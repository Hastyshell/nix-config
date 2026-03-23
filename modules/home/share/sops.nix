{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.sops;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.custom.sops = {
    enable = lib.mkEnableOption "sops-nix secrets management";
    defaultSopsFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the default sops secrets file";
    };
    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      description = "Path to the age key file used for decryption";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.sops ];

    sops = {
      inherit (cfg) defaultSopsFile;
      age.keyFile = cfg.keyFile;
    };
  };
}
