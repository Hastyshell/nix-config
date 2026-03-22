{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  walkerPackage = pkgs.rustPlatform.buildRustPackage rec {
    pname = "walker";
    version = (builtins.fromTOML (builtins.readFile "${inputs.walker.outPath}/Cargo.toml")).package.version;

    # Use the fetched flake source directly here. The upstream package filters
    # the source tree with `lib.fileset.toSource`, which creates another raw
    # store source path that `nix flake check --no-build` can trip over on a
    # clean runner.
    src = inputs.walker.outPath;
    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs = with pkgs; [
      gobject-introspection
      pkg-config
      protobuf
      wrapGAppsHook4
    ];

    buildInputs = with pkgs; [
      glib
      gtk4
      gtk4-layer-shell
      gdk-pixbuf
      graphene
      cairo
      pango
      poppler
    ] ++ (with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-libav
    ]);

    meta = {
      description = "Wayland-native application runner";
      homepage = "https://github.com/abenz1267/walker";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "walker";
    };
  };
in
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
      package = walkerPackage;
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
