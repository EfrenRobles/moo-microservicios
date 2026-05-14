#!/bin/bash

# Detener el script si algo falla
set -e 

# --- Importacion de modulos ---
source ~/init.done
source ~/$PROJECT_NAME/scripts/common.sh
source ~/$PROJECT_NAME/scripts/utils.sh
source ~/$PROJECT_NAME/scripts/tools.sh

function main() {

  verifyIfSystemIsReady
  installTools
  generateDockerStateVolumes
}

# Ejecutamos la funcion principal
main

source ~/$PROJECT_NAME/dockers/devMenu.sh
