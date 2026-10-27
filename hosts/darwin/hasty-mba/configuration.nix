{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  time.timeZone = "Asia/Shanghai";

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  homebrew.casks = [
    "tailscale-app"
    "baidunetdisk"
    "feishu"
    "tencent-meeting"
    "wechat"
  ];

  system.defaults.dock.persistent-apps = lib.mkAfter [
    { app = "/Applications/WeChat.app"; }
  ];
}
