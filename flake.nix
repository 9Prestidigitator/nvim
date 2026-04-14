{
  description = "maxvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            lua-language-server
            stylua

            nixd
            alejandra

            prettierd

            git

            ripgrep
            fd
          ];
        };
      };

      flake = {
        homeManagerModules.default = {
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.programs.maxvim;
          effectiveAppName = baseNameOf cfg.config.dir;
          effectiveConfigHome = dirOf cfg.config.dir;

          nvimWrapper = pkgs.writeShellApplication {
            name = cfg.name;
            runtimeInputs = [cfg.package];
            text = ''
              set -euo pipefail
              export NVIM_APPNAME="${effectiveAppName}"
              export XDG_CONFIG_HOME="${effectiveConfigHome}"
              exec "${cfg.package}/bin/nvim" "$@"
            '';
          };
        in {
          options.programs.maxvim = {
            enable = lib.mkEnableOption "Personal Neovim config";

            name = lib.mkOption {
              type = lib.types.str;
              default = "nvim";
              description = "Executable and desktop-entry name.";
            };
            package = lib.mkOption {
              type = lib.types.package;
              default = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
              description = "Neovim package to use. Minimum required version is 0.12. Nightly by default.";
            };
            desktopIntegration = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to add desktop file.";
            };
            config = {
              dir = lib.mkOption {
                type = lib.types.str;
                default = "${config.xdg.configHome}/mvim";
                description = "Directory where the git managed config lives.";
              };
              cloneUrl = lib.mkOption {
                type = lib.types.str;
                default = "https://github.com/9Prestidigitator/nvim.git";
                description = "Url to clone in the pace of the neovim configuration.";
              };
              branch = lib.mkOption {
                type = lib.types.str;
                default = "main";
                description = "Branch of git repository to use.";
              };
              pushUrl = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "git@github.com:9Prestidigitator/nvim.git";
                description = "Url to push to origin.";
              };
              autoUpdate = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Whether to update via git pull (ff-only) during activation.";
              };
            };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [nvimWrapper];

            xdg = lib.mkIf cfg.desktopIntegration {
              desktopEntries.${cfg.name} = {
                name = "Neovim";
                genericName = "Text Editor";
                comment = "Neovim using ${cfg.config.dir}";
                exec = "${cfg.name} %F";
                terminal = true;
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
                icon = ./logo.png;
              };
              mimeApps = {
                enable = true;
                defaultApplications = {
                  "text/plain" = ["${cfg.name}.desktop"];
                  "text/markdown" = ["${cfg.name}.desktop"];
                  "application/x-nix" = ["${cfg.name}.desktop"];
                };
              };
            };

            home.activation.NvimUpdate =
              lib.hm.dag.entryAfter ["writeBoundary"]
              (lib.mkIf cfg.config.autoUpdate ''
                set -euo pipefail

                dst="${cfg.config.dir}"
                repo="${cfg.config.cloneUrl}"
                branch="${cfg.config.branch}"
                pushUrl="${cfg.config.pushUrl}"

                mkdir -p "$(dirname "$dst")"

                if [ -d "$dst/.git" ]; then
                  if [ "$(${pkgs.git}/bin/git -C "$dst" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)" != "HEAD" ] &&
                     ${pkgs.git}/bin/git -C "$dst" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1 &&
                     [ -z "$(${pkgs.git}/bin/git -C "$dst" status --porcelain)" ]; then
                    ${pkgs.git}/bin/git -C "$dst" pull --ff-only || true
                  fi
                else
                  if [ -e "$dst" ] && [ -n "$(ls -A "$dst" 2>/dev/null || true)" ]; then
                    echo "neovim: $dst exists and is not empty (and not a git repo); not overwriting."
                  else
                    rm -rf "$dst"
                    ${pkgs.git}/bin/git clone --branch "$branch" "$repo" "$dst"
                    if [ -d "$pushUrl" ]; then
                      cd "$dst"
                      ${pkgs.git}/bin/git remote set-url --push origin "$pushUrl"
                    fi
                  fi
                fi
              '');
          };
        };
      };
    };
}
