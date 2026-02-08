{
  description = "Neovim + Config";
  # Point of this is to package my desired Neovim version, and configuration
  # into one home manager module.

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
      cfg = config.programs.neovim;
      nvimPkg = neovim-nightly-overlay.packages.${pkgs.system}.default;

      nvimWrapper = pkgs.writeShellApplication {
        name = "${cfg.appName}";
        runtimeInputs = [nvimPkg];
        text = ''
          set -euo pipefail
          export NVIM_APPNAME="${cfg.appName}"
          exec "${nvimPkg}/bin/nvim" "$@"
        '';
      };
    in {
      options.programs.Neovim = {
        enable = lib.mkEnableOption "Personal Neovim config + nightly";

        repo = lib.mkOption {
          type = lib.types.str;
          default = "https://github.com/9Prestidigitator/nvim.git";
          description = "Git repo containing configuration";
        };
        branch = lib.mkOption {
          type = lib.types.str;
          default = "main";
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
          default = "${config.home.homeDirectory}/.config";
          description = "Config directory (~/.config).";
        };
        configDir = lib.mkOption {
          type = lib.types.str;
          default = "${cfg.configHome}/${cfg.appName}";
          description = "Directory where the config repo lives.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [nvimWrapper];

        xdg.desktopEntries.${cfg.appName} = {
          name = "Neovim";
          genericName = "Text Editor";
          comment = "Neovim (nightly) with ${cfg.appName} config";
          exec = "${cfg.appName} %F";
          terminal = true; # Neovim is terminal-based
          type = "Application";
          categories = ["Utility" "TextEditor" "Development"];
          mimeType = [
            "inode/directory"
            "text/plain"
            "text/markdown"
            "text/x-shellscript"
            "text/x-csrc"
            "text/x-c++src"
            "text/x-python"
            "application/x-nix"
          ];
          icon = ./logo.svg;
        };

        xdg.mimeApps.enable = true;
        xdg.mimeApps.defaultApplications = {
          "text/plain" = ["${cfg.appName}.desktop"];
          "text/markdown" = ["${cfg.appName}.desktop"];
          "application/x-nix" = ["${cfg.appName}.desktop"];
        };

        home.activation.prestiNvimUpdate =
          lib.hm.dag.entryAfter ["writeBoundary"]
          (lib.mkIf cfg.autoUpdate ''
              set -euo pipefail

              dst="${cfg.configDir}"
              repo="${cfg.repo}"
              branch="${cfg.branch}"

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
      };
    in {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          export SHELL="/run/current-system/sw/bin/bash"
        '';

        packages = with pkgs; [
          lua-language-server
          stylua

          git

          ripgrep
          fd

          nixd
          alejandra
        ];
      };
    })
    // {
      homeManagerModules.default = hmModule;
    };
}
