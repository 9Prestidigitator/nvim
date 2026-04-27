{
  lib,
  stdenvNoCC,
  makeWrapper,
  neovimPackage,
  src,
  git,
  ripgrep,
  fd,
  xdg-utils,
}:
stdenvNoCC.mkDerivation {
  pname = "maxvim";
  version = "0.1.0";
  inherit src;

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/maxvim"
    cp -r init.lua lua nvim-pack-lock.json "$out/share/maxvim/"

    mkdir -p "$out/bin"

    makeWrapper ${lib.getExe neovimPackage} "$out/bin/maxvim" \
      --set NVIM_APPNAME maxvim \
      --set XDG_CONFIG_HOME "$out/share" \
      --prefix PATH : ${lib.makeBinPath [
      git
      ripgrep
      fd
      xdg-utils
    ]}

    runHook postInstall
  '';

  meta = {
    description = "Store-backed wrapped Neovim configuration";
    mainProgram = "maxvim";
  };
}
