{ pkgs, ... }:
{
  home.packages = with pkgs; [
    obsidian
    t3code-desktop
  ];
}
