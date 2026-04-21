#!/bin/bash
# Moo CLI - Abstracción de infraestructura

set -e # Detener el script si algo falla

# --- Importación de módulos ---
[[ -f "./moo-vm/setup/utils.sh" ]] && source ./moo-vm/setup/utils.sh
[[ -f "./moo-vm/setup/dockers.sh" ]] && source ./moo-vm/setup/dockers.sh

# --- MENÚ PRINCIPAL ---

function show_menu {
  clear
  title_name "  MOO STACK CLI - Java / Spring Boot"

  echo ""
  echo "  1) Instala la VM"
  echo "  2) Enciende la VM"
  echo "  3) apaga la VM"
  echo ""
  echo "  0) Exit"
  echo ""
  echo "------------------------------------------------------------"
}

while true; do
  show_menu
  read -p "Choose an option: " choice

  case $choice in
    1) setup_env ;;
    2) echo build_project ;;
    3) echo clean_project ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac 

  pause
done
