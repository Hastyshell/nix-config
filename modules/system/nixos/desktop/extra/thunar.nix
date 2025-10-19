{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.custom.linux.desktop.fileManager.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-volman
        thunar-archive-plugin
      ];
    };
    # keep preference
    # use "alacritty --working-directory %f" to open terminal
    programs.xfconf.enable = true;

    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}
