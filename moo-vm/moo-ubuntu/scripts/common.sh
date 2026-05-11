#!/bin/bash

# Detener el script si algo falla
set -e

# Variables globales solo para la instalacion.
SHARE_DRIVE_TARGET_SIZE="214748364800"

ROOT_FOLDER_SHARED="moo-shared"
MOUNTED_FOLDER="/mnt/$ROOT_FOLDER_SHARED"

DOCKER_SPACE="docker-volumes"
WORKSPACE_NAME="moo-microservices"

WORKSPACE_DIR="$MOUNTED_FOLDER/$WORKSPACE_NAME"
DOCKER_VOLUME="$MOUNTED_FOLDER/$DOCKER_SPACE"

