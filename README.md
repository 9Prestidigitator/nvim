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
    inputs.maxvim.homeManagerModules.default
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

- [mini.pick](https://github.com/nvim-mini/mini.pick): Picker.
- [auto-session](https://github.com/rmagatti/auto-session): Automatically saves sessions.
- [alpha-nvim](https://github.com/goolord/alpha-nvim): Greeter.
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs): Bracket/quote pairing.
- [nvim-surround](https://github.com/kylechui/nvim-surround): Surrounding plugin.
- [which-key.nvim](https://github.com/folke/which-key.nvim): Modal key viewer.
- [flash.nvim](https://github.com/folke/flash.nvim): Cursor teleportation.
- [vimtex](https://github.com/lervag/vimtex): Shortcuts to compile latex.
- [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim): Obsidian vault parsing.
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim): LazyGit window.

Might move these to another branch. They are large, somewhat unmaintained, and not always used:

- plenary.nvim
- nui.nvim
- leetcode.nvim

## LSP/Formatters/Debuggers

- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [conform.nvim](https://github.com/stevearc/conform.nvim): Lightweight formatter.
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [nvim-nio](https://github.com/nvim-neotest/nvim-nio): Dependency of nvim-dap-ui.
- [lazydev.nvim](https://github.com/folke/lazydev.nvim): For better lua parsing.

## File Explorer

- [oil.nvim](https://github.com/stevearc/oil.nvim)
- [oil-vcs-status](https://github.com/SirZenith/oil-vcs-status)

## Packaging

- mason.nvim
- mason-lspconfig.nvim
- mason-conform.nvim
- mason-nvim-dap.nvim

## Autocomplete

Neovim has it's own native autocomplete. However last time I tried, it was buggy with OmniSharp.

- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp.git)
- cmp-buffer
- cmp-path
- cmp-cmdline

## Appearance

- [vague.nvim](https://github.com/vague-theme/vague.nvim): Theme.
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [smear-cursor.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [markview.nvim](https://github.com/OXY2DEV/markview.nvim)
- [mini.icons](https://github.com/nvim-mini/mini.icons)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
