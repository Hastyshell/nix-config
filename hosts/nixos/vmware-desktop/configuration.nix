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
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # for amd cpu
  boot.kernelParams = [ "video=3840x2160" ];

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  networking.proxy.default = "http://192.168.0.145:20172";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  virtualisation.vmware.guest.enable = true;
  environment.systemPackages = [ pkgs.open-vm-tools ];
  services.xserver.videoDrivers = [ "vmware" ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hastyshell = {
    isNormalUser = true;
    description = "hastyshell";
    extraGroups = [
      "networkmanager"
      "wheel"
      "lxd"
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

    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.0.132";
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
