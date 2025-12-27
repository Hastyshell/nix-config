# XDG stands for "Cross-Desktop Group", with X used to mean "cross".
# It's a bunch of specifications from freedesktop.org intended to standardize desktops and
# other GUI applications on various systems (primarily Unix-like) to be interoperable:
#   https://www.freedesktop.org/wiki/Specifications/
{ config, ... }:
{
  xdg.configFile."mimeapps.list".force = true;
  xdg = {
    enable = true;

    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    # manage $XDG_CONFIG_HOME/mimeapps.list
    # xdg search all desktop entries from $XDG_DATA_DIRS, check it by command:
    #  echo $XDG_DATA_DIRS
    # the system-level desktop entries can be list by command:
    #   ls -l /run/current-system/sw/share/applications/
    # the user-level desktop entries can be list by command(user ryan):
    #  ls /etc/profiles/per-user/ryan/share/applications/
    mimeApps = {
      enable = true;
      # let `xdg-open` to open the url with the correct application.
      defaultApplications =
        let
          browser = [ "google-chrome.desktop" ];
          editor = [ "nvim.desktop" ];
          terminal = [ "Alacritty.desktop" ];
        in
        {
          "application/json" = browser;
          "application/pdf" = browser; # TODO: pdf viewer

          "text/html" = browser;
          "text/xml" = browser;
          "text/plain" = editor;
          "application/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xhtml_xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/x-extension-xht" = browser;
          "application/x-extension-xhtml" = browser;
          "application/x-wine-extension-ini" = editor;

          # define default applications for some url schemes.
          "x-scheme-handler/about" = browser; # open `about:` url with `browser`
          "x-scheme-handler/ftp" = browser; # open `ftp:` url with `browser`
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;

          # all other unknown schemes will be opened by this default application.
          "x-scheme-handler/unknown" = editor;

          # term
          "x-scheme-handler/terminal" = terminal;

          # "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop " ];

          "audio/*" = [ "mpv.desktop" ];
          "video/*" = [ "mpv.desktop" ];
          "image/*" = [ "imv-dir.desktop" ];
          "image/gif" = [ "imv-dir.desktop" ];
          "image/jpeg" = [ "imv-dir.desktop" ];
          "image/png" = [ "imv-dir.desktop" ];
          "image/webp" = [ "imv-dir.desktop" ];
        };

      associations.removed = {
        # ......
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/.xdg/desktop";
      documents = "${config.home.homeDirectory}/.xdg/documents";
      download = "${config.home.homeDirectory}/.xdg/downloads";
      music = "${config.home.homeDirectory}/.xdg/music";
      pictures = "${config.home.homeDirectory}/.xdg/pictures";
      publicShare = "${config.home.homeDirectory}/.xdg/public";
      templates = "${config.home.homeDirectory}/.xdg/templates";
      videos = "${config.home.homeDirectory}/.xdg/videos";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };
  };
}
