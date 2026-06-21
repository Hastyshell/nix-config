{
  flake.homeModules = {
    default = import ./common;
    desktop = import ./desktop;
    linux = {
      desktop = import ./linux/desktop;
      # server = import ./linux/server;
    };
    darwin = {
      desktop = import ./darwin/desktop;
    };
  };
}
