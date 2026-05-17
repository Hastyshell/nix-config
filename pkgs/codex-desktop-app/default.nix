{
  lib,
  appimageTools,
  codex,
  fetchurl,
  stdenvNoCC,
  ...
}:
let
  inherit (stdenvNoCC.hostPlatform) system;

  pname = "codex-desktop-app";
  version = "26.506.31421-launcher.27";

  meta = {
    description = "Unofficial Linux launcher for the Codex desktop app";
    homepage = "https://github.com/better-slop/codex-app-linux";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ hastyshell ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };

  sources = {
    x86_64-linux = {
      src = fetchurl {
        url = "https://github.com/better-slop/codex-app-linux/releases/download/v${version}/codex-app-linux-${version}-x64.AppImage";
        hash = "sha256-2nwDOseyY3feznolzRU1oVKnq6OETveN9nusL/fVNm0=";
      };
      icon = fetchurl {
        url = "https://github.com/better-slop/codex-app-linux/releases/download/v${version}/codex-app-linux-${version}-x64.png";
        hash = "sha256-HJJuOAv+alD0Bkjdm8XeiNpycVRkka35nschcuF99qA=";
      };
    };
  };

  inherit (sources.${system} or (throw "Unsupported system: ${system}")) src icon;
in
appimageTools.wrapType2 {
  inherit
    pname
    version
    src
    meta
    ;

  extraInstallCommands = ''
    install -m 444 -D ${icon} $out/share/icons/hicolor/512x512/apps/${pname}.png
    install -m 444 -D /dev/stdin $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Name=Codex
    Comment=Codex desktop app
    Exec=${pname}
    Icon=${pname}
    Terminal=false
    Type=Application
    Categories=Development;
    EOF
  '';

  extraBwrapArgs = [
    "--setenv CODEX_CLI_PATH ${codex}/bin/codex"
  ];
}
