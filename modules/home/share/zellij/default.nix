{
  programs.zellij = {
    enable = true;
    extraConfig = builtins.readFile ./config.kdl;
  };
}
