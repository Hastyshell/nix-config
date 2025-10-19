{ lib, stdenv }:
stdenv.mkDerivation (finalAttrs: {
  pname = "assets";
  version = "1.0";

  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers/
    mkdir -p $out/share/icons/
    install wallpapers/* $out/share/wallpapers/
    install icons/* $out/share/icons/

    runHook postInstall
  '';

  meta = {
    description = "Assets for this nix-config";
    license = lib.licenses.mit;
  };
})
