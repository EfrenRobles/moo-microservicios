#!/bin/bash

# Stop the script if something goes wrong
set -e 

# --- Importing modules ---
source ~/init.done
source ~/$PROJECT_NAME/scripts/common.sh
source ~/$PROJECT_NAME/scripts/utils.sh
source ~/$PROJECT_NAME/scripts/tools.sh

# --- MAIN MENU ---
function show_menu {
  clear
  title_name "Local Development Environment - Interactive Menu"
  print_banner
  title_name "Interactive Menu"
  echo ""
  echo "  1) Run containers"
  echo "  2) Stop containers"
  echo ""
  echo "  3) SQS queues list"
  echo ""
  echo "  4) Query a specific user by samAccountName"
  echo "  5) Query the LDAP users"
  echo "  6) Query the LDAP groups"
  echo "  7) Query the LDAP roles"
  echo "  8) Query the LDAP scopes"
  echo "  9) Display the memberOf of a specific user"
  echo ""
  echo "  0) Exit"
  echo ""
  echo "------------------------------------------------------------"
}

function execute_make() {
  ACTION=$1

  make -C "$ROOT_FOLDER_PROJECT/dockers" $ACTION
}

function query_ldap_user {
  echo ""
  read -p "Enter samAccountName to search: " uid
  if [ -z "$uid" ]; then
    echo "samAccountName cannot be empty."
  else
    execute_make ldap-query-user UID=$uid
  fi
}

function query_ldap_memberof {
  echo ""
  read -p "Enter samAccountName to view memberOf: " uid
  if [ -z "$uid" ]; then
    echo "samAccountName cannot be empty."
  else
    execute_make ldap-memberof UID=$uid
  fi
}

function dev_menu() {

  while true; do
    show_menu
    read -p "Choose an option: " choice

    case $choice in
      1) execute_make up ;;
      2) execute_make down ;;
      3) execute_make sqs-list ;;
      4) query_ldap_user ;;
      5) execute_make ldap-users ;;
      6) execute_make ldap-groups ;;
      7) execute_make ldap-roles ;;
      8) execute_make ldap-scopes ;;
      9) query_ldap_memberof ;;
      0) echo "Exiting..."; exit 10 ;;
      *) echo "Invalid option." ;;
    esac

    pause
  done
}

dev_menu
