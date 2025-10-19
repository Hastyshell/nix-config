{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override { embeddedTheme = "astronaut"; };
in
{
  config = lib.mkIf config.custom.nixos.desktop.displayManager.sddm.enable {
    services.displayManager.sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;

      wayland = {
        enable = true;
        compositor = "kwin";
      };
      enableHidpi = true;
      theme = "sddm-astronaut-theme";
      settings = {
        Theme = {
          Current = "sddm-astronaut-theme";
          CursorTheme = "breeze_cursors";
          CursorSize = 24;
        };
      };
      extraPackages = with pkgs; [ custom-sddm-astronaut ];
    };

    environment.systemPackages = with pkgs; [
      custom-sddm-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.breeze
    ];
  };
}
