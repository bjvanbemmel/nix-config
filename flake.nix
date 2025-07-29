{
  description = "Flake containing stable system packages";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-25.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, nixos-hardware, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    profile = "";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      "framework" = lib.nixosSystem {
        inherit system;
	        modules = [
            ./profiles/${profile}/configuration.nix
            nixos-hardware.nixosModules.framework-13-7040-amd
          ];
      };
      "desktop" = lib.nixosSystem {
        inherit system;
        modules = [
          ./profiles/${profile}/configuration.nix
        ];
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
