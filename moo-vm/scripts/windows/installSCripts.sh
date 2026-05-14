#!/bin/bash

# Detener el script si algo falla
set -e

# Agregando script principal como autorun
function setInitScript() {

  logInfo "Verificando el estado de los scripts"
  if [ ! -z $(runAsMoo "ls ~/ | grep done" ) ]; then

    return 0
  fi

  logInfo "Agregando script principal como autorun"
  runAsMoo "echo '~/$PROJECT_NAME/scripts/main.sh' >> ~/.bashrc"

  logInfo "Agregando archivo de bloqueo, para evitar que el script se ejecute varias veces"
  runAsMoo "echo \"PROJECT_NAME=$PROJECT_NAME\">~/init.done"

}

# Copia los scripts de moo-vm/scripts dentro de moo-ubunto en $SCRIPTS_FOLDER
function installScripts() {

  # Hace una copia de moo-vm/moo-ubunto en ~/
  logInfo "Instalado scripts en $SCRIPTS_FOLDER dentro de $PROJECT_NAME"
  runAsMoo "cp -R \"/mnt${WORKSPACE_DIR}/moo-vm/$PROJECT_NAME\" ~/"

  setInitScript

}