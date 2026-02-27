#!/bin/bash
set -e

CREDENTIAL_USER=$ADMIN_USER
CREDENTIAL_PASS=$ADMIN_PASSWORD

# Wildfly admin user credentials
./bin/add-user.sh -u ${CREDENTIAL_USER} -p ${CREDENTIAL_PASS} --silent

CERT_DIR="/opt/jboss/wildfly/standalone/configuration/sslcacerts"
KEYSTORE="$JAVA_HOME/lib/security/cacerts"
STOREPASS="changeit"

echo "Importando certificados de $CERT_DIR en el keystore Java..."

for certfile in "$CERT_DIR"/*.crt; do
  [ -e "$certfile" ] || continue  # Si no hay .crt, saltar
  aliasname=$(basename "$certfile" .crt | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  
  if keytool -list -keystore "$KEYSTORE" -storepass "$STOREPASS" -alias "$aliasname" >/dev/null 2>&1; then
    echo "El certificado '$aliasname' ya está importado, saltando..."
  else
    echo "Importando certificado '$aliasname'..."
    keytool -importcert -noprompt -alias "$aliasname" -file "$certfile" -keystore "$KEYSTORE" -storepass "$STOREPASS"
    echo "Certificado '$aliasname' importado correctamente."
  fi
done

echo "Arrancando WildFly..."
exec /opt/jboss/wildfly/bin/standalone.sh -Djavax.net.ssl.trustore=$KEYSTORE -Djavax.net.ssl.trustorepass=$STOREPASS -b 0.0.0.0 -bmanagement 0.0.0.0