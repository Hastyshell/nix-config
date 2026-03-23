let
  # for security reasons, do not load neovim's user config
  # since EDITOR may be used to edit some critical files
  vimCmd = "nvim --clean";
in
{
  imports = [
    ./nix.nix
    ./font.nix
    ./pkgs.nix
  ];

  environment.variables.EDITOR = vimCmd;
  environment.shellAliases = {
    vim = vimCmd;
  };
}
