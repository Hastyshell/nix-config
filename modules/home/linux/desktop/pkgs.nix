{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
    libnotify
    papirus-icon-theme
    hicolor-icon-theme
    awww
    file-roller
    wtype
    wl-clipboard
    localsend

    mypkgs.codex-desktop-app
    mypkgs.xwechat
    mypkgs.satty-shot
    feishu
    libreoffice
  ];

}
