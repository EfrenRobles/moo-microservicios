#!/bin/bash
# Moo CLI - Abstracción de infraestructura

set -e # Detener el script si algo falla

# --- Importación de módulos ---

# Usamos una validación simple para evitar errores si el archivo no existe
[[ -f "./utils.sh" ]] && source ./utils.sh
[[ -f "./windows/setup.sh" ]] && source ./windows/setup.sh
[[ -f "./linux/setup/setup.sh" ]] && source ./linux/setup/setup.sh
[[ -f "./mac/setup/setup.sh" ]] && source ./mac/setup/setup.sh

# --- MENÚ PRINCIPAL ---

case "$1" in
    setup)
        setup_env
        ;;
    build)
        build_project "$2"
        ;;
    clean)
        clean_project
        ;;
    dev)
        run_dev "$2"
        ;;
    *)
        echo "==============================================="
        echo "  MOO STACK CLI - Java / Spring Boot"
        echo "==============================================="
        echo "Uso: ./moo {comando} [argumentos]"
        echo ""
        echo "Comandos:"
        echo "  setup         Instala dependencias y prepara la VM/WSL"
        echo "  build [mod]   Compila todo o un módulo (ej: moo-users:moo-users-service)"
        echo "  clean         Borra todas las carpetas /build"
        echo "  dev [serv]    Corre un servicio en modo desarrollo local"
        echo "==============================================="
        exit 1
        ;;
esac
