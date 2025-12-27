{
  lib,
  config,
  inputs,
  ...
}:
{

  imports = [ inputs.walker.homeManagerModules.default ];

  config = lib.mkIf config.custom.linux.desktop.launcher.walker.enable {
    nix.settings = {
      extra-substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];
      extra-trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };

    programs.walker = {
      enable = true;
      runAsService = true; # Note: this option isn't supported in the NixOS module only in the home-manager module
      config = {
        theme = "tokyo-night";
        keybinds.quick_activate = [ ];
      };
      themes = {
        "tokyo-night" = {
          style = builtins.readFile ./style.css;
          layouts = {
            "layout" = builtins.readFile ./layout.xml;
            "item_clipboard" = builtins.readFile ./items/clipboard.xml;
          };
        };
      };

      # All options from the config.toml can be used here https://github.com/abenz1267/walker/blob/master/resources/config.toml
      # config = {
      #   theme = "your theme name";
      #   placeholders."default" = {
      #     input = "Search";
      #     list = "Example";
      #   };
      #   providers.prefixes = [
      #     {
      #       provider = "websearch";
      #       prefix = "+";
      #     }
      #     {
      #       provider = "providerlist";
      #       prefix = "_";
      #     }
      #   ];
      #   keybinds.quick_activate = [ "F1" "F2" "F3" ];
      # };
      #
      # # Set `programs.walker.config.theme="your theme name"` to choose the default theme
      # themes = {
      #   "your theme name" = {
      #     # Check out the default css theme as an example https://github.com/abenz1267/walker/blob/master/resources/themes/default/style.css
      #     style = " /* css */ ";
      #
      #     # Check out the default layouts for examples https://github.com/abenz1267/walker/tree/master/resources/themes/default
      #     layouts = {
      #       "layout" = " <!-- xml --> ";
      #       "item_calc" = " <!-- xml --> ";
      #       # other provider layouts
      #     };
      #   };
      #   "other theme name" = {
      #     # ...
      #   };
      #   # more themes
      # };
    };
  };
}
