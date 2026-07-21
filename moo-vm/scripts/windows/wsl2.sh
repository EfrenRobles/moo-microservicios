#!/bin/bash

# Stop the script if something goes wrong
set -e 

# Setting global constants for WSL
WSL_LINUX_IMAGE_URL="https://cloud-images.ubuntu.com/wsl/releases/24.04/current/"
WSL_LINUX_IMAGE_FILE="ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz"
WSL_IMPORT_FILE="$ROOT_FOLDER/$WSL_LINUX_IMAGE_FILE"
WSL_CONFIG_PATH="$USERPROFILE/.wslconfig"
WSL_SOURCE_CONFIG="moo-vm/scripts/windows/.wslconfig"

# To download and import the Linux image.
function install_moo_ubuntu() {

  log_info "Downloading the Linux image"
  mkdir -p ${ROOT_FOLDER}

  if [ -f "$WSL_IMPORT_FILE" ]; then
    log_info "Linux distribution file found in: $WSL_IMPORT_FILE"
  else
    log_warn "Downloading the Linux image $WSL_IMPORT_FILE"
    curl -L "${WSL_LINUX_IMAGE_URL}/${WSL_LINUX_IMAGE_FILE}" -o "${WSL_IMPORT_FILE}"
  fi

  if [ $? -eq 0 ]; then
    log_success "The Linux distro downloaded successfully"
    wsl --import $PROJECT_NAME $ROOT_FOLDER_PROJECT $WSL_IMPORT_FILE

  else
    log_error "Error downloading Linux distro"
    return 1
  fi
}

# Method to verify if WSL 2 is installed.
moo_ubuntu_setup() {
  # with 2>&1 force the text output on the screen to be stored in the variable and
  # with | tr -d '\0' avoid extra messages like screen residue
  local installed_count=$(wsl.exe -l -v 2>/dev/null | tr -d '\0' | grep -cE "${PROJECT_NAME}")

  # Verify if PROJECT_NAME is installed
  if [ "$installed_count" -eq 0 ]; then
    log_warn "Not detected ${PROJECT_NAME}"

    install_moo_ubuntu
    log_info "${PROJECT_NAME} has been successfully installed"

    return 0
  fi

  log_info "${PROJECT_NAME} is already installed"
}

# In Git Bash it is accessed as /c/Users/<user name> or via $USERPROFILE
function wslconfig_setup() {

  # Verify if the source file exists before copying
  if [ -f "$WSL_SOURCE_CONFIG" ]; then
      log_info "Copying settings from $WSL_SOURCE_CONFIG..."
      cp "$WSL_SOURCE_CONFIG" "$WSL_CONFIG_PATH"
      log_success "The file .wslconfig has been successfully copied."
  else
      log_error "Error: The source file was not found in $WSL_SOURCE_CONFIG"
      return 1
  fi
}

# Verify that WSL2 is installed on Windows
function wsl2_setup() {

  if ! command -v wsl.exe &> /dev/null; then
    log_error "WSL is not installed on the system"
    return 1
  fi

  log_info "Updating the settings file in Windows"
  wslconfig_setup

  log_info "Check if there are Linux distro installed on WSL"
  moo_ubuntu_setup
}

# Run WSL2 in terminal mode
function wsl2_run() {

  log_info "Entering ${PROJECT_NAME} via WSL2, please wait"
  wsl.exe -d ${PROJECT_NAME}
}

# Safely shutdown WSL2
function wsl2_shutdown() {
  wsl --shutdown
}