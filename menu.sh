#!/bin/bash
# Moo CLI - Abstracción de infraestructura

set -e # Detener el script si algo falla

# --- Importacion de modulos ---
source ./moo-vm/scripts/common.sh
source ./moo-vm/moo/$PROJECT_NAME/scripts/utils.sh
source ./moo-vm/scripts/install.sh

# --- MENÚ PRINCIPAL ---

function showMenu {
  clear
  titleName "  MOO STACK CLI - Java / Spring Boot"

  echo ""
  echo "  1) Instala la VM"
  echo "  2) Enciende la VM"
  echo "  3) Apaga la VM"
  echo ""
  echo "  0) Exit"
  echo ""
  echo "------------------------------------------------------------"
}

while true; do
  showMenu
  read -p "Choose an option: " choice

  case $choice in
    1) installEnv ;;
    2) logDev runEnv ;;
    3) logDev shutdownEnv ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac

  pause
done
