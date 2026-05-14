#!/bin/bash

# Detener el script si algo falla
set -e 

# --- Importacion de modulos ---
source ~/init.done
source ~/$PROJECT_NAME/scripts/common.sh
source ~/$PROJECT_NAME/scripts/utils.sh
source ~/$PROJECT_NAME/scripts/tools.sh

function showMenu {
  clear
  titleName "Local Development Environment - Interactive Menu"
  print_banner
  titleName "Menu interactivo"
  echo ""
  echo "  1) Inicia todos los servicios"
  echo "  2) Detiene todos los servicios"
  echo ""
  echo "  3) Lista los SQS queues"
  echo ""
  echo "  4) Consultar a un usuario en especifico por samAccountName"
  echo "  5) Lista todos los LDAP users"
  echo "  6) Lista todos los LDAP groups"
  echo "  7) Lista todos los LDAP roles"
  echo "  8) Lista todos los LDAP scopes"
  echo "  9) Muestra el memberOf de un usuario en especifico"
  echo ""
  echo "  0) Salir del menu"
  echo ""
  echo "------------------------------------------------------------"
}

function executeMake() {
  ACTION=$1

  make -C "$ROOT_FOLDER_PROJECT/dockers" $ACTION
}

function queryLdapUser {
  echo ""
  read -p "Enter samAccountName to search: " uid
  if [ -z "$uid" ]; then
    echo "samAccountName no puede ir vacio."
  else
    executeMake ldap-query-user UID=$uid
  fi
}

function queryLdapMemberof {
  echo ""
  read -p "Enter samAccountName to view memberOf: " uid
  if [ -z "$uid" ]; then
    echo "samAccountName no puede ir vacio."
  else
    executeMake ldap-memberof UID=$uid
  fi
}

function devMenu() {

  while true; do
    showMenu
    read -p "Selecciona una opcion: " choice

    case $choice in
      1) executeMake up ;;
      2) executeMake down ;;
      3) executeMake sqs-list ;;
      4) queryLdapUser ;;
      5) executeMake ldap-users ;;
      6) executeMake ldap-groups ;;
      7) executeMake ldap-roles ;;
      8) executeMake ldap-scopes ;;
      9) queryLdapMemberof ;;
      0) echo "Saliendo del Menu interactivo"; exit 10 ;;
      *) echo "Opcion invalida." ;;
    esac

    pause
  done
}

devMenu
