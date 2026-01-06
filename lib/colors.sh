#!/usr/bin/env bash
# Color definitions for terminal output

# Reset
export RESET='\033[0m'

# Regular colors
export BLACK='\033[0;30m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[0;37m'

# Bold colors
export BOLD_BLACK='\033[1;30m'
export BOLD_RED='\033[1;31m'
export BOLD_GREEN='\033[1;32m'
export BOLD_YELLOW='\033[1;33m'
export BOLD_BLUE='\033[1;34m'
export BOLD_PURPLE='\033[1;35m'
export BOLD_CYAN='\033[1;36m'
export BOLD_WHITE='\033[1;37m'

# Check if colors should be disabled
if [[ ! -t 1 ]] || [[ "${NO_COLOR:-}" == "1" ]]; then
    RESET=''
    BLACK=''
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    WHITE=''
    BOLD_BLACK=''
    BOLD_RED=''
    BOLD_GREEN=''
    BOLD_YELLOW=''
    BOLD_BLUE=''
    BOLD_PURPLE=''
    BOLD_CYAN=''
    BOLD_WHITE=''
fi
