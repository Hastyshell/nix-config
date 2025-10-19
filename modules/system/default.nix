{
  flake = {
    nixosModules = {
      default = {
        imports = [
          ./nixos
          ./share
        ];
      };
      desktop = import ./nixos/desktop;
    };
    # darwinModules = import ./darwin // import ./share;
  };
}
