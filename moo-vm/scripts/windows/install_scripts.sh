#!/bin/bash

# Stop the script if something goes wrong
set -e

# Adding main script as autorun
function set_init_script() {

  log_info "Checking the status of the scripts"
  if [ ! -z $(run_as_moo "ls ~/ | grep done" ) ]; then

    return 0
  fi

  log_info "Adding main script as autorun"
  run_as_moo "echo '~/$PROJECT_NAME/scripts/main.sh' >> ~/.bashrc"

  log_info "Adding a lock file to prevent the script from running multiple times"
  run_as_moo "echo \"PROJECT_NAME=$PROJECT_NAME\">~/init.done"

}

# Copy the scripts from moo-vm/scripts ito moo-ubuntu in $SCRIPTS_FOLDER
function install_scripts() {

  # Make a copy of moo-vm/moo-utunbu in ~/
  log_info "Installed scripts in $SCRIPTS_FOLDER inside $PROJECT_NAME"
  run_as_moo "cp -R \"/mnt${WORKSPACE_DIR}/moo-vm/$PROJECT_NAME\" ~/"

  set_init_script

}