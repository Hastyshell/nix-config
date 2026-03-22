{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.elephant.homeManagerModules.default ];

  config = lib.mkIf config.custom.linux.desktop.launcher.walker.enable {
    programs.elephant.enable = true;

    services.walker = {
      enable = true;
      package = pkgs.unstable.walker;
      systemd.enable = true;
      settings = {
        theme = "tokyo-night";
        keybinds.quick_activate = [ ];
      };
    };

    xdg.configFile = {
      "walker/themes/tokyo-night/style.css".text = builtins.readFile ./style.css;
      "walker/themes/tokyo-night/layout.xml".text = builtins.readFile ./layout.xml;
      "walker/themes/tokyo-night/item_clipboard.xml".text = builtins.readFile ./items/clipboard.xml;
    };
  };
}
