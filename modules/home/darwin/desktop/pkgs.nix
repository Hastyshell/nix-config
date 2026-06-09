{ pkgs, ... }:
{
  home.packages = with pkgs; [
    getopt
    mas
  ];
}
