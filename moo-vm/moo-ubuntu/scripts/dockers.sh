#!/bin/bash

# Detener el script si algo falla
set -e 

# Instalación universal de Docker Engine
function installDocker() {
  
  # Verificamos si docker ya es un comando ejecutable
    if runAsRoot "command -v docker" >/dev/null 2>&1; then
      logSuccess "Docker Engine ya está instalado. Saltando paso."

      return 0
    fi

    logInfo "Iniciando instalación de Docker Engine (GPL)"

    # 1. Actualizar e instalar dependencias base
    runAsRoot "apt-get update && apt-get install -y ca-certificates curl gnupg"

    # 2. Ejecutar el script oficial de Docker
    # (Nota: get.docker.com funciona en casi cualquier distro Linux/WSL)
    runAsRoot "curl -fsSL https://get.docker.com | sh"

    # 3. Configurar permisos de usuario
    runAsRoot "usermod -aG docker $USER"

    logSuccess "Docker Engine instalado correctamente."
}
