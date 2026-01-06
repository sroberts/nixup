#!/usr/bin/env bash
# User configuration module for nixup installer

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# shellcheck source=../lib/logging.sh
source "${LIB_DIR}/logging.sh"
# shellcheck source=../lib/prompts.sh
source "${LIB_DIR}/prompts.sh"
# shellcheck source=../lib/utils.sh
source "${LIB_DIR}/utils.sh"

# User configuration variables
export USERNAME=""
export USER_FULLNAME=""
export USER_PASSWORD=""
export HOSTNAME=""
export TIMEZONE=""
export LOCALE=""
export KEYBOARD_LAYOUT=""

# Configure user account
configure_user() {
    log_step "2" "User Configuration"

    # Username
    while true; do
        ask "Username" "" USERNAME
        if validate_username "$USERNAME"; then
            break
        else
            log_error "Invalid username. Must start with a letter and contain only lowercase letters, numbers, and underscores."
        fi
    done

    # Full name
    ask "Full name" "$USERNAME" USER_FULLNAME

    # Password
    ask_password_confirm "User password" USER_PASSWORD

    log_success "User account configured"
}

# Configure system hostname
configure_hostname() {
    while true; do
        ask "System hostname" "nixos" HOSTNAME
        if validate_hostname "$HOSTNAME"; then
            break
        else
            log_error "Invalid hostname. Must be 1-63 characters, alphanumeric with hyphens (not at start/end)."
        fi
    done

    log_success "Hostname set to: $HOSTNAME"
}

# Configure timezone
configure_timezone() {
    log_info "Configuring timezone..."

    # Common timezone options
    local timezones=(
        "America/New_York"
        "America/Chicago"
        "America/Denver"
        "America/Los_Angeles"
        "America/Toronto"
        "Europe/London"
        "Europe/Berlin"
        "Europe/Paris"
        "Asia/Tokyo"
        "Asia/Shanghai"
        "Australia/Sydney"
        "Other (enter manually)"
    )

    local selection
    selection=$(select_option "Select timezone" "${timezones[@]}")

    if [[ "$selection" == "Other (enter manually)" ]]; then
        ask "Enter timezone (e.g., America/New_York)" "UTC" TIMEZONE
    else
        TIMEZONE="$selection"
    fi

    log_success "Timezone set to: $TIMEZONE"
}

# Configure locale
configure_locale() {
    log_info "Configuring locale..."

    local locales=(
        "en_US.UTF-8"
        "en_GB.UTF-8"
        "de_DE.UTF-8"
        "fr_FR.UTF-8"
        "es_ES.UTF-8"
        "ja_JP.UTF-8"
        "zh_CN.UTF-8"
        "Other (enter manually)"
    )

    local selection
    selection=$(select_option "Select locale" "${locales[@]}")

    if [[ "$selection" == "Other (enter manually)" ]]; then
        ask "Enter locale (e.g., en_US.UTF-8)" "en_US.UTF-8" LOCALE
    else
        LOCALE="$selection"
    fi

    log_success "Locale set to: $LOCALE"
}

# Configure keyboard layout
configure_keyboard() {
    log_info "Configuring keyboard layout..."

    local layouts=(
        "us"
        "uk"
        "de"
        "fr"
        "es"
        "dvorak"
        "colemak"
        "Other (enter manually)"
    )

    local selection
    selection=$(select_option "Select keyboard layout" "${layouts[@]}")

    if [[ "$selection" == "Other (enter manually)" ]]; then
        ask "Enter keyboard layout" "us" KEYBOARD_LAYOUT
    else
        KEYBOARD_LAYOUT="$selection"
    fi

    log_success "Keyboard layout set to: $KEYBOARD_LAYOUT"
}

# Generate user password hash for NixOS
get_password_hash() {
    local password="$1"
    echo "$password" | mkpasswd -m sha-512 -s
}

# Generate user configuration for NixOS
generate_user_config() {
    local password_hash
    password_hash=$(get_password_hash "$USER_PASSWORD")

    cat << EOF
  # User account
  users.users.${USERNAME} = {
    isNormalUser = true;
    description = "${USER_FULLNAME}";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    hashedPassword = "${password_hash}";
  };

  # Allow wheel group to use sudo
  security.sudo.wheelNeedsPassword = true;
EOF
}

# Generate locale configuration
generate_locale_config() {
    cat << EOF
  # Localization
  time.timeZone = "${TIMEZONE}";
  i18n.defaultLocale = "${LOCALE}";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "${LOCALE}";
    LC_IDENTIFICATION = "${LOCALE}";
    LC_MEASUREMENT = "${LOCALE}";
    LC_MONETARY = "${LOCALE}";
    LC_NAME = "${LOCALE}";
    LC_NUMERIC = "${LOCALE}";
    LC_PAPER = "${LOCALE}";
    LC_TELEPHONE = "${LOCALE}";
    LC_TIME = "${LOCALE}";
  };

  # Console and keyboard
  console.keyMap = "${KEYBOARD_LAYOUT}";
EOF
}

# Run all user configuration
setup_user() {
    configure_user
    configure_hostname
    configure_timezone
    configure_locale
    configure_keyboard
}

export -f configure_user configure_hostname configure_timezone configure_locale configure_keyboard
export -f get_password_hash generate_user_config generate_locale_config setup_user
