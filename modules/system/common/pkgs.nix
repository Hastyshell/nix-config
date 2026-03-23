{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    gnumake
    git
    findutils

    # nix helper
    nh

    # disk
    duf # Disk Usage/Free Utility - a better 'df' alternative
    ncdu # analyzer your disk usage Interactively, via TUI(replacement of `du`)

    # networking
    wget
    curl
    mtr # A network diagnostic tool(traceroute)
    dnsutils # `dig` + `nslookup`
    doggo # DNS client for humans
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    iperf3 # network performance test
    tcpdump # network sniffer
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # security
    libargon2
    openssl

    # misc
    file
    which
    tealdeer # a very fast version of tldr
    hyperfine # command-line benchmarking tool
  ];
}
