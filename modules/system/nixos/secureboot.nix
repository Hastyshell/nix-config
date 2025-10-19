{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  config = lib.mkIf config.custom.nixos.secureBoot.lanzaboote.enable {
    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      configurationLimit = 5;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
