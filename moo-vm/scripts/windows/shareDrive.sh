#!/bin/bash

# Detener el script si algo falla
set -e

# SHARE_DRIVE_STATUS="drive.ready"
# SHARE_DRIVE_TARGET_SIZE="214748364800"

# Genera una copia del additionalDrive en el $ROOT_FOLDER_SHARED_DRIVE de WSL 2
function installShareDrive() {

  logInfo "Buscando el share drive"
  mkdir -p ${ROOT_FOLDER_SHARED_DRIVE}

  if [ ! -f "${ROOT_FOLDER_SHARED_DRIVE_FILE}" ]; then
    logWarn "El share drive esta perdido, importandolo como ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
    cp "$WORKSPACE_DIR/moo-vm/additionalDrive/$SHARED_DRIVE_FILE" "$ROOT_FOLDER_SHARED_DRIVE"
  fi

  logInfo "El share drive se encuentra en: ${ROOT_FOLDER_SHARED_DRIVE_FILE}"
}

# Da formato al share drive como ext4
function formatShareDrive() {
  local PARTITION=$1

  logInfo "Esperando a que el kernel detecte la particion"
  sleep 1

  logInfo "Dando formato a la particion "
  runAsRoot "mkfs.ext4 -F $PARTITION"
}

# Montar el share drive en el folder especificado en common.sh
function mountShareDrive() {

  logInfo "Verificando punto de montaje"
  local DETECTED_MOUNTPOINTS=$(runAsRoot "lsblk -b -o MOUNTPOINTS $DEVICE | grep ${ROOT_FOLDER_SHARED}")

  if [ ! -z "$DETECTED_MOUNTPOINTS" ]; then
    logInfo "El share drive se encuentra montado en $MOUNTED_FOLDER"

    return 0
  fi

  logInfo "Creando punto de montaje"
  runAsRoot "mkdir -p $MOUNTED_FOLDER"

  local PARTITION=$1

  logInfo "Montando particion"
  runAsRoot "mount $PARTITION $MOUNTED_FOLDER"

  logInfo "Cambiamos la propiedad del punto de montaje para $VM_USER"
  runAsRoot "chown $VM_USER:$VM_USER $MOUNTED_FOLDER"

  logInfo "Verificando montaje"
  runAsMoo "df -h | grep $MOUNTED_FOLDER || echo \"Advertencia: no aparece en df -h\""

  logInfo "Agregando entrada a /etc/fstab"
  FSTAB_LINE="$PARTITION   $MOUNTED_FOLDER   ext4   defaults   0   0"

  if ! grep -q "$PARTITION" /etc/fstab; then
      runAsMoo "echo \"$FSTAB_LINE\" | sudo tee -a /etc/fstab > /dev/null"
      logInfo "Entrada agregada."
  else
      logInfo "Entrada ya existía."
  fi

  logInfo "El share drive a sido montado correctamente en en: $MOUNTED_FOLDER"
}

# Inicializa el share drive agregandole una particion primaria
function partitionShareDrive() {
  local DEVICE=$1

  logInfo "El share drive se detecto en $DEVICE"
  logInfo "Verificando si el share drive ya tiene particiones"

  local DETECTED_PARTITION=$(runAsRoot "lsblk -b -o TYPE $DEVICE | grep part")

  if [ ! -z "$DETECTED_PARTITION" ]; then
    logInfo "Se detecto una particion en ${DEVICE}1"
    mountShareDrive "${DEVICE}1"

    return 0
  fi

  logInfo "No se encontraron particiones, creando particion vis sfdisk"
  runAsRoot "echo \",,L\" | sudo sfdisk \"$DEVICE\""

  formatShareDrive "${DEVICE}1"
  mountShareDrive "${DEVICE}1"
}

# Busca la ruta del share drive en moo-ubuntu
function lookupShareDrive() {
  local ACTION=$1

  logInfo "Detectando el share drive in moo-ubuntu"
  local DISK=$(runAsRoot "lsblk -b -o NAME,SIZE | grep ${SHARE_DRIVE_TARGET_SIZE} | cut -d ' ' -f1")

  if [ -z "$DISK" ]; then

    if [ ! -z $ACTION ]; then
      logWarn "No se encontro el share drive montado en WSL"

      # Monta el share drive en la VM
      attachShareDrive

      # Ahora que el share drive esta montado, vamos a verificar que sea el correcto.
      lookupShareDrive

      return 0
    fi

    logError "ERROR: No se encontró un disco con tamaño $SHARE_DRIVE_TARGET_SIZE en bytes"

    return 0
  fi

  partitionShareDrive "/dev/$DISK"
}

# Monta el share drive cada vez que se ejecuta la VM
function attachShareDrive() {

  logInfo "Verificando el estado del share drive"

  # logWarn "El share drive no esta inicializado aun"
  wsl.exe --mount --vhd "${ROOT_FOLDER_SHARED_DRIVE_FILE}" --bare
}

function shareDriveSetup() {
  # Copia el additionalDrive en la carpeta
  installShareDrive

  # Busca la partition e intenta montarla
  lookupShareDrive "attach"

}