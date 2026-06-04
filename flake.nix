{
  description = "Flake containing stable system packages";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-26.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, nixos-hardware, lanzaboote, ... }:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    profile = "bjvanbemmel";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      "bjvanbemmel" = lib.nixosSystem {
        inherit system;
	        modules = [
            ./profiles/${profile}/configuration.nix
          ];
      };
      "storage" = lib.nixosSystem {
        inherit system;
	        modules = [
            ./profiles/${profile}/configuration.nix
          ];
      };
      "framework" = lib.nixosSystem {
        inherit system;
	        modules = [
            ./profiles/${profile}/configuration.nix
            nixos-hardware.nixosModules.framework-13-7040-amd
            lanzaboote.nixosModules.lanzaboote
          ];
      };
      "desktop" = lib.nixosSystem {
        inherit system;
        modules = [
          ./profiles/${profile}/configuration.nix
          lanzaboote.nixosModules.lanzaboote
        ];
      };
    };
    homeConfigurations = {
      "beauv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	      modules = [
	        ./profiles/${profile}/home.nix
	        nixvim.homeModules.nixvim
        ];
      };
    };
  };
}
