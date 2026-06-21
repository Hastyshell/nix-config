{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea
    getopt
    iterm2
    maccy
    mas
    stats
  ];
}
