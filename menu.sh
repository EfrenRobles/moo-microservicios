#!/bin/bash
# Moo CLI - Infrastructure absrraction

# Stop the script if something goes wrong
set -e

# --- Importing modules ---
source ./moo-vm/scripts/common.sh
source ./moo-vm/$PROJECT_NAME/scripts/utils.sh
source ./moo-vm/scripts/check_env.sh

# --- MAIN MENU ---

function show_menu {
  clear
  title_name "Local Development Environment - Interactive Menu"
  print_banner
  title_name "Interactive Menu"
  echo ""
  echo "  1) VM install"
  echo "  2) VM turn on"
  echo "  3) VM shutdown"
  echo ""
  echo "  0) Exit"
  echo ""
  echo "------------------------------------------------------------"
}

while true; do
  show_menu
  read -p "Choose an option: " choice

  case $choice in
    1) check_env _install;;
    2) check_env _run ;;
    3) check_env _shutdown ;;
    0) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid option." ;;
  esac

  pause
done
