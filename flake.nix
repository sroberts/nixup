{
  description = "NixOS configuration for Framework 13 with Niri";

  inputs = {
    # Use git+https to avoid GitHub tarball regeneration issues (NixOS/nix#9303)
    # The github: scheme fetches tarballs which can be regenerated with different hashes
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-24.11";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    niri.url = "github:sodiboo/niri-flake";
    # Note: We intentionally do NOT override xwayland-satellite inputs.
    # Using `follows` to override these inputs causes narHash assertion failures
    # due to GitHub tarball regeneration (NixOS/nix#9303). Let niri-flake use
    # its own properly locked inputs instead.
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, niri, ... }@inputs:
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
          # Framework laptop hardware support
          nixos-hardware.nixosModules.framework-13-7040-amd

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
