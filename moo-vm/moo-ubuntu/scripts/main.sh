#!/bin/bash

# Stop the script if something goes wrong
set -e 

# --- Importing modules ---
source ~/init.done
source ~/$PROJECT_NAME/scripts/common.sh
source ~/$PROJECT_NAME/scripts/utils.sh
source ~/$PROJECT_NAME/scripts/tools.sh

function main() {

  verify_if_system_is_ready
  install_tools
  generate_docker_state_volumes
}

# To run the main function
main

source ~/$PROJECT_NAME/dockers/dev_menu.sh
