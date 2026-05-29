{ lib, pkgs, ... }:
let
  inherit (pkgs) codex;
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [
    codex
  ];

  home.sessionVariables = {
    CODEX_CLI_PATH = "${codex}/bin/codex";
  };
}
