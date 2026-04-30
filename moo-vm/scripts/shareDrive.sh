#!/bin/bash

# Detener el script si algo falla
set -e

# Copiamos el additionalDrive en la carpeta 
function installAdditionalDrive() {

  logInfo "Buscando el disco adicional compartido"
  mkdir -p ${ROOT_FOLDER_SHARED_DRIVE}

  if [ ! -f "${ROOT_FOLDER_SHARED_DRIVE_FILE}" ]; then
    logWarn "Disco adicional esta perdido, importando disco como ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
    cp "$WORKSPACE_DIR/moo-vm/additionalDrive/$SHARED_DRIVE_FILE" "$ROOT_FOLDER_SHARED_DRIVE"
  fi

  logInfo "El disco adicional compartido se encuentra en: ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
}
