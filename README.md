<h1 align="center">
  <img src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/static/logos/neovim-logo-300x87.png" alt="Neovim">
</h1>

Nix-aware [Neovim](https://github.com/neovim/neovim) lua configuration.

# Nix

This flake packages the required version of neovim (nightly) with the configuration.

## Home Manager

Add input to flake.

```nix
{
  inputs = {
    neovim.url = "github:9prestidigitator/nvim";
  };
}
```

Import the module in a home manager configuration:

```nix
{
  imports = [
    inputs.neovim.homeManagerModules.default
  ];
  programs.Neovim = {
    enable = true;
    autoUpdate = true;
  };
}
```

# External Tooling

These are a good to have in you environment for a better experience. If you are using NixOS it is expected that you provide these packages via your dev shell or configuration, otherwise will be installed via Mason.

## LSPs

- Rust Analyzer
- Clangd
- BasedPyright
- Ruff
- Omnisharp
- Lua Language Server
- Bash Language Server
- texlab
- MATLAB Language Server
- qmlls
- TS Language Server
- nixd

## Formatters

- clang-format
- alejandra
- csharpier
- black
- stylua
- prettier
- prettierd
- tex-fmt
- shfmt
- taplo
- jq

## Debuggers

This is not yet nix aware so it will be installed via mason everywhere.

- codelldb
- netcoredbg
- debugpy

## Programs

- [fd](https://github.com/BurntSushi/ripgrep)
- [ripgrep](https://github.com/BurntSushi/ripgrep)

# Plugins

## Core

- plenary.nvim
- auto-session
- alpha-nvim
- nvim-autopairs
- nvim-surround
- which-key.nvim
- nui.nvim
- lazygit.nvim
- obsidian.nvim
- leetcode.nvim

## LSP/Formatters/Debuggers

- nvim-lspconfig
- fidget.nvim
- conform.nvim
- nvim-dap
- nvim-dap-ui
- nvim-nio
- nvim-dap-python
- mini.pick
- lazydev.nvim
- vimtex

## File Explorer

- oil.nvim
- oil-vcs-status

## Packaging

- mason.nvim
- mason-lspconfig.nvim
- mason-confirm.nvim
- mason-nvim-dap.nvim

## Autocomplete

- nvim-cmp
- cmp-nvim-lsp
- cmp-buffer
- cmp-path
- cmp-cmdline

## Appearance

- vague.nvim
- lualine.nvim
- gitsigns.nvim
- smear-cursor.nvim
- markview.nvim
- mini.icons
- nvim-web-devicons
