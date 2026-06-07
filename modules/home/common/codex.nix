{ pkgs, ... }:
let
  inherit (pkgs) codex;
in
{
  home.packages = [
    codex
  ];

  home.sessionVariables = {
    CODEX_CLI_PATH = "${codex}/bin/codex";
  };
}
