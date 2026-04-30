#!/bin/bash

# Detener el script si algo falla
set -e

# Variables globales solo para la instalacion.
WORKSPACE_DIR=$(echo "$PWD" 2>/dev/null | tr -d '\0')

ROOT_FOLDER="/b/WSL"
ROOT_FOLDER_SHARED="moo-shared"

PROJECT_NAME="moo-ubuntu"
ROOT_FOLDER_PROJECT=$ROOT_FOLDER"/$PROJECT_NAME"

SHARED_DRIVE_FILE="mooShared.vhdx"
ROOT_FOLDER_SHARED_DRIVE="$ROOT_FOLDER/$ROOT_FOLDER_SHARED"
ROOT_FOLDER_SHARED_DRIVE_FILE="$ROOT_FOLDER/$ROOT_FOLDER_SHARED/$SHARED_DRIVE_FILE"

# Definimos el nombre del usuario para el entorno moo-vm
VM_USER="moo"
