# Definimos el nombre del usuario para el entorno moo-vm
VM_USER="moo"

# --- FUNCIONES ---
function log_info() {
    echo -e "[INFO] $1";
}

function log_warn() {
    echo -e "[WARN] $1";
}

function log_success() {
    echo -e "[SUCCESS] $1";
}

function log_error() {
    echo -e "[ERROR] $1";
}

# Ejecuta comandos como root dependiendo del OS
# Uso: run_as_root "comando"
run_as_root() {
    local cmd="$1"

    case "$OSTYPE" in
      msys*|win32*)
        # En Windows enviamos a la distro de moo-vm
        wsl.exe -d Ubuntu-24.04 -u root sh -c "$cmd"
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

# function build_project() {
#     local module=$1
#     if [ -z "$module" ]; then
#         log_info "Compilando el Monorepo completo..."
#         ./gradlew build -x test
#     else
#         log_info "Compilando módulo específico: $module..."
#         ./gradlew :$module:build -x test
#     fi
# }

# function clean_project() {
#     log_info "Limpiando artefactos de compilación..."
#     ./gradlew clean
# }

# function run_dev() {
#     local service=$1
#     if [ -z "$service" ]; then
#         log_error "Debes especificar un servicio (ej: ./moo dev moo-users-service)"
#         exit 1
#     fi
    
#     log_info "Iniciando $service en modo desarrollo con Debug (puerto 5005)..."

#     # Aquí es donde ocurre la magia de Java + Spring Boot
#     ./gradlew :$service:bootRun --args='--spring.profiles.active=dev'
# }

# function setup_ai_engine() {
#     log_info "Instalando motor de IA local (Ollama)..."

#     # Instalamos Ollama dentro de WSL para que DeepSeek corra con baja latencia
#     wsl -u root bash -c "curl -fsSL https://ollama.com/install.sh | sh"
    
#     log_info "Descargando modelo DeepSeek-V2 (o el más óptimo para tu RAM)..."
#     wsl bash -c "ollama pull deepseek-coder:6.7b" # Una versión balanceada para tus 4GB-8GB
# }

# function check_connectivity() {
#     log_info "Verificando puente de red Host <-> WSL (Mirrored Mode)..."
    
#     # Prueba de fuego: ¿Windows ve a la VM?
#     if ping -c 1 127.0.0.1 &> /dev/null; then
#         log_success "Conectividad Mirror confirmada."
#     else
#         log_error "Error de red. Revisa el archivo .wslconfig."
#     fi
# }

# function setup_env() {
#     log_info "Iniciando aprovisionamiento del entorno..."
    
#     if [ "$IS_WINDOWS" = true ]; then
#         log_info "Detectado Windows. Verificando WSL2..."

#         # Aseguramos que el motor de Docker esté en la distro de WSL
#         # Usamos 'ubuntu' como estándar, pero podrías parametrizarlo
#         wsl -u root bash -c "apt update && apt install -p docker.io -y && usermod -aG docker \$USER"
#         log_success "Docker Engine configurado en WSL2."
#     else
#         log_info "Detectado Unix-like. Verificando Docker/Colima..."
#         if ! command -v docker &> /dev/null; then
#             log_error "Docker no encontrado. Por favor instale Docker Engine o Colima."
#             exit 1
#         fi
#     fi

#     log_success "Entorno listo para trabajar."
# }
