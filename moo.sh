#!/bin/bash
# Moo CLI - Abstracción de infraestructura

set -e # Detener el script si algo falla

case "$1" in
    "setup")
        echo " Iniciando configuración del entorno..."
        # Aquí irá la lógica de instalación de Docker en WSL/Mac
        ;;
    "build")
        echo " Compilando monorepo..."
        ./gradlew build -x test
        ;;
    *)
        echo "Uso: ./moo {setup|build}"
        exit 1
        ;;
esac