#!/usr/bin/env bash

#### Description: Lists alias from jks keystore
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   KEYTOOL LIST              ###
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

echo "[$(date +"%Y-%m-%d %T")] Generating SSL certificates..."

export NAMECA=${NGINX_SSL_NAMECA}
export NAMECLIENT=${NGINX_SSL_NAMECLIENT}
export NAMESERVER=${NGINX_SSL_NAMESERVER}
export ALIAS=${NGINX_SSL_DST_ALIAS}
export PASS=${NGINX_KEYSTORE_PASS}
export SSL_PASS=${NGINX_SSL_PASS}

PWD=$(cat ${SSL_PASS})

export OPENSSL_CONF=${NGINX_CONF_PATH}/${NGINX_OPENSSL_CONF_FILE}
export OPENSSL_CERTS_PATH=${APP_FILES_BASE_FOLDER}/assets/ssl

# Extraer DNAME de openssl.conf
echo "[$(date +"%Y-%m-%d %T")] Extracting DNAME from openssl.conf..."
#DNAME=$(grep -E '^(CN|C|ST|L|O|OU|serialNumber|emailAddress)=' ${OPENSSL_CONF} | tr '\n' ',' | sed 's/,$//')
DNAME=$(awk '/\[ req_distinguished_name \]/,/^\[.*\]/{if($1 ~ /^(CN|C|ST|L|O|OU|serialNumber|emailAddress)$/) print $1"="$2}' ${OPENSSL_CONF} | tr '\n' ',' | sed 's/,$//')

mkdir -p ${OPENSSL_CERTS_PATH}

COMMAND=${JAVA_HOME}/bin/keytool

KEYTOOL=$(command -v $COMMAND)
echo "$COMMAND at $KEYTOOL"

echo dname is ${DNAME}

touch ${OPENSSL_CERTS_PATH}/${NAMECA}.txt
touch ${OPENSSL_CERTS_PATH}/${NAMESERVER}.txt

rm ${OPENSSL_CERTS_PATH}/${NAMECA}*.*
rm ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.*

echo Cleaning up old certificates...

# Generate server key
echo "generating server key"
openssl genpkey -algorithm RSA -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -pkeyopt rsa_keygen_bits:2048

# Create a certificate signing request (CSR)
echo "generating server csr"
openssl req -new -key ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr -config ${OPENSSL_CONF} # -subj "${DNAME}"

openssl pkcs12 -in ${NGINX_SSL_KEYSTORE} -nocerts -nodes -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key -passin pass:${PWD}
openssl pkcs12 -in ${NGINX_SSL_KEYSTORE} -nokeys -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.crt -passin pass:${PWD}
# Sign the CSR with the CA key to create the server certificate
echo "signing server certificate"
openssl x509 -req -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr -CA ${OPENSSL_CERTS_PATH}/${NAMECA}ca.crt -CAkey ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key -CAcreateserial -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -days 365 -sha256 -extfile ${OPENSSL_CONF} -extensions v3_req -passin pass:${PWD}

# Generate server jks
echo "generating server p12"
openssl pkcs12 -export -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -inkey ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -name ${NAMESERVER} -CAfile ${OPENSSL_CERTS_PATH}/${NAMECA}ca.crt -caname ${NAMECA} -passin pass:${PWD} -passout pass:${PWD}

echo "getting info from p12"
openssl pkcs12 -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -info -noout -passin pass:${PWD}

echo "importing certificates to jks"
$KEYTOOL -importcert -noprompt -alias ${ALIAS} -keypass ${PASS} -file ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -storepass ${PASS}

cp ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks

mv ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.jks ${APP_FILES_BASE_FOLDER}/firma

$KEYTOOL -list -v -keystore ${APP_FILES_BASE_FOLDER}/firma/${NAMESERVER}.jks -storepass ${PASS}


chmod 755 ${OPENSSL_CERTS_PATH}/*


