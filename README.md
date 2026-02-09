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
  programs.Neovim.enable = true;
}
```

# External Tooling

These are a good to have in you environment for a better experience:

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

## Programs

- [fd](https://github.com/BurntSushi/ripgrep)
- [ripgrep](https://github.com/BurntSushi/ripgrep)

# Plugins

- nvim-lspconfig
- mason.nvim
- mason-lspconfig.nvim
- mason-confirm.nvim
- mason-nvim-dap.nvim
- plenary.nvim
- nui.nvim
- conform.nvim
- nvim-dap
- nvim-dap-ui
- nvim-nio
- nvim-dap-python
- vague.nvim
- smear-cursor.nvim
- lualine.nvim
- mini.icons
- nvim-web-devicons
- which-key.nvim
- alpha-nvim
- oil.nvim
- oil-vcs-status
- auto-session
- mini.pick
- nvim-autopairs
- nvim-surround
- gitsigns.nvim
- lazygit.nvim
- lazydev.nvim
- markview.nvim
- obsidian.nvim
- vimtex
- leetcode.nvim
- fidget.nvim
- nvim-cmp
- cmp-nvim-lsp
- cmp-buffer
- cmp-path
- cmp-cmdline
