{ pkgs, ... }:
{
  assets = pkgs.callPackage ./assets { };
  satty-shot = pkgs.callPackage ./satty-shot { };
  xwechat = pkgs.callPackage ./wechat { };
}
