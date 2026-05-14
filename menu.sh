#!/bin/bash
# Moo CLI - Abstracción de infraestructura

set -e # Detener el script si algo falla

# --- Importacion de modulos ---
source ./moo-vm/scripts/common.sh
source ./moo-vm/$PROJECT_NAME/scripts/utils.sh
source ./moo-vm/scripts/checkEnv.sh

# --- MENÚ PRINCIPAL ---

function showMenu {
  clear
  titleName "Local Development Environment - Interactive Menu"
  print_banner
  titleName "Menu interactivo"
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
    1) checkEnv Install;;
    2) checkEnv Run ;;
    3) checkEnv Shutdown ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac

  pause
done
