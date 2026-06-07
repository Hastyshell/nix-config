{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    settings = {
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
