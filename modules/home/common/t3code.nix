{ pkgs, ... }:
{
  programs.t3code = {
    enable = true;
    package = pkgs.t3code;
  };
}
