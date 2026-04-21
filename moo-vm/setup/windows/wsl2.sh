#!/bin/bash

# Detener el script si algo falla
set -e 

# Definimos variables con las configuraciones necesarias
WSL_LINUX_IMAGE_URL="https://cloud-images.ubuntu.com/wsl/releases/24.04/current/"
WSL_LINUX_IMAGE_FILE="ubuntu-noble-wsl-amd64-24.04lts.rootfs.tar.gz"
WSL_ROOT_FOLDER="/b/WSL"
WSL_PROJECT_NAME="moo-ubuntu"
WSL_IMPORT_FILE="$WSL_ROOT_FOLDER/$WSL_LINUX_IMAGE_FILE"
WSL_ROOT_FOLDER_PROJECT=$WSL_ROOT_FOLDER"/$WSL_PROJECT_NAME"
WSL_CONFIG_PATH="$USERPROFILE/.wslconfig"
SOURCE_CONFIG="moo-vm/setup/windows/.wslconfig"

# Funcion para descargar e importar la imagen de linux
function install_wsl_linux() {

  log_info "Descargando la imagen de Linux"
  mkdir -p ${WSL_ROOT_FOLDER}

  if [ -f "$WSL_IMPORT_FILE" ]; then
    log_info "Archivo de la distribucion de linux encontrado en: $WSL_IMPORT_FILE"
  else
    log_warn "Descargando la imagen de linux $WSL_IMPORT_FILE"
    curl -L "${WSL_LINUX_IMAGE_URL}/${WSL_LINUX_IMAGE_FILE}" -o "${WSL_IMPORT_FILE}"
  fi

  if [ $? -eq 0 ]; then
    log_success "La distro de linux se bajo con exito."
    wsl --import $WSL_PROJECT_NAME $WSL_ROOT_FOLDER_PROJECT $WSL_IMPORT_FILE

  else
    log_error "Error al descargar la distro de Linux"
    return 1
  fi
}

# Funcion para verificar si WSL2 esta instalado
check_wsl2_status() {
  # con 2>&1 fuerza que la salida del texto en pantalla se guarde en la variable y
  # | tr -d '\0' evita mensaje extras como residuos en pantalla.
  local installed_count=$(wsl.exe -l -v 2>/dev/null | tr -d '\0' | grep -cE "Running|Stopped")

  # Verifica si WSL esta instalado
  if [ "$installed_count" -eq 0 ]; then
    log_warn "No distribuciones de linux han sido detectadas"
    # wsl --install -d ubuntu24.04 --no-launch

    install_wsl_linux
    log_info "WSL ha sido instalado con exito"

    return 0
  fi

  log_info "WSL ya se encuentra instalado"
}

# En Git Bash se accede como /c/Users/<Nombre usuario> o mediante $USERPROFILE
function verify_wsl2_config() {

  # 1. Definir la ruta del archivo .wslconfig en Windows
  log_info "Verificando existencia de $WSL_CONFIG_PATH..."

  # 2. Comprobar si el archivo NO existe
  if [ -f "$WSL_CONFIG_PATH" ]; then
    log_info "El archivo .wslconfig ya existe."

    return 0
  fi

  log_info "El archivo .wslconfig no existe en el perfil de usuario."

  # Verificar si el archivo origen existe antes de copiar
  if [ -f "$SOURCE_CONFIG" ]; then
      log_info "Copiando configuración desde $SOURCE_CONFIG..."
      cp "$SOURCE_CONFIG" "$WSL_CONFIG_PATH"
      log_success "Archivo .wslconfig copiado exitosamente."
  else
      log_error "Error: No se encontró el archivo de origen en $SOURCE_CONFIG"
      return 1
  fi

}

# Verifica que WSL 2 este instalado en windows.
function verify_wsl2_status() {
  if ! command -v wsl.exe &> /dev/null; then
    log_error "WSL no está instalado en este sistema."
    return 1
  fi

  log_info "Verificando si el archivo de configuracion esta instalado en Windows"
  verify_wsl2_config

  log_info "Verificar si hay distribuciones de linux instaladas en wsl"
  check_wsl2_status
}
