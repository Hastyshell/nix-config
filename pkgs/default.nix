{ pkgs, ... }:
let
  inherit (pkgs) lib stdenv;
in
{
  assets = pkgs.callPackage ./assets { };
}
// lib.optionalAttrs stdenv.isLinux {
  codex-desktop-app = pkgs.callPackage ./codex-desktop-app { };
  satty-shot = pkgs.callPackage ./satty-shot { };
  xwechat = pkgs.callPackage ./wechat { };
}
// lib.optionalAttrs stdenv.isDarwin {
}
