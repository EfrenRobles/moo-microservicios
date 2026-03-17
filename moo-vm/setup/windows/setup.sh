function verify_network() {
  log_info "Verificando Mirrored Networking..."
  
  # Intentamos hacer un curl al localhost de Windows desde dentro de WSL
  if wsl.exe -d Ubuntu-24.04 curl -s --connect-timeout 3 google.com > /dev/null; then
    log_success "WSL tiene salida a internet."
  else
      log_error "WSL no tiene salida a internet. Revisa el modo mirrored o tu Firewall"
  fi
}

function verify_user() {
    log_info "Configurando usuario '$VM_USER' en Ubuntu-24.04..."

    # 1. Verificamos si el usuario ya existe para evitar el error "already exists"
    if ! wsl.exe -d Ubuntu-24.04 -u root id "$VM_USER" >/dev/null 2>&1; then
        log_info "Creando el usuario '$VM_USER' dentro de la distro..."
        wsl.exe -d Ubuntu-24.04 -u root useradd -m -G sudo -s //bin//bash "$VM_USER"
    else
        log_success "El usuario '$VM_USER' ya existe."
    fi

    log_info "Configurando sudoers (NOPASSWD) para '$VM_USER'..."
    # Usamos // para la ruta del archivo de sudoers
    wsl.exe -d Ubuntu-24.04 -u root sh -c "echo '$VM_USER ALL=(ALL) NOPASSWD:ALL' > //etc//sudoers.d//$VM_USER"

    log_info "Configurando auto-login en //etc//wsl.conf..."
    # Usamos printf para asegurar que el formato sea correcto y // para la ruta
    wsl.exe -d Ubuntu-24.04 -u root sh -c "printf '[user]\ndefault=$VM_USER\n' > //etc//wsl.conf"

    # Limpiamos posibles retornos de carro de Windows (\r) para que Linux no se queje
    wsl.exe -d Ubuntu-24.04 -u root sed -i 's/\r$//' //etc//wsl.conf

    log_info "Habilitando Systemd en Ubuntu para el demonio de Docker..."
    wsl.exe -d Ubuntu-24.04 -u root sh -c "printf '[boot]\nsystemd=true\n' >> //etc//wsl.conf"

    log_success "Usuario y auto-login configurados correctamente."
}

function verify_wsl2_config() {
  # 1. Definir la ruta del archivo .wslconfig en Windows
  # USERPROFILE es una variable de entorno de Windows que apunta a C:\Users\Nombre
  # En Git Bash se accede como /c/Users/Nombre o mediante $USERPROFILE

  local WSL_CONFIG_PATH="$USERPROFILE/.wslconfig"
  local SOURCE_CONFIG="windows/.wslconfig"

  log_info "Verificando existencia de $WSL_CONFIG_PATH..."

  # 2. Comprobar si el archivo NO existe
  if [ ! -f "$WSL_CONFIG_PATH" ]; then
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
  else
      log_success "El archivo .wslconfig ya existe."
  fi

}

function verify_wsl2_status() {
  if ! command -v wsl.exe &> /dev/null; then
    log_error "WSL no está instalado en este sistema."

  else
        log_success "WSL detectado correctamente."

        # Verificando si el archivo de configuracion esta instalado en Windows
        verify_wsl2_config

        # Verificar si hay distros instaladas
        local installed_count=$(wsl.exe -l -v 2>/dev/null | tr -d '\0' | grep -cE "Running|Stopped")

        if [ "$installed_count" -eq 0 ]; then
             log_info "No se detectaron distribuciones de Linux. Instalando Ubuntu por defecto..."
             wsl --install -d Ubuntu-24.04 --no-launch
        fi
    fi
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