{ pkgs, ... }:
let
  inherit (pkgs) codex;
in
{
  home.packages = with pkgs; [
    codex
    mypkgs.codex-desktop-app
  ];

  home.sessionVariables = {
    CODEX_CLI_PATH = "${codex}/bin/codex";
  };
}
