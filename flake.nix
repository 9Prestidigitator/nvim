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
        devShells.default = pkgs.callPackage ./nix/shell.nix {};
        packages.default = pkgs.callPackage ./nix/package.nix {
          neovimPackage = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
          src = ./.;
        };
      };
      flake.homeModules.default = import ./nix/home.nix {inherit inputs;};
    };
}
