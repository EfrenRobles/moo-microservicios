#!/bin/bash

# Stop the script if something goes wrong
set -e 

# Create directories for Docker's volumes.
function generate_docker_state_volumes() {

  log_info "Creating folders on docker's share folder"
  mkdir -p $DOCKER_VOLUME/postgres
  mkdir -p $DOCKER_VOLUME/localstack
  mkdir -p $DOCKER_VOLUME/rabbitmq
  mkdir -p $DOCKER_VOLUME/ldap
}

# Verify if OS is ready to install tools.
function verify_if_system_is_ready() {
  log_info "Waiting for the system to initialize (checking APT/DPKG locks)"

  # Using pgrep is safer because it does not require installing additional tools.
  # Check if any apt or dpkg processes are running
  while pgrep -x "apt|apt-get|dpkg" >/dev/null 2>&1; do
    log_info "System busy (apt/dpkg running). Retrying in 2 seconds"
    sleep 2
  done

  # Verify if the lock files are not empty, which sometimes indicates an active lock
  while [ -f /var/lib/apt/lists/lock ] && run_as_root "lsof /var/lib/apt/lists/lock" >/dev/null 2>&1; do
    log_info "The lock file is still active, please wait"
    sleep 2
  done

  log_success "The system has been successfully initialized"
}

# Docker engine universal installation
function install_tools() {

  log_info "Verify if the tools are already installed"
  if run_as_root "command -v docker" >/dev/null 2>&1; then
    log_success "The tools are already installed."

    return 0
  fi

  log_info "Starting the tools installation"

  # Update and install base dependnecies
  run_as_root "apt-get update && apt-get install -y ca-certificates curl gnupg htop make"

  # Run the official docker script
  # (Note: get.docker.com works on almost any Linux/WSL distro)
  log_info "Installing dockers"
  run_as_root "curl -fsSL https://get.docker.com | sh"

  log_info "Configurando permisos y socket temporal"
  log_info "Setting permissions and temporal sockets"
  run_as_root "usermod -aG docker $USER"

  # Temporary fix to avoid permission issues because the system undoes upon restart.
  run_as_root "chmod 666 /var/run/docker.sock"

  log_success "The tools have been installaed correctly"
}
