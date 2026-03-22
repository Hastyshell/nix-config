{
  config,
  ...
}:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
