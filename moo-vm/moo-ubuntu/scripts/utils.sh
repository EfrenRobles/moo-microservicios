#!/bin/bash

# Detener el script si algo falla
set -e 

# Para imprimir mensajes en pantall
function logDev() {
    echo -e "[TODO] $1";
}

function logInfo() {
    echo -e "[INFO] $1";
}

function logWarn() {
    echo -e "[WARN] $1";
}

function logSuccess() {
    echo -e "[SUCCESS] $1";
}

function logError() {
    echo -e "[ERROR] $1";
}

# Print helper
function titleName {
  echo ""
  echo "------------------------------------------------------------"
  echo -e "$1"
  echo "------------------------------------------------------------"
}

function pause {
  echo ""
  read -p "Press ENTER to continue..." dummy
}

# Ejecuta comandos dependiendo el tipo de usuario, dependiendo del OS
# Uso: runAs "user" "comando"
runAs() {
  local USER="$1"
  local CMD="$2"

  case "$OSTYPE" in
    msys*|win32*)
      wsl.exe -d "$PROJECT_NAME" -u "$USER" sh -c "$CMD"
      ;;
    linux-gnu*|darwin*)
      if [ "$USER" = "root" ]; then
        sudo sh -c "$CMD"
      else
        sh -c "$CMD"
      fi
      ;;
  esac
}

# Ejecuta comandos como root dependiendo del OS
# Uso: runAsRoot "comando"
runAsRoot() {
  runAs "root" "$1";
}

# Ejecuta comandos como moo dependiendo del OS
# Uso: runAsMoo "comando"
runAsMoo()  {
  runAs "moo"  "$1";
}