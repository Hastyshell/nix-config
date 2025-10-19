{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.nur.modules.homeManager.default ];

  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
    libnotify
    adwaita-icon-theme
    swww
    file-roller

    mypkgs.xwechat
  ];

}
