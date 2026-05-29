{ lib, pkgs, ... }:
lib.mkIf pkgs.stdenv.isLinux {
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
