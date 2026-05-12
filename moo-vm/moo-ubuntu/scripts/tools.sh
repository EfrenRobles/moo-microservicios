#!/bin/bash

# Detener el script si algo falla
set -e 

function verifyIfSystemIsReady() {
  logInfo "Esperando que el sistema se inicialice (checking APT/DPKG locks)..."
  
  # Usar pgrep es mas seguro porque no requiere la instalacion de herramientas adicionales.
  # Comprueba si algun proceso de apt o dpkg se esta ejecutando.
  while pgrep -x "apt|apt-get|dpkg" >/dev/null 2>&1; do
    logInfo "Sistema ocupado (apt/dpkg en ejecución). Reintentando en 2 segundos..."
    sleep 2
  done

  # Doble verificacion: Comprobar la existencia de archivos de bloqueo por si acaso
  # Verificamos si los archivos de bloqueo no estan vacios, lo que a veces indica un bloqueo activo.
  while [ -f /var/lib/apt/lists/lock ] && runAsRoot "lsof /var/lib/apt/lists/lock" >/dev/null 2>&1; do
    logInfo "El archivo de bloqueo aún está activo. Esperando..."
    sleep 2
  done

  logSuccess "El sistema se ha inicializado con exito"
}

# Instalación universal de Docker Engine
function installTools() {

  logInfo "Verificamos si las tools ya estan instaladas"
  if runAsRoot "command -v docker" >/dev/null 2>&1; then
    logSuccess "Las tools ya está instalado."

    return 0
  fi

  logInfo "Iniciando la instalacion de las tools"

  # Actualizar e instalar dependencias base
  runAsRoot "apt-get update && apt-get install -y ca-certificates curl gnupg htop"

  # Ejecutar el script oficial de Docker
  # (Nota: get.docker.com funciona en casi cualquier distro Linux/WSL)
  logInfo "Instalando dockers"
  runAsRoot "curl -fsSL https://get.docker.com | sh"

  logInfo "Configurando permisos y socket temporal"
  runAsRoot "usermod -aG docker $USER"

  # Temporal fix para evitar el problema con los permisos, el sistema hace undo al reiniciar.
  runAsRoot "chmod 666 /var/run/docker.sock"

  logSuccess "Las tools se han instalado correctamente."
}
