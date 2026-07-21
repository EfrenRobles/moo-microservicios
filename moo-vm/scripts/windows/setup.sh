#!/bin/bash

# Stop the script if something goes wrong
set -e 

# --- Importing modules ---
source ./moo-vm/scripts/windows/wsl2.sh
source ./moo-vm/scripts/windows/share_drive.sh
source ./moo-vm/scripts/windows/install_scripts.sh

# Verify that wsl has internet access
function network_setup() {
  log_info "Verifying Mirrored Networking"
  
  # Try to curl from WSL
  if $(run_as_moo "curl -s --connect-timeout 3 google.com > /dev/null"); then
    log_success "WSL has internet"

    return 0
  fi

  log_error "WSL has not internet access. check your mirroring mode or your firewall settings"
  exit 0
}

# Generate the necessary settings for the VM_USER
function user_setup() {
    log_info "Configuring user '$VM_USER' in ${PROJECT_NAME}"

    # We check if the user already exist to avoid the error
    if $(run_as_root "id "$VM_USER" >/dev/null 2>&1"); then
        log_success "the user '$VM_USER' already exist"

        return 0
    fi

    log_info "Creating the user '$VM_USER' within the distro"
    run_as_root "useradd -m -G sudo -s //bin//bash $VM_USER"

    # We use // for the sudoers file path
    log_info "Configuring sudoers (NOPASSWD) para '$VM_USER'"
    run_as_root "echo '$VM_USER ALL=(ALL) NOPASSWD:ALL' > //etc//sudoers.d//$VM_USER"

    # We use printf to ensure the format is correct and // for the path
    log_info "Configuring auto-login in //etc//wsl.conf"
    run_as_root "printf '[user]\ndefault=$VM_USER\n' > //etc//wsl.conf"

    # We cleared up any Windows carriage returns (\r) so that Linux would not complain
    run_as_root "sed -i 's/\r$//' //etc//wsl.conf"

    log_info "Enabling Systemmd in Ubuntu for the Docker daemon"
    run_as_root "printf '[boot]\nsystemd=true\n' >> //etc//wsl.conf"

    log_success "User and auto-login configured correctly"
}

# Method to install everything necessary for Windows
function windows_install() {
  log_info "Configuring the Windows environment"

  # Let's check if WSL2 is installed on Windows
  wsl2_setup

  # Let's configure a user for Ubuntu.
  user_setup

  # We'll check if there's communication between Windows and WSL2
  network_setup

  # We linked the moo-shared.vhdx file to persist information in case of reinstalling or updating the VM
  share_drive_setup

  # Installing scripts
  install_scripts

  # We turned off WSL2 to prevent it from running in root mode
  wsl2_shutdown

  log_success "Installation of ${PROJECT_NAME} in WSL2 successfully"
}

function windows_run() {
  log_info "Running WSL2 environment for Windows"

  # Mount the share drive every time the VM runs
  share_drive_setup

  install_scripts

  # Boot ${PROJECT_NAME} in WSL2 for Windows
  wsl2_run

}

function windows_shutdown() {
  log_info "Shutting down WSL2 environment for Windows"

  wsl2_shutdown
}