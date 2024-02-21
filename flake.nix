{
  description = "ROS Development Enviroment";

  inputs = {
    nixpkgs.url = "github:lopsided98/nixpkgs/61852b7faa8b47aad422adca0fea90fe007e9ead";
    flake-utils.url = "github:numtide/flake-utils";
    nixros.url = "github:lopsided98/nix-ros-overlay";
  };

  outputs = { self, nixpkgs, nixros, flake-utils }:
    let my-ros-distro-overlay = (final: prev: {
          pkg = prev.callPackage ./pkg.nix {}; #the pkg I want to add
        });
        my-ros-overlay = (self: super: {
          # Apply our overlay to multiple ROS distributions
          rosPackages = super.rosPackages // {
            humble = super.rosPackages.humble.overrideScope my-ros-distro-overlay;
      };
    });

    in
    with nixpkgs.lib;
    with flake-utils.lib;
    eachSystem allSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nixros.overlays.default
          my-ros-overlay
        ];
      };
    in {
      legacyPackages = pkgs.rosPackages ;

      devShells = {
      #dev shells
      };
    }) // {
  };

    nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}