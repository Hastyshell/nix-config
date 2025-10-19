{
  services.openssh = {
    enable = true;
    settings = {
      UseDns = false;
      # PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  # Add terminfo database of all known terminals to the system profile.
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;
}
