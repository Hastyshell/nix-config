{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    package = pkgs.unstable.claude-code;
    settings = {
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
