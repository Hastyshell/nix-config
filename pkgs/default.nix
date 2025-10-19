{ pkgs, ... }:
{
  assets = pkgs.callPackage ./assets { };
  xwechat = pkgs.callPackage ./wechat { };
}
