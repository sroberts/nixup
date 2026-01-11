# Framework 13 laptop hardware configuration
# Note: nixos-hardware provides base Framework configuration
# This file contains additional customizations
{ config, pkgs, lib, ... }:

{
  # Firmware updates
  services.fwupd.enable = true;

  # Ambient light sensor
  hardware.sensor.iio.enable = true;

  # AMD graphics (Framework 13 AMD Ryzen 7040)
  # Note: Intel graphics config removed as this is for AMD model
  hardware.graphics = {
    enable = true;
  };

  # Power management is configured in modules/hardware/power.nix

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # Fingerprint reader (uncomment if you have one)
  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  # security.pam.services.sudo.fprintAuth = true;
}
