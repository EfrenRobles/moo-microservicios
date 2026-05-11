#!/bin/bash

# Detener el script si algo falla
set -e

# --- Importacion de modulos ---
source ./moo-vm/scripts/windows/setup.sh
# todo: hacer desarrollo para linux y mac.

# source ./moo-vm/scripts/windows/dockers.sh

function checkEnv() {
  local action=$1

  # Detectamos el sistema operativo actual
  case "$OSTYPE" in
    msys*|win32*)
      logInfo "Detectado: Windows"
      os="windows"
      ;;
    linux-gnu*)
      logInfo "Detectado: Linux"
      os="linux"
      ;;
    darwin*)
      logInfo "Detectado: macOS"
      os="mac"
      ;;
    *)
      logError "Error: Sistema operativo no soportado."
      return 1
      ;;
  esac

  local fn="${os}${action}"

  if declare -f "$fn" >/dev/null; then
    $fn
  else
    LoglogError "Funcion no implementada: $fn"
  fi

  # Una vez que el OS está listo, instalamos las herramientas comunes 
  # installDocker

  logSuccess "--- Configuración finalizada con éxito ---"
}