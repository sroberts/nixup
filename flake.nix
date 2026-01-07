{
  description = "NixOS configuration for Framework 13 with Niri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    # Override xwayland-satellite inputs to work around Nix narHash assertion bug
    # https://github.com/NixOS/nix/issues/9303
    # Pin to exact commits that niri-flake uses, but without narHash in URL
    xwayland-satellite-stable = {
      url = "github:Supreeeme/xwayland-satellite/388d291e82ffbc73be18169d39470f340707edaa";
      flake = false;
    };
    xwayland-satellite-unstable = {
      url = "github:Supreeeme/xwayland-satellite/0dde7ca1d3a8e8c5082533d76084e2aa02bef70e";
      flake = false;
    };
    niri.inputs.xwayland-satellite-stable.follows = "xwayland-satellite-stable";
    niri.inputs.xwayland-satellite-unstable.follows = "xwayland-satellite-unstable";
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
