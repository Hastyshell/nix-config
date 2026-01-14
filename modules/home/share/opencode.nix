{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    settings = {
      theme = "tokyonight";
    };
  };
}
