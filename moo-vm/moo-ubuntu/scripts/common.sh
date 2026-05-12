#!/bin/bash

# Detener el script si algo falla
set -e

# Variables globales solo para la instalacion.
SHARE_DRIVE_TARGET_SIZE="214748364800"

ROOT_FOLDER_SHARED="moo-shared"
MOUNTED_FOLDER="/mnt/$ROOT_FOLDER_SHARED"

DOCKER_ENGINE="docker-engine"
WORKSPACE_NAME="moo-microservices"

WORKSPACE_DIR="$MOUNTED_FOLDER/$WORKSPACE_NAME"
DOCKER_SPACE="$MOUNTED_FOLDER/$DOCKER_ENGINE"
DOCKER_WORKSPACE_FOLDER="~/$PROJECT_NAME/dockers"
