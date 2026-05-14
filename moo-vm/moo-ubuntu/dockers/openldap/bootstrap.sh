#!/bin/bash
set -e

echo "==============================================="
echo "   OpenLDAP AD-like Bootstrap Initialization"
echo "==============================================="

SLAPD_BIN="/usr/local/libexec/slapd"
SLAPD_CONF="/container/service/slapd/slapd.conf"
DATA_DIR="/usr/local/var/openldap-data"
LDIF_DIR="/container/service/slapd/assets/ldif"

echo "[bootstrap] Fixing permissions..."
chown -R ldap:ldap /usr/local/var

echo "[bootstrap] Preparing directories..."
mkdir -p "$DATA_DIR"
chown -R ldap:ldap "$DATA_DIR"

if [ ! -f "$DATA_DIR/data.mdb" ]; then
  echo "[bootstrap] No data.mdb found, initializing from scratch..."

  echo "[bootstrap] Starting temporary slapd..."
  # IMPORTANT: -d 0 keeps slapd in foreground so the PID is correct
  $SLAPD_BIN -u ldap -g ldap -f "$SLAPD_CONF" -h "ldap://0.0.0.0:389" -d 0 &
  SLAPD_PID=$!

  echo "[bootstrap] Waiting for slapd to accept connections on port 389..."
  until nc -z localhost 389 >/dev/null 2>&1; do
    echo "  -> waiting for slapd..."
    sleep 1
  done

  echo "[bootstrap] slapd is ready, loading initial LDIF files..."
  for f in "$LDIF_DIR"/*.ldif; do
    echo "  -> loading $f"
    ldapadd -x \
      -H ldap://localhost \
      -D "cn=admin,dc=example,dc=com" -w admin \
      -f "$f"
  done

  # ------------------------------------------------------------
  # Trigger memberOf overlay AFTER loading all LDIFs
  # ------------------------------------------------------------
  echo "[bootstrap] Triggering memberOf overlay..."

  # Buscar todos los grupos y roles (groupOfNames o group)
  GROUP_DNS=$(ldapsearch -H ldap://localhost:389 -x \
      -D "cn=admin,dc=example,dc=com" -w admin \
      -b "dc=example,dc=com" \
      "(|(objectClass=groupOfNames)(objectClass=group))" dn \
      | grep "^dn:" | cut -d' ' -f2-)

  # Para cada grupo, hacer un modify mínimo para disparar memberOf
  for DN in $GROUP_DNS; do
      echo "[bootstrap] Touching $DN"
      ldapmodify -H ldap://localhost:389 -x \
        -D "cn=admin,dc=example,dc=com" -w admin <<EOF
dn: $DN
changetype: modify
add: description
description: trigger
-
delete: description
description: trigger
EOF
  done

  echo "[bootstrap] memberOf overlay triggered successfully."

  echo "[bootstrap] Stopping temporary slapd..."
  # Do not fail if the process is already gone
  if kill "$SLAPD_PID" 2>/dev/null; then
    wait "$SLAPD_PID" 2>/dev/null || true
  else
    echo "[bootstrap] Temporary slapd was already stopped, continuing..."
  fi
else
  echo "[bootstrap] Existing database found, skipping LDIF import."
fi

echo "==============================================="
echo "   OpenLDAP AD-like ready for production"
echo "==============================================="

# IMPORTANT: Start slapd in foreground so Docker keeps the container alive
exec $SLAPD_BIN -u ldap -g ldap -f "$SLAPD_CONF" -h "ldap://0.0.0.0:389" -d 0
