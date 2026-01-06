{
  description = "NixOS configuration for Framework 13 with Niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, niri, ... }@inputs:
  let
    # Load local configuration
    local = import ./hosts/framework/local.nix;
  in
  {
    nixosConfigurations = {
      # Default Framework 13 configuration
      # Usage: nixos-install --flake .#framework
      # Or: nixos-rebuild switch --flake .#framework
      framework = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs local; };
        modules = [
          # Niri flake module
          niri.nixosModules.niri

          # Host-specific configuration
          ./hosts/framework

          # Home Manager as NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs local; };
            };
          }
        ];
      };
    };
  };
}
