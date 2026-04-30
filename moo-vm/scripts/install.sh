#!/bin/bash

# Detener el script si algo falla
set -e

# --- Importacion de modulos ---
source ./moo-vm/scripts/windows/setup.sh
# todo: hacer desarrollo para linux y mac.

source ./moo-vm/scripts/shareDrive.sh
# source ./moo-vm/scripts/windows/dockers.sh

installEnv() {
    logInfo "--- Iniciando configuración global de moo-vm ---"

    # Detectamos el sistema operativo actual
    case "$OSTYPE" in
        msys*|win32*)
            logInfo "Detectado: Windows"
            installEnvWin
            ;;
        linux-gnu*)
            logInfo "Detectado: Linux"
            logDev installEnvLin
            ;;
        darwin*)
            logInfo "Detectado: macOS"
            logDev installEnvMac
            ;;
        *)
            logError "Error: Sistema operativo no soportado."
            return 1
            ;;
    esac

    # Vinculamos el moo-shared.vhdx para persistir informacion en caso de reinstalar o actualizar la vm.
    installAdditionalDrive

    # Una vez que el OS está listo, instalamos las herramientas comunes 
    # installDocker

    logSuccess "--- Configuración finalizada con éxito ---"
}