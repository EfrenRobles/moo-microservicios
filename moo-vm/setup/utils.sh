#!/bin/bash

# Detener el script si algo falla
set -e 

# --- FUNCIONES ---
function log_dev() {
    echo -e "[DEV] $1";
}

function log_info() {
    echo -e "[INFO] $1";
}

function log_warn() {
    echo -e "[WARN] $1";
}

function log_success() {
    echo -e "[SUCCESS] $1";
}

function log_error() {
    echo -e "[ERROR] $1";
}

# Print helper
function title_name {
  echo ""
  echo "------------------------------------------------------------"
  echo -e "$1"
  echo "------------------------------------------------------------"
}

function pause {
  echo ""
  read -p "Press ENTER to continue..." dummy
}

# Function to request elevation using PowerShell in the WSL environment
request_elevation() {
    if [ "$EUID" -ne 0 ]; then
        echo "The requested operation requires elevation."
        sudo "$0" "$@"
        exit $?
    fi

    # The rest of your script goes here...
    echo "Running with superuser privileges."
}
