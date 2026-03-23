{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.custom.nixos.desktop.displayManager.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        };
      };
      useTextGreeter = true;
    };
  };
}
