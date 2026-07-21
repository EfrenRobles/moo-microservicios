#!/bin/bash

# Stop the script if something goes wrong
set -e

PROJECT_NAME="moo-ubuntu"

# --- Importing modules ---
source ./moo-vm/$PROJECT_NAME/scripts/common.sh

# Global variables for installation only.
WORKSPACE_DIR=$(echo "$PWD" 2>/dev/null | tr -d '\0')
SHARED_DRIVE_FILE="mooShared.vhdx"

ROOT_FOLDER="/b/WSL"
ROOT_FOLDER_PROJECT=$ROOT_FOLDER"/$PROJECT_NAME"
ROOT_FOLDER_SHARED_DRIVE="$ROOT_FOLDER/$ROOT_FOLDER_SHARED"
ROOT_FOLDER_SHARED_DRIVE_FILE="$ROOT_FOLDER/$ROOT_FOLDER_SHARED/$SHARED_DRIVE_FILE"

# We define the moo-vm's username
VM_USER="moo"

