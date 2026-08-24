{
  config,
  lib,
  pkgs,
  ...
}:
let
  npmPrefix = config.home.sessionVariables.NPM_CONFIG_PREFIX;
in
{
  home.packages = [
    pkgs.nodejs
  ];

  home.sessionVariables.NPM_CONFIG_PREFIX = lib.mkDefault "${config.home.homeDirectory}/.local";

  home.sessionPath = [
    "${npmPrefix}/bin"
  ];
}
