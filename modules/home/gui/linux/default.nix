{
  imports = [
    ./alacritty.nix
    ./chrome.nix
    ./fcitx5.nix
    ./stylix.nix
    ./swaylock.nix
    ./mako.nix
    ./media.nix
    ./xdg.nix
    ./kanshi.nix
    ./obs.nix
    ./pkgs.nix
    ./extra
  ];

  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
    # enable native Wayland support for most Electron apps
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # misc
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "QT_QPA_PLATFORM" = "wayland";
    "SDL_VIDEODRIVER" = "wayland";
    "GDK_BACKEND" = "wayland";
    "XDG_SESSION_TYPE" = "wayland";
  };

  # display volumes and brightness
  services.avizo.enable = true;

  # https://wiki.archlinux.org/title/Kanshi
  services.kanshi.enable = true;
}
