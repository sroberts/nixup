{ config, lib, pkgs, ... }:

{
  # Power profiles daemon for dynamic power management
  services.power-profiles-daemon.enable = true;

  # Alternative: TLP (uncomment if you prefer TLP over power-profiles-daemon)
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #     CPU_BOOST_ON_AC = 1;
  #     CPU_BOOST_ON_BAT = 0;
  #     PLATFORM_PROFILE_ON_AC = "performance";
  #     PLATFORM_PROFILE_ON_BAT = "low-power";
  #   };
  # };

  # Hibernate support
  # Ensure swap partition/file is large enough (>= RAM size)
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    AllowHybridSleep=yes
    HibernateDelaySec=1800
  '';

  # Suspend-then-hibernate: suspend first, hibernate after 30 min
  # This preserves battery while maintaining state
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "ignore";
    powerKey = "suspend-then-hibernate";
    powerKeyLongPress = "poweroff";
  };

  # Low battery hibernate
  # Create udev rule to hibernate at critical battery level
  services.udev.extraRules = ''
    # Hibernate on critical battery (adjust percentage as needed)
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';

  # Package for power management tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
  ];

  # Auto-tune with powertop on boot (optional, can be aggressive)
  # powerManagement.powertop.enable = true;

  # Kernel parameters for better power management
  boot.kernelParams = [
    "mem_sleep_default=deep"  # Use S3 sleep by default
  ];
}
