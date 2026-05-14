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

function titleName {
  echo ""
  echo "------------------------------------------------------------"
  echo -e "$1"
  echo "------------------------------------------------------------"
}

function pause {
  echo ""
  read -p "Preciona la tecla ENTER para continuar..." dummy
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
      local SUDO=""

      if [ "$USER" = "root" ]; then
        SUDO="sudo"
      fi

      $SUDO sh -c "$CMD"
      ;;
  esac
}

# Ejecuta comandos como root dependiendo del OS
# Uso: runAsRoot "comando"
runAsRoot() {
  runAs "root" "$1";
}

# Ejecuta comandos como $VM_MOO dependiendo del OS
# Uso: runAsMoo "comando"
runAsMoo()  {
  runAs "moo"  "$1";
}


# Imprime el banner en el menu
# Fuente: https://patorjk.com/software/taag/#p=display&f=Lil+Devil&t=Moo&x=none&v=4&h=4&w=80&we=false
function print_banner() {
cat << 'EOF'
           <-. (`-')
              \(OO )_      .->        .->
            ,--./  ,-.)(`-')----. (`-')----.
            |   `.'   |( OO).-.  '( OO).-.  '
            |  |'.'|  |( _) | |  |( _) | |  |
            |  |   |  | \|  |)|  | \|  |)|  |
            |  |   |  |  '  '-'  '  '  '-'  '
            `--'   `--'   `-----'    `-----'
EOF
}