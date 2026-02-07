{
  description = "Neovim + config packaged as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    neovim-nightly-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            neovim-nightly-overlay.overlays.default
          ];
        };

        # avoid treesitter hash-mismatch issues
        nvimNightly = neovim-nightly-overlay.packages.${system}.default;

        # Put this repo into the store under a dedicated appname directory
        nvimConfig = pkgs.stdenvNoCC.mkDerivation {
          name = "9prestidigitator-nvim-config";
          src = self;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/9prestidigitator-nvim
            cp -R $src/* $out/9prestidigitator-nvim/
          '';
        };

        nvimWrapped = pkgs.writeShellApplication {
          name = "nvim-9prestidigitator";
          runtimeInputs = [nvimNightly pkgs.coreutils pkgs.git pkgs.rsync];
          text = ''
            set -euo pipefail
            export NVIM_APPNAME="9prestidigitator-nvim"

            cfg_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
            dst="$cfg_home/$NVIM_APPNAME"
            src="${nvimConfig}/9prestidigitator-nvim"

            is_dir_empty() {
              [ -z "$(ls -A "$1" 2>/dev/null || true)" ]
            }

            clone_or_seed() {
              [ -d "$dst/.git" ] && return 0

              if [ ! -e "$dst/init.lua" ]; then
                git clone https://github.com/9Prestidigitator/nvim.git "$dst"
                return 0
              fi

              # else, seed from flake snapshot
              if [ ! -e "$dst/init.lua" ]; then
                rsync -a "$src/" "$dst/"
              fi
            }

            mkdir -p "$dst"
            auto_update() {
              [ -d "$dst/.git" ] || return 0

              # must be on a branch and have an upstream
              if [ "$(git -C "$dst" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)" = "HEAD" ]; then
                return 0
              fi
              git -C "$dst" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 || return 0

              # Don't touch if there are local changes
              [ -n "$(git -C "$dst" status --porcelain)" ] && return 0

              # fetch/fast-forward only if behind
              git -C "$dst" fetch --quiet || return 0
              local_counts="$(git -C "$dst" rev-list --left-right --count "HEAD...@{u}" 2>/dev/null || echo "0 0")"
              behind="$(printf '%s' "$local_counts" | awk '{print $2}')"

              if [ "''${behind:-0}" -gt 0 ]; then
                git -C "$dst" pull --ff-only --quiet || true
              fi
            }

            clone_or_seed
            auto_update

            export XDG_CONFIG_HOME="$cfg_home"
            exec "${nvimNightly}/bin/nvim" "$@"
          '';
        };
      in {
        packages = {
          default = nvimWrapped;
          neovim = nvimWrapped;
        };

        apps.default = {
          type = "app";
          program = "${nvimWrapped}/bin/nvim-9prestidigitator";
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            export SHELL="/run/current-system/sw/bin/bash"
          '';

          packages = [
            nvimWrapped
            pkgs.lua-language-server
            pkgs.stylua

            pkgs.git

            pkgs.ripgrep
            pkgs.fd

            pkgs.nixd
            pkgs.alejandra
          ];
        };
      }
    );
}
