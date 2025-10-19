{
  flake.homeModules = {
    default = import ./share;
    gui = {
      linux = import ./gui/linux;
      # darwin = import ./gui/darwin;
    };
  };
}
