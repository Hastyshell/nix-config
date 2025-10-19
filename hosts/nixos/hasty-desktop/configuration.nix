# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    # only boot systems in /boot
    # switch from grub to systemd-boot
    # https://discourse.nixos.org/t/switch-from-grub-to-systemd-boot/65158/3
    systemd-boot = {
      enable = true;
      configurationLimit = 6;
    };

    # grub can boot windows on another disk, but does not support secure boot
    # grub = {
    #   enable = true;
    #   devices = [ "nodev" ];
    #   efiSupport = true;
    #   useOSProber = true;
    # };
  };

  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu
  boot.kernelParams = [
    "video=3840x2160"
    "usbcore.autosuspend=-1"
  ];

  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  networking.proxy.default = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  virtualisation.vmware.guest.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hastyshell = {
    isNormalUser = true;
    description = "hastyshell";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking = {
    useDHCP = false;
    firewall.enable = false;

    interfaces.wlp9s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.108";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "192.168.0.1";
    nameservers = [
      "192.168.0.1"
      "8.8.8.8"
      "1.1.1.1"
    ];
  };
}
