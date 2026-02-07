{
  description = "Neovim + config packaged as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, neovim-nightly-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            neovim-nightly-overlay.overlays.default
          ];
        };

        # Recommended by the overlay README to avoid treesitter hash-mismatch issues:
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
          runtimeInputs = [ nvimNightly pkgs.coreutils ];
          text = ''
            set -euo pipefail
            export NVIM_APPNAME="9prestidigitator-nvim"
            cfg_root="$(mktemp -d)"
            trap 'rm -rf "$cfg_root"' EXIT

            mkdir -p "$cfg_root/$NVIM_APPNAME"
            cp -R "${nvimConfig}/9prestidigitator-nvim/." "$cfg_root/$NVIM_APPNAME"

            export XDG_CONFIG_HOME="$cfg_root"
            exec "${nvimNightly}/bin/nvim" "$@"
          '';
        };
      in
      {
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

