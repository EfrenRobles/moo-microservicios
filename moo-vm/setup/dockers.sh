#!/bin/bash

# Detener el script si algo falla
set -e 

# --- Importación de módulos ---
[[ -f "./moo-vm/setup/windows/setup.sh" ]] && source ./moo-vm/setup/windows/setup.sh
# [[ -f "./linux/setup/setup.sh" ]] && source ./linux/setup/setup.sh
# [[ -f "./mac/setup/setup.sh" ]] && source ./mac/setup/setup.sh

# Definimos el nombre del usuario para el entorno moo-vm
VM_USER="moo"

# Ejecuta comandos como root dependiendo del OS
# Uso: run_as_root "comando"
run_as_root() {
    local cmd="$1"

    case "$OSTYPE" in
      msys*|win32*)
        # En Windows enviamos a la distro de moo-vm
        wsl.exe -d ${WSL_PROJECT_NAME} -u root sh -c "$cmd"
        ;;
      linux-gnu*|darwin*)
        # En Linux o Mac usamos sudo local
        sudo sh -c "$cmd"
        ;;
    esac
}

# Instalación universal de Docker Engine
install_docker_engine() {
  
  # Verificamos si docker ya es un comando ejecutable
    if run_as_root "command -v docker" >/dev/null 2>&1; then
      log_success "Docker Engine ya está instalado. Saltando paso."

      return 0
    fi

    log_info "Iniciando instalación de Docker Engine (GPL)..."

    # 1. Actualizar e instalar dependencias base
    run_as_root "apt-get update && apt-get install -y ca-certificates curl gnupg"

    # 2. Ejecutar el script oficial de Docker
    # (Nota: get.docker.com funciona en casi cualquier distro Linux/WSL)
    run_as_root "curl -fsSL https://get.docker.com | sh"

    # 3. Configurar permisos de usuario
    case "$OSTYPE" in
      msys*|win32*)
        run_as_root "usermod -aG docker $VM_USER"
        ;;
      linux-gnu*|darwin*)
        run_as_root "usermod -aG docker $USER"
        ;;
    esac
    
    log_success "Docker Engine instalado correctamente."
}

setup_env() {
    log_info "--- Iniciando configuración global de moo-vm ---"

    # Detectamos el sistema operativo actual
    case "$OSTYPE" in
        msys*|win32*)
            log_info "Detectado: Windows"
            setup_env_windows
            ;;
        linux-gnu*)
            log_info "Detectado: Linux"
            log_success setup_env_linux
            ;;
        darwin*)
            log_info "Detectado: macOS"
            log_success setup_env_mac
            ;;
        *)
            log_error "Error: Sistema operativo no soportado."
            return 1
            ;;
    esac

    # Una vez que el OS está listo, instalamos las herramientas comunes 
    install_docker_engine

    log_success "--- Configuración finalizada con éxito ---"
}