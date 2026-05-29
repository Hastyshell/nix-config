{
  flake.homeModules = {
    default = import ./common;
    linux = {
      desktop = import ./linux/desktop;
      # server = import ./linux/server;
    };
    darwin = {
      desktop = import ./darwin/desktop;
    };
  };
}
