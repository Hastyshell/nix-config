{ pkgs, ... }:
{
  # https://wiki.nixos.org/wiki/PipeWire
  security.rtkit.enable = true;
  # avahi required for service discovery
  services.avahi.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    #Airplay
    # opens UDP ports 6001-6002
    raopOpenFirewall = true;

    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";

            # increase the buffer size if you get dropouts/glitches
            # args = {
            #   "raop.latency.ms" = 500;
            # };
          }
        ];
      };
    };
  };
  # Disable pulseaudio, it conflicts with pipewire
  services.pulseaudio.enable = false;

  # By default Wireplumber suspends a sink after 5 seconds of no playback which can create
  # a sound pop on sensitive audio equipment, or a noticeable delay on equipment that takes
  # a moment to start back up. You can disable this by providing extra configuration to wireplumber
  # but first you need to find out the name of the problematic sink in the wireplumber namespace
  # (or blanket disable the functionality).
  # Disable suspend of Toslink output to prevent audio popping.
  services.pipewire.wireplumber.extraConfig."99-disable-suspend" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "~alsa_input.*";
          }
          {
            "node.name" = "~alsa_output.*";
          }
        ];
        actions = {
          update-props = {
            "session.suspend-timeout-seconds" = 0;
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    wiremix
    bluetui
  ];

  # https://wiki.nixos.org/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Name = "Hastyshell";
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
        ControllerMode = "dual";
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };
}
