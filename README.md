<h1 align="center">
  <img src="https://raw.githubusercontent.com/neovim/neovim.github.io/master/static/logos/neovim-logo-300x87.png" alt="Neovim">
</h1>

Nix-aware [Neovim](https://github.com/neovim/neovim) lua configuration.

# Nix Flake

This flake packages my lua configuration with my preferred version of neovim (0.12+), ensuring that I write my neovim configuration in lua without nix-language abstraction.

## Home Manager Module

Add input to flake.

```nix
{
  inputs = {
    maxvim.url = "github:9prestidigitator/nvim";
  };
}
```

Import the module in a home manager configuration:

```nix
{
  imports = [
    inputs.neovim.homeManagerModules.default
  ];
  programs.maxvim = {
    enable = true;
    name = "NvimCustom";
    config = {
      dir = "${config.xdg.configHome}/customNvimConfig"
      autoUpdate = true;
    };
  };
}
```

# External Tooling

These are a good to have in you environment for a better development experience. If you are using NixOS it is expected that you provide these packages via your dev shell or configuration, otherwise will be installed via Mason.

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

- codelldb
- netcoredbg
- debugpy

## Programs

- [fd](https://github.com/BurntSushi/ripgrep)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [LazyGit](https://github.com/jesseduffield/lazygit)

# Plugins

## Core

- mini.pick
- auto-session
- alpha-nvim
- nvim-autopairs
- nvim-surround
- which-key.nvim
- flash.nvim
- vimtex
- obsidian.nvim
- lazygit.nvim

Might move these to another branch. They are large, somewhat unmaintained, and not always used:

- plenary.nvim
- nui.nvim
- leetcode.nvim

## LSP/Formatters/Debuggers

- nvim-lspconfig
- conform.nvim
- nvim-dap
- nvim-dap-ui
- nvim-dap-python
- lazydev.nvim: For better lua parsing
- nvim-nio

## File Explorer

- oil.nvim
- oil-vcs-status

## Packaging

Might move these to their own non-nix branch:

- mason.nvim
- mason-lspconfig.nvim
- mason-conform.nvim
- mason-nvim-dap.nvim

## Autocomplete

Neovim has it's own native autocomplete. However last time I tried, it was buggy with OmniSharp.

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
