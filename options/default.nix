{
  flake.customOptions =
    { lib, ... }:
    {
      options = {
        custom.nixos.secureBoot.lanzaboote.enable = lib.mkEnableOption "enable lanzaboote as secure booter";

        custom.nixos.graphics.nvidia.enable = lib.mkEnableOption "enable nvidia configs";

        custom.linux.desktop.wm.niri.enable = lib.mkEnableOption "enable niri as default wm";

        custom.linux.desktop.launcher.walker.enable =
          lib.mkEnableOption "enable walker as default app launcher";

        custom.linux.desktop.bar.waybar.enable = lib.mkEnableOption "enable waybar as default bar";

        custom.nixos.desktop.displayManager.sddm.enable =
          lib.mkEnableOption "enable walker as default display manager";
        custom.nixos.desktop.displayManager.greetd.enable =
          lib.mkEnableOption "enable walker as default display manager";

        custom.linux.desktop.fileManager.thunar.enable =
          lib.mkEnableOption "enable thunar as default file manager";

        custom.linux.desktop.swayidle.enable = lib.mkEnableOption "enable swayidle";

        custom.nixos.desktop.remoteDesktop.sunshine.enable =
          lib.mkEnableOption "enable sunshine as remote desktop solution";
      };
    };
}
