{
  description = "Flake containing stable system packages";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    profile = "framework";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      "laptop" = lib.nixosSystem {
        inherit system;
	        modules = [ ./profiles/${profile}/configuration.nix ];
      };
      "framework" = lib.nixosSystem {
        inherit system;
	        modules = [ ./profiles/${profile}/configuration.nix ];
      };
    };
    homeConfigurations = {
      "beauv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	      modules = [
	        ./profiles/${profile}/home.nix
	        nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
