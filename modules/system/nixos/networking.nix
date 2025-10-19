{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking = {
    networkmanager.enable = true;
    # Use an NTP server located in the mainland of China to synchronize the system time
    timeServers = [
      "ntp.aliyun.com" # Aliyun NTP Server
      "ntp.tencent.com" # Tencent NTP Server
    ];
  };

  programs.clash-verge = {
    enable = true;
    autoStart = true;
  };

  # =============================================================
  #
  # Tailscale - your own private network(VPN) that uses WireGuard
  #
  # It's open source and free for personal use,
  # and it's really easy to setup and use.
  # Tailscale has great client coverage for Linux, windows, Mac, android, and iOS.
  # Tailscale is more mature and stable compared to other alternatives such as netbird/netmaker.
  #
  # How to use:
  #  1. Create a Tailscale account at https://login.tailscale.com
  #  2. Login via `tailscale login`
  #  3. join into your Tailscale network via `tailscale up --accept-routes`
  #  4. If you prefer automatic connection to Tailscale, use the `authKeyFile` option` in the config below.
  #
  # Status Data:
  #   `journalctl -u tailscaled` shows tailscaled's logs
  #   logs indicate that tailscale store its data in /var/lib/tailscale
  #   which is already persistent across reboots(via preservation)
  #
  # References:
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/networking/tailscale.nix
  #
  # =============================================================

  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  # enable the tailscale service
  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # allow the Tailscale UDP port through the firewall
    openFirewall = true;

    useRoutingFeatures = "client";
    extraSetFlags = [ "--accept-routes" ];
  };

  programs.wireshark = {
    enable = true;
    # Whether to allow users in the 'wireshark' group to capture network traffic(via a setcap wrapper).
    dumpcap.enable = true;
    # Whether to allow users in the 'wireshark' group to capture USB traffic (via udev rules).
    usbmon.enable = false;
  };
}
