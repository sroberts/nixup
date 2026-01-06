#!/usr/bin/env bash
# Hardware detection and configuration module for nixup installer
# Includes Framework laptop support

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# shellcheck source=../lib/logging.sh
source "${LIB_DIR}/logging.sh"
# shellcheck source=../lib/utils.sh
source "${LIB_DIR}/utils.sh"

# Hardware configuration variables
export CPU_VENDOR=""
export GPU_VENDOR=""
export IS_LAPTOP=false
export IS_FRAMEWORK=false
export HAS_FINGERPRINT=false
export HAS_BLUETOOTH=true

# Detect system hardware
detect_system() {
    log_info "Detecting system hardware..."

    CPU_VENDOR=$(get_cpu_vendor)
    GPU_VENDOR=$(get_gpu_vendor)

    log_info "CPU vendor: $CPU_VENDOR"
    log_info "GPU vendor: $GPU_VENDOR"

    # Detect laptop
    if [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]; then
        IS_LAPTOP=true
        log_info "System type: Laptop"
    else
        log_info "System type: Desktop"
    fi

    # Detect Framework laptop
    if is_framework; then
        IS_FRAMEWORK=true
        log_info "Framework laptop detected!"
    fi

    # Detect fingerprint reader
    if lsusb 2>/dev/null | grep -qi "fingerprint\|goodix\|synaptics.*finger"; then
        HAS_FINGERPRINT=true
        log_info "Fingerprint reader detected"
    fi

    # Detect Bluetooth
    if ! lsusb 2>/dev/null | grep -qi "bluetooth" && ! lspci 2>/dev/null | grep -qi "bluetooth"; then
        HAS_BLUETOOTH=false
    fi

    log_success "Hardware detection complete"
}

# Generate CPU microcode configuration
generate_cpu_config() {
    case "$CPU_VENDOR" in
        intel)
            cat << 'EOF'
  # Intel CPU
  hardware.cpu.intel.updateMicrocode = true;
EOF
            ;;
        amd)
            cat << 'EOF'
  # AMD CPU
  hardware.cpu.amd.updateMicrocode = true;
EOF
            ;;
    esac
}

# Generate GPU configuration
generate_gpu_config() {
    case "$GPU_VENDOR" in
        intel)
            cat << 'EOF'
  # Intel Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
EOF
            ;;
        amd)
            cat << 'EOF'
  # AMD Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
  };
EOF
            ;;
        nvidia)
            cat << 'EOF'
  # NVIDIA Graphics
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
EOF
            ;;
    esac
}

# Generate laptop-specific configuration
generate_laptop_config() {
    if [[ "$IS_LAPTOP" != true ]]; then
        return 0
    fi

    cat << 'EOF'
  # Laptop power management
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;

  # Better battery life
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  # Lid switch behavior
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };
EOF
}

# Generate Framework-specific configuration
generate_framework_config() {
    if [[ "$IS_FRAMEWORK" != true ]]; then
        return 0
    fi

    cat << 'EOF'
  # Framework laptop specific
  hardware.framework.enableKmod = true;

  # Framework firmware updates
  services.fwupd.enable = true;

  # Ambient light sensor
  hardware.sensor.iio.enable = true;

  # Better power management for Framework
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };
  # Disable power-profiles-daemon when using TLP
  services.power-profiles-daemon.enable = false;
EOF
}

# Generate fingerprint configuration
generate_fingerprint_config() {
    if [[ "$HAS_FINGERPRINT" != true ]]; then
        return 0
    fi

    cat << 'EOF'
  # Fingerprint reader
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
EOF
}

# Generate Bluetooth configuration
generate_bluetooth_config() {
    if [[ "$HAS_BLUETOOTH" != true ]]; then
        return 0
    fi

    cat << 'EOF'
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
EOF
}

# Generate complete hardware configuration
generate_hardware_config() {
    cat << 'EOF'
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

EOF

    generate_cpu_config
    echo ""
    generate_gpu_config
    echo ""
    generate_laptop_config
    echo ""
    generate_framework_config
    echo ""
    generate_fingerprint_config
    echo ""
    generate_bluetooth_config

    cat << 'EOF'

  # Firmware
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
}
EOF
}

# Run hardware setup
setup_hardware() {
    log_step "3" "Hardware Detection"
    detect_system
}

export -f detect_system generate_cpu_config generate_gpu_config generate_laptop_config
export -f generate_framework_config generate_fingerprint_config generate_bluetooth_config
export -f generate_hardware_config setup_hardware
