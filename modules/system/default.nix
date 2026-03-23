{
  flake = {
    nixosModules = {
      default = {
        imports = [
          ./common
          ./nixos/common
        ];
      };
      desktop = import ./nixos/desktop;
    };
    # darwinModules = {
    #   default = {
    #     imports = [
    #       ./common
    #       ./darwin/common
    #     ];
    #   };
    # };
  };
}
