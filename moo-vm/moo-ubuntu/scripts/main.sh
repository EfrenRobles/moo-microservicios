#!/bin/bash

# Detener el script si algo falla
set -e 

source ~/init.done
source ~/$PROJECT_NAME/scripts/common.sh
source ~/$PROJECT_NAME/scripts/utils.sh
source ~/$PROJECT_NAME/scripts/tools.sh

function main() {
  verifyIfSystemIsReady

  installTools
}

# Ejecutamos la funcion principal
main
cd ~/$PROJECT_NAME/dockers