{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    wget
  ];
}
