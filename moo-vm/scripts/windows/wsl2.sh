#!/bin/bash

# Detener el script si algo falla
set -e 

# Definimos variables con las configuraciones necesarias
WSL_LINUX_IMAGE_URL="https://cloud-images.ubuntu.com/wsl/releases/24.04/current/"
WSL_LINUX_IMAGE_FILE="ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz"
WSL_IMPORT_FILE="$ROOT_FOLDER/$WSL_LINUX_IMAGE_FILE"
WSL_CONFIG_PATH="$USERPROFILE/.wslconfig"
WSL_SOURCE_CONFIG="moo-vm/scripts/windows/.wslconfig"

# Funcion para descargar e importar la imagen de linux
function installMooUbuntu() {

  logInfo "Descargando la imagen de Linux"
  mkdir -p ${ROOT_FOLDER}

  if [ -f "$WSL_IMPORT_FILE" ]; then
    logInfo "Archivo de la distribucion de linux encontrado en: $WSL_IMPORT_FILE"
  else
    logWarn "Descargando la imagen de linux $WSL_IMPORT_FILE"
    curl -L "${WSL_LINUX_IMAGE_URL}/${WSL_LINUX_IMAGE_FILE}" -o "${WSL_IMPORT_FILE}"
  fi

  if [ $? -eq 0 ]; then
    logSuccess "La distro de linux se bajo con exito."
    wsl --import $PROJECT_NAME $ROOT_FOLDER_PROJECT $WSL_IMPORT_FILE

  else
    logError "Error al descargar la distro de Linux"
    return 1
  fi
}

# Funcion para verificar si WSL2 esta instalado
mooUbuntuSetup() {
  # con 2>&1 fuerza que la salida del texto en pantalla se guarde en la variable y
  # | tr -d '\0' evita mensaje extras como residuos en pantalla.
  local installed_count=$(wsl.exe -l -v 2>/dev/null | tr -d '\0' | grep -cE "${PROJECT_NAME}")

  # Verifica si PROJECT_NAME esta instalado
  if [ "$installed_count" -eq 0 ]; then
    logWarn "No se ha detectado ${PROJECT_NAME}"

    installMooUbuntu
    logInfo "${PROJECT_NAME} ha sido instalado con exito"

    return 0
  fi

  logInfo "${PROJECT_NAME} ya se encuentra instalado"
}

# En Git Bash se accede como /c/Users/<Nombre usuario> o mediante $USERPROFILE
function wslconfigSetup() {

  # Verificar si el archivo origen existe antes de copiar
  if [ -f "$WSL_SOURCE_CONFIG" ]; then
      logInfo "Copiando configuración desde $WSL_SOURCE_CONFIG..."
      cp "$WSL_SOURCE_CONFIG" "$WSL_CONFIG_PATH"
      logSuccess "Archivo .wslconfig se a copiado exitosamente."
  else
      logError "Error: No se encontró el archivo de origen en $WSL_SOURCE_CONFIG"
      return 1
  fi
}

# Verifica que WSL 2 este instalado en windows.
function wsl2Setup() {

  if ! command -v wsl.exe &> /dev/null; then
    logError "WSL no está instalado en este sistema."
    return 1
  fi

  logInfo "Actualizando el archivo de configuracion en Windows"
  wslconfigSetup

  logInfo "Verificar si hay distribuciones de linux instaladas en wsl"
  mooUbuntuSetup
}

# Arranca wsl en modo terminal
function wsl2Run() {
  logInfo "Entrando a ${PROJECT_NAME} via WSL 2, por favor espere"
  wsl.exe -d ${PROJECT_NAME}
}

# Apaga la WSL 2 de forma segura
function wsl2Shutdown() {
  wsl --shutdown
}