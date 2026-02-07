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
  }: let
    hmModule = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.prestiNvim;
      nvimPkg = pkgs.neovim-nightly;

      nvimWrapper = pkgs.writeShellApplication {
        name = "nvim";
        runtimeInputs = [nvimPkg];
        text = ''
          set -euo pipefail
          export NVIM_APPNAME="${cfg.appName}"
          exec "${nvimPkg}/bin/nvim" "$@"
        '';
      };
    in {
      options.programs.prestiNvim = {
        repo = lib.mkOption {
          type = lib.types.str;
          default = "https://github.com/9Prestidigitator/nvim.git";
          description = "Git repo containing configuration";
        };
        branch = lib.mkOption {
          type = lib.types.str;
          defualt = "main";
          description = "Branch of git repository to use.";
        };
        appName = lib.mkOption {
          type = lib.types.str;
          default = "nvim";
          description = "NVIM_APPNAME used for XDG dirs (config/data/state/cache)";
        };
        autoUpdate = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to update via git pull (ff-only) during activation.";
        };
        configHome = lib.mkOption {
          type = lib.types.str;
          default = "${config.xdg.configHome}";
          description = "Config directory (~/.config).";
        };
        configDir = lib.mkOption {
          type = lib.types.str;
          default = "${cfg.configHome}/${cfg.appName}-9prest";
          description = "Directory where the config repo lives.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [nvimWrapper];
        home.activation.prestiNvimUpdate =
          lib.hm.dag.entryAfter ["writeBoundary"]
          (lib.mkIf cfg.autoUpdate ''
              set -euo pipefail
              dst="${cfg.configDir}"
              repo="${cfg.repo}"
              mkdir -p "${cfg.configHome}"

              if [ -d "$dst/.git" ]; then
              # Only ff when not detached, has upstream, clean working tree
              if [ "$(${pkgs.git}/bin/git -C "$dst" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)" != "HEAD" ] &&
                 ${pkgs.git}/bin/git -C "$dst" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 &&
                 [ -z "$(${pkgs.git}/bin/git -C "$dst" status --porcelain)" ]; then
                ${pkgs.git}/bin/git -C "$dst" pull --ff-only || true
              fi
              else
              # Clone only if missing/empty; never overwrite non-empty non-git dirs
              if [ -e "$dst" ] && [ -n "$(ls -A "$dst" 2>/dev/null || true)" ]; then
                echo "prestiNvim: $dst exists and is not empty (and not a git repo); not overwriting."
              else
                rm -rf "$dst"
                ${pkgs.git}/bin/git clone --branch "$branch" "$repo" "$dst"
              fi
            fi
          '');
      };
    };
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [neovim-nightly-overlay.overlays.default];
      };
      nvimNightly = neovim-nightly-overlay.packages.${system}.default;
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
        name = "nvim";
        runtimeInputs = [nvimNightly];
        text = ''
          set -euo pipefail
          export NVIM_APPNAME="9prestidigitator-nvim"

          cfg_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
          dst="$cfg_home/$NVIM_APPNAME"

          # Prefer user checkout if present; else fallback to flake snapshot
          if [ -e "$dst/init.lua" ]; then
            export XDG_CONFIG_HOME="$cfg_home"
          else
            export XDG_CONFIG_HOME="${nvimConfig}"
          fi

          exec "${nvimNightly}/bin/nvim" "$@"
        '';
      };
    in {
      packages = {default = nvimWrapped;};
      apps = {
        default = {
          type = "app";
          program = "${nvimWrapped}/bin/nvim";
        };
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
    }) {
      homeManagerModules.default = hmModule;
    };
}
