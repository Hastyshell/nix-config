{ pkgs, ... }:
{
  assets = pkgs.callPackage ./assets { };
  opencode-claude-max-proxy = pkgs.callPackage ./opencode-claude-max-proxy { };
  satty-shot = pkgs.callPackage ./satty-shot { };
  xwechat = pkgs.callPackage ./wechat { };
}
