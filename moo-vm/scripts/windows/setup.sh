#!/bin/bash

# Detener el script si algo falla
set -e 

# --- Importacion de modulos ---
source ./moo-vm/scripts/windows/wsl2.sh
source ./moo-vm/scripts/windows/shareDrive.sh
source ./moo-vm/scripts/windows/installSCripts.sh

# Verifica que wsl tiene acceso a internet
function networkSetup() {
  logInfo "Verificando Mirrored Networking"
  
  # Intentamos hacer un curl al localhost de Windows desde dentro de WSL
  if $(runAsMoo "curl -s --connect-timeout 3 google.com > /dev/null"); then
    logSuccess "WSL tiene salida a internet."

    return 0
  fi

  logError "WSL no tiene salida a internet. Revisa el modo mirrored o tu Firewall"
  exit 0
}

# Hace la configuracion necesaria para el VM_USER
function userSetup() {
    logInfo "Configurando usuario '$VM_USER' en ${PROJECT_NAME}"

    # 1. Verificamos si el usuario ya existe para evitar el error "already exists"
    if $(runAsRoot "id "$VM_USER" >/dev/null 2>&1"); then
        logSuccess "El usuario '$VM_USER' ya existe."

        return 0
    fi

    logInfo "Creando el usuario '$VM_USER' dentro de la distro"
    runAsRoot "useradd -m -G sudo -s //bin//bash $VM_USER"

    # Usamos // para la ruta del archivo de sudoers
    logInfo "Configurando sudoers (NOPASSWD) para '$VM_USER'"
    runAsRoot "echo '$VM_USER ALL=(ALL) NOPASSWD:ALL' > //etc//sudoers.d//$VM_USER"

    # Usamos printf para asegurar que el formato sea correcto y // para la ruta
    logInfo "Configurando auto-login en //etc//wsl.conf"
    runAsRoot "printf '[user]\ndefault=$VM_USER\n' > //etc//wsl.conf"

    # Limpiamos posibles retornos de carro de Windows (\r) para que Linux no se queje
    runAsRoot "sed -i 's/\r$//' //etc//wsl.conf"

    logInfo "Habilitando Systemd en Ubuntu para el demonio de Docker"
    runAsRoot "printf '[boot]\nsystemd=true\n' >> //etc//wsl.conf"

    logSuccess "Usuario y auto-login configurados correctamente."
}

# funcion para instalar todo lo necesario para Windows
function windowsInstall() {
  logInfo "Configurando entorno de Windows"

  # Vamos a verificar si WSL 2 esta instalado en windows
  wsl2Setup

  # Vamos a configurar un usuario para ubunto.
  userSetup

  # Vamos a verificar si hay comunicacion entre windows y wsl
  networkSetup

  # Vinculamos el moo-shared.vhdx para persistir informacion en caso de reinstalar o actualizar la vm.
  shareDriveSetup

  # Instalando de scripts
  installScripts

  # Instalando de dockers

  # Apagamos la WSL 2 para evitar que corra en modo root.
  wsl2Shutdown

  logSuccess "Instalacion de ${PROJECT_NAME} en WSL2 con exito"
}

function windowsRun() {
  logInfo "Ejecutando WSL 2 entorno para windows"

  # Monta el share drive cada vez que se ejecuta la VM
  shareDriveSetup

  installScripts

  # Arranca ${PROJECT_NAME} en WSL 2 para windows.
  wsl2Run

}

function windowsShutdown() {
  logInfo "Apagando entorno de WSL 2 para windows"

  wsl2Shutdown
}