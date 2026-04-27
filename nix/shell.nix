{
  mkShell,
  lua-language-server,
  stylua,
  nixd,
  alejandra,
  prettierd,
  git,
  ripgrep,
  fd,
}:
mkShell {
  packages = [
    lua-language-server
    stylua

    nixd
    alejandra

    prettierd

    git

    ripgrep
    fd
  ];
}
