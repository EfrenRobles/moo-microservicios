#!/bin/bash

# Stop the script if something goes wrong
set -e

# --- Importing modules ---
source ./moo-vm/scripts/windows/setup.sh
# todo: Develoop for Linux and Mac

# source ./moo-vm/scripts/windows/dockers.sh

function check_env() {
  local action=$1

  # Detecting the current OS
  case "$OSTYPE" in
    msys*|win32*)
      log_info "Windows detected"
      os="windows"
      ;;
    linux-gnu*)
      log_info "Linux detected"
      os="linux"
      ;;
    darwin*)
      log_info "MacOS detected"
      os="mac"
      ;;
    *)
      log_error "Error: OS not supported"
      return 1
      ;;
  esac

  local fn="${os}${action}"

  if declare -f "$fn" >/dev/null; then
    $fn
  else
    log_error "Method not implemented: $fn"
  fi

  log_success "--- Configuratin completed successfully ---"
}