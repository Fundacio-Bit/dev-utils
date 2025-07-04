#!/usr/bin/env bash

#### Description: Generates SSL certificates for NGINX from a PFX keystore
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###  GENERATING CERTS FROM PFX  ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./nginx_openssl_generate.sh

    Lists alias from jks keystore

'
    exit
fi


echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing JDK..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux

export NAMECA=${NGINX_SSL_NAMECA}
export NAMECLIENT=${NGINX_SSL_NAMECLIENT}
export NAMESERVER=${NGINX_SSL_NAMESERVER}
export ALIAS=${NGINX_SSL_DST_ALIAS}
export PASS=${NGINX_KEYSTORE_PASS}
export SSL_PASS=${NGINX_SSL_PASS}

PWD=$(cat ${SSL_PASS})

export OPENSSL_CONF=${NGINX_CONF_PATH}/${NGINX_OPENSSL_CONF_FILE}
export OPENSSL_CERTS_PATH=${APP_FILES_BASE_FOLDER}/assets/ssl

DNAME=$(grep -E '^(CN|C|ST|L|O|OU|serialNumber|emailAddress)=' ${OPENSSL_CONF} | tr '\n' ',' | sed 's/,$//')

mkdir -p ${OPENSSL_CERTS_PATH}

COMMAND=${JAVA_HOME}/bin/keytool

KEYTOOL=$(command -v $COMMAND)
echo "$COMMAND at $KEYTOOL"

echo dname is ${DNAME}

touch ${OPENSSL_CERTS_PATH}/${NAMECA}.txt
touch ${OPENSSL_CERTS_PATH}/${NAMESERVER}.txt

rm ${OPENSSL_CERTS_PATH}/${NAMECA}*.*
rm ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.*

echo "Checking pfx keystore"
if [[ ! -f ${NGINX_SSL_KEYSTORE} ]]; then
    echo "Keystore ${NGINX_SSL_KEYSTORE} not found. Please check the path and try again."
    exit 1
fi

echo "generating server key"

###################################
###   VALIDAR PFX Y CLAVE PRIVADA
###################################

PFX_FILE=${NGINX_SSL_KEYSTORE}
KEY_FILE=${OPENSSL_CERTS_PATH}/${NAMESERVER}.key
CERT_FILE=${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt
PFX_PASS=${PWD}

echo "🔐 Validando archivo .pfx en $PFX_FILE..."

if [ ! -f "$PFX_FILE" ]; then
    echo "❌ ERROR: No se encontró el archivo .pfx: $PFX_FILE"
    exit 1
fi

# Extraer clave privada sin cifrar (sobrescribe si ya existe)
openssl pkcs12 -in "$PFX_FILE" -nocerts -nodes -out "$KEY_FILE" -passin pass:"$PFX_PASS" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la extracción de la clave privada del .pfx"
    exit 2
fi

# Validar que la clave privada es usable
openssl rsa -in "$KEY_FILE" -check -noout > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ERROR: La clave privada extraída no es válida o está cifrada."
    exit 3
fi

echo "✅ Clave privada válida."

# Extraer certificado
openssl pkcs12 -in "$PFX_FILE" -clcerts -nokeys -out "$CERT_FILE" -passin pass:"$PFX_PASS" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la extracción del certificado del .pfx"
    exit 4
else
    echo "✅ Certificado exportado a $CERT_FILE"
fi


# (Opcional) Validar que el certificado y la clave coinciden
if [ -f "$CERT_FILE" ]; then
    CERT_MOD=$(openssl x509 -noout -modulus -in "$CERT_FILE" | openssl md5)
    KEY_MOD=$(openssl rsa  -noout -modulus -in "$KEY_FILE"  | openssl md5)
    if [ "$CERT_MOD" != "$KEY_MOD" ]; then
        echo "❌ ERROR: El certificado y la clave privada no coinciden."
        exit 4
    else
        echo "✅ Certificado y clave coinciden."
    fi
else
    echo "⚠️ Aviso: No se encontró $CERT_FILE, se omite validación cruzada con certificado."
fi




# openssl genrsa -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key 4096

# echo "generating server csr"
# openssl req -new -config ${OPENSSL_CONF} -key ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr

# echo "extracting pem and key from NGINX_SSL_KEYSTORE.p12"

# openssl pkcs12 -in ${NGINX_SSL_KEYSTORE} -nodes -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -passin pass:${PWD}
# openssl pkcs12 -in ${NGINX_SSL_KEYSTORE} -nocerts -nodes -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key -passin pass:${PWD}

# echo "generating server crt"
# openssl x509 -req -CA ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -CAkey ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr  -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -days 1000 -CAcreateserial

# echo "generating server pem"
# openssl x509 -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -inform PEM -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.pem -outform PEM
# cat ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key >> ${OPENSSL_CERTS_PATH}/${NAMESERVER}.pem


# echo "generating jks"
# $KEYTOOL -genkeypair -alias ${ALIAS} -keyalg RSA -keysize 4096 -dname "${DNAME}" -validity 1000 -keypass ${PASS} -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -storepass ${PASS} -storetype JKS -noprompt
# echo "changing alias password"
# $KEYTOOL -keypasswd -alias ${ALIAS} -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -storepass ${PASS} -keypass ${PASS} -new ${PASS} -noprompt
# $KEYTOOL -importkeystore -srckeystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -destkeystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.pfx -srcstoretype JKS -deststoretype pkcs12 -srcstorepass ${PASS} -deststorepass ${PASS} -noprompt

# echo "importing certificates to jks"
# $KEYTOOL -importcert -noprompt -alias ${ALIAS} -keypass ${PASS} -file ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS}

# mv ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.jks ${APP_FILES_BASE_FOLDER}/firma
# mv ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.pfx ${APP_FILES_BASE_FOLDER}/firma

chmod 755 ${OPENSSL_CERTS_PATH}/*
