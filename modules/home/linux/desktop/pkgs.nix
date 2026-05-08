{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
    libnotify
    papirus-icon-theme
    hicolor-icon-theme
    swww
    file-roller
    wtype
    wl-clipboard

    mypkgs.xwechat
    mypkgs.satty-shot
    feishu
    libreoffice
  ];

}
