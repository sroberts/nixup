{ config, pkgs, ... }:

{
  # User packages for container management
  home.packages = with pkgs; [
    podman-compose
    dive  # Container image explorer
    skopeo  # Container image operations
  ];

  # Podman configuration
  xdg.configFile."containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io', 'ghcr.io', 'quay.io']

    [registries.block]
    registries = []
  '';

  # Policy for pulling images
  xdg.configFile."containers/policy.json".text = builtins.toJSON {
    default = [{ type = "insecureAcceptAnything"; }];
    transports = {
      docker-daemon = {
        "" = [{ type = "insecureAcceptAnything"; }];
      };
    };
  };
}
