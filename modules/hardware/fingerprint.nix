{ config, lib, pkgs, ... }:

{
  # Enable fprintd
  services.fprintd.enable = true;

  # PAM configuration for fingerprint
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    polkit-1.fprintAuth = true;
    # greetd uses PAM, enable fingerprint there too
    greetd.fprintAuth = true;
  };

  # Note: After installation, enroll fingerprints with:
  #   fprintd-enroll
  # 
  # To list enrolled fingerprints:
  #   fprintd-list $USER
  #
  # To verify enrollment:
  #   fprintd-verify
}
