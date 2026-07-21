#!/bin/bash

# Stop the script if something goes wrong
set -e 

# To print messages on screen
function log_dev() {
    echo -e "[TODO] $1";
}

function log_info() {
    echo -e "[INFO] $1";
}

function log_warn() {
    echo -e "[WARN] $1";
}

function log_success() {
    echo -e "[SUCCESS] $1";
}

function log_error() {
    echo -e "[ERROR] $1";
}

function title_name {
  echo ""
  echo "------------------------------------------------------------"
  echo -e "$1"
  echo "------------------------------------------------------------"
}

function pause {
  echo ""
  read -p "Press ENTER to continue" dummy
}

# Executes commands depending on the user type
# Use: run_as "user" "command"
run_as() {
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

# Executes commands as Root
# Uso: run_as_root "command"
run_as_root() {
  run_as "root" "$1";
}

# Executes commands as $VM_MOO
# Uso: run_as_moo "command"
run_as_moo()  {
  run_as "moo" "$1";
}

# Print the menus banner
# Source: https://patorjk.com/software/taag/#p=display&f=Lil+Devil&t=Moo&x=none&v=4&h=4&w=80&we=false
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