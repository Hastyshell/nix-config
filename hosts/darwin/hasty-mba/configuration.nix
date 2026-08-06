{ pkgs, ... }:
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
}
