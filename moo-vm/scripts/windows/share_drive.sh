#!/bin/bash

# Stop the script if something goes wrong
set -e

# SHARE_DRIVE_STATUS="drive.ready"
# SHARE_DRIVE_TARGET_SIZE="214748364800"

# Creates a copy of the additionalDrive in the $ROOT_FOLDER_SHARED_DRIVE of WSL2
function install_share_drive() {

  log_info "Looking for the share drive"
  mkdir -p ${ROOT_FOLDER_SHARED_DRIVE}

  if [ ! -f "${ROOT_FOLDER_SHARED_DRIVE_FILE}" ]; then
    log_warn "The share drive is missing, importing it as ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
    cp "$WORKSPACE_DIR/moo-vm/additionalDrive/$SHARED_DRIVE_FILE" "$ROOT_FOLDER_SHARED_DRIVE"
  fi

  log_info "The share drive is located in: ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
}

# Format the share drive as ext4
function format_share_drive() {
  local PARTITION=$1

  log_info "Waiting for the kernel to detect the partition"
  sleep 1

  log_info "Formatting the partition"
  run_as_root "mkfs.ext4 -F $PARTITION"
}

# Mount the share drive in the specified folder in common.sh
function mount_share_drive() {

  log_info "Checking mountig point"
  local DETECTED_MOUNTPOINTS=$(run_as_root "lsblk -b -o MOUNTPOINTS $DEVICE | grep ${ROOT_FOLDER_SHARED}")

  if [ ! -z "$DETECTED_MOUNTPOINTS" ]; then
    log_info "The share drive is mounted in $MOUNTED_FOLDER"

    return 0
  fi

  log_info "Creating mounting point"
  run_as_root "mkdir -p $MOUNTED_FOLDER"

  local PARTITION=$1

  log_info "Mounting partition"
  run_as_root "mount $PARTITION $MOUNTED_FOLDER"

  log_info "Changing the property of the mount point to $VM_USER"
  run_as_root "chown $VM_USER:$VM_USER $MOUNTED_FOLDER"

  log_info "Checking assembly"
  run_as_moo "df -h | grep $MOUNTED_FOLDER || echo \"Warning: does not appear in df -h\""

  log_info "Adding entry a /etc/fstab"
  FSTAB_LINE="$PARTITION   $MOUNTED_FOLDER   ext4   defaults   0   0"

  if ! grep -q "$PARTITION" /etc/fstab; then
      run_as_moo "echo \"$FSTAB_LINE\" | sudo tee -a /etc/fstab > /dev/null"
      log_info "Entry added."
  else
      log_info "Entry already existed"
  fi

  log_info "The share drive has been successfully mounted on: $MOUNTED_FOLDER"
}

# Initialize the share drive by adding a primary partition to it
function partition_share_drive() {
  local DEVICE=$1

  log_info "The share drive was detected in $DEVICE"
  log_info "Checking if the share drive already has partitions"

  local DETECTED_PARTITION=$(run_as_root "lsblk -b -o TYPE $DEVICE | grep part")

  if [ ! -z "$DETECTED_PARTITION" ]; then
    log_info "A partition was detected in ${DEVICE}1"
    mount_share_drive "${DEVICE}1"

    return 0
  fi

  log_info "No partitions were found, creating partition via sfdisk"
  run_as_root "echo \",,L\" | sudo sfdisk \"$DEVICE\""

  format_share_drive "${DEVICE}1"
  mount_share_drive "${DEVICE}1"
}

# Find the share drive route in moo-ubuntu
function lookup_share_drive() {
  local ACTION=$1

  log_info "Detecting the share drive in moo-ubuntu"
  local DISK=$(run_as_root "lsblk -b -o NAME,SIZE | grep ${SHARE_DRIVE_TARGET_SIZE} | cut -d ' ' -f1")

  if [ -z "$DISK" ]; then

    if [ ! -z $ACTION ]; then
      log_warn "The shared drive mounted on WSL was not found"

      # Mount the share drive on the VM
      attach_share_drive

      # Now that the shar drive is mounted, let's verify that it's the correct one
      lookup_share_drive

      return 0
    fi

    log_error "ERROR: No disk of size was found $SHARE_DRIVE_TARGET_SIZE in bytes"

    return 0
  fi

  partition_share_drive "/dev/$DISK"
}

# Mount the share drive every time the VM runs
function attach_share_drive() {

  log_info "Checking the status of the share drive"

  # log_warn "The share drive is not yet initialized"
  wsl.exe --mount --vhd "${ROOT_FOLDER_SHARED_DRIVE_FILE}" --bare
}

function share_drive_setup() {
  # Copy the additional drive to the folder
  install_share_drive

  # Find the partition and try to mount it
  lookup_share_drive "attach"

}