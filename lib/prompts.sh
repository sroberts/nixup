#!/usr/bin/env bash
# User prompt utilities for nixup installer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./colors.sh
source "${SCRIPT_DIR}/colors.sh"

# Ask for confirmation (yes/no)
# Returns 0 for yes, 1 for no
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"
    local response

    if [[ "${default,,}" == "y" ]]; then
        prompt="${prompt} [Y/n]: "
    else
        prompt="${prompt} [y/N]: "
    fi

    echo -en "${BOLD_YELLOW}?${RESET} ${prompt}"
    read -r response

    response="${response:-$default}"

    [[ "${response,,}" == "y" || "${response,,}" == "yes" ]]
}

# Ask for input with optional default
ask() {
    local prompt="$1"
    local default="${2:-}"
    local var_name="$3"
    local response

    if [[ -n "$default" ]]; then
        echo -en "${BOLD_CYAN}?${RESET} ${prompt} [${default}]: "
    else
        echo -en "${BOLD_CYAN}?${RESET} ${prompt}: "
    fi

    read -r response
    response="${response:-$default}"

    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$response"
    else
        echo "$response"
    fi
}

# Ask for password (hidden input)
ask_password() {
    local prompt="${1:-Password}"
    local var_name="$2"
    local password

    echo -en "${BOLD_CYAN}?${RESET} ${prompt}: "
    read -rs password
    echo

    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$password"
    else
        echo "$password"
    fi
}

# Ask for password with confirmation
ask_password_confirm() {
    local prompt="${1:-Password}"
    local var_name="$2"
    local pass1 pass2

    while true; do
        echo -en "${BOLD_CYAN}?${RESET} ${prompt}: "
        read -rs pass1
        echo

        echo -en "${BOLD_CYAN}?${RESET} Confirm ${prompt}: "
        read -rs pass2
        echo

        if [[ "$pass1" == "$pass2" ]]; then
            if [[ -n "$var_name" ]]; then
                printf -v "$var_name" '%s' "$pass1"
            else
                echo "$pass1"
            fi
            return 0
        else
            echo -e "${RED}Passwords do not match. Please try again.${RESET}"
        fi
    done
}

# Select from a list of options
# Usage: select_option "Choose an option" option1 option2 option3
select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    local selection

    echo -e "${BOLD_CYAN}?${RESET} ${prompt}"

    local i=1
    for option in "${options[@]}"; do
        echo -e "  ${CYAN}${i})${RESET} ${option}"
        ((i++))
    done

    while true; do
        echo -en "  ${YELLOW}Enter selection [1-${#options[@]}]:${RESET} "
        read -r selection

        if [[ "$selection" =~ ^[0-9]+$ ]] && \
           [[ "$selection" -ge 1 ]] && \
           [[ "$selection" -le "${#options[@]}" ]]; then
            echo "${options[$((selection-1))]}"
            return 0
        else
            echo -e "  ${RED}Invalid selection. Please enter a number between 1 and ${#options[@]}.${RESET}"
        fi
    done
}

# Wait for user to press Enter
pause() {
    local message="${1:-Press Enter to continue...}"
    echo -en "${YELLOW}${message}${RESET}"
    read -r
}
