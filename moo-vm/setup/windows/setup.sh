#!/bin/bash

# Detener el script si algo falla
set -e 

# --- Importación de módulos ---
[[ -f "./moo-vm/setup/windows/wsl2.sh" ]] && source ./moo-vm/setup/windows/wsl2.sh

function verify_network() {
  log_info "Verificando Mirrored Networking..."
  
  # Intentamos hacer un curl al localhost de Windows desde dentro de WSL
  if wsl.exe -d ${WSL_PROJECT_NAME} curl -s --connect-timeout 3 google.com > /dev/null; then
    log_success "WSL tiene salida a internet."
  else
      log_error "WSL no tiene salida a internet. Revisa el modo mirrored o tu Firewall"
  fi
}

function verify_user() {
    log_info "Configurando usuario '$VM_USER' en ${WSL_PROJECT_NAME}..."

    # 1. Verificamos si el usuario ya existe para evitar el error "already exists"
    if ! wsl.exe -d ${WSL_PROJECT_NAME} -u root id "$VM_USER" >/dev/null 2>&1; then
        log_info "Creando el usuario '$VM_USER' dentro de la distro..."
        wsl.exe -d ${WSL_PROJECT_NAME} -u root useradd -m -G sudo -s //bin//bash "$VM_USER"
    else
        log_success "El usuario '$VM_USER' ya existe."
    fi

    log_info "Configurando sudoers (NOPASSWD) para '$VM_USER'..."
    # Usamos // para la ruta del archivo de sudoers
    wsl.exe -d ${WSL_PROJECT_NAME} -u root sh -c "echo '$VM_USER ALL=(ALL) NOPASSWD:ALL' > //etc//sudoers.d//$VM_USER"

    log_info "Configurando auto-login en //etc//wsl.conf..."
    # Usamos printf para asegurar que el formato sea correcto y // para la ruta
    wsl.exe -d ${WSL_PROJECT_NAME} -u root sh -c "printf '[user]\ndefault=$VM_USER\n' > //etc//wsl.conf"

    # Limpiamos posibles retornos de carro de Windows (\r) para que Linux no se queje
    wsl.exe -d ${WSL_PROJECT_NAME} -u root sed -i 's/\r$//' //etc//wsl.conf

    log_info "Habilitando Systemd en Ubuntu para el demonio de Docker..."
    wsl.exe -d ${WSL_PROJECT_NAME} -u root sh -c "printf '[boot]\nsystemd=true\n' >> //etc//wsl.conf"

    log_success "Usuario y auto-login configurados correctamente."
}

function setup_env_windows() {
  log_info "Configurando entorno de Windows..."
  
  log_info "Detectado Windows. Verificando WSL2..."

  # Vamos a verificar si WSL 2 esta instalado en windows
  verify_wsl2_status

  # Vamos a configurar un usuario para ubunto.
  verify_user

  # Vamos a verificar si hay comunicacion entre windows y wsl
  verify_network

  # Aseguramos que el motor de Docker esté en la distro de WSL
  # Usamos 'ubuntu' como estándar, pero podrías parametrizarlo
  # wsl -u root bash -c "apt update && apt install -p docker.io -y && usermod -aG docker \$USER"

  log_success "Docker Engine configurado en WSL2."
}