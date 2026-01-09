{ config, lib, pkgs, ... }:

{
  # AMD GPU drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
  };

  # AMD P-State driver for better power efficiency
  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.sg_display=0"  # Fix for display issues on some Framework configs
  ];

  # Firmware updates
  services.fwupd.enable = true;

  # Framework-specific kernel module for better hardware support
  boot.extraModulePackages = with config.boot.kernelPackages; [
    framework-laptop-kmod
  ];

  # Load framework_laptop module
  boot.kernelModules = [ "framework_laptop" ];

  # Better touchpad support
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = true;
    };
  };

  # Ambient light sensor
  hardware.sensor.iio.enable = true;

  # Enable thermald for better thermal management
  services.thermald.enable = true;

  # USB autosuspend for power saving
  services.udev.extraRules = ''
    # Framework laptop keyboard
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="32ac", ATTR{idProduct}=="0012", ATTR{power/autosuspend}="1"
  '';
}
