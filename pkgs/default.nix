{ pkgs, ... }:
{
  assets = pkgs.callPackage ./assets { };
  codex-desktop-app = pkgs.callPackage ./codex-desktop-app { };
  satty-shot = pkgs.callPackage ./satty-shot { };
  xwechat = pkgs.callPackage ./wechat { };
}
