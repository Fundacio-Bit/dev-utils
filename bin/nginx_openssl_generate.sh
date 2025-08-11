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

export NAMECA=${NGINX_SSL_NAMECA}
export NAMECLIENT=${NGINX_SSL_NAMECLIENT}
export NAMESERVER=${NGINX_SSL_NAMESERVER}
export ALIAS=${NGINX_SSL_DST_ALIAS}
export PASS=${NGINX_KEYSTORE_PASS}
export SSL_PASS=${NGINX_SSL_PASS}

PWD=$(cat ${SSL_PASS})

export OPENSSL_CONF=${NGINX_CONF_PATH}/${NGINX_OPENSSL_CONF_FILE}
export OPENSSL_CERTS_PATH=${APP_FILES_BASE_FOLDER}/assets/ssl
export OPENSSL_CACERTS_PATH=${APP_FILES_BASE_FOLDER}/assets/sslcacerts

# Extraer DNAME de openssl.conf
DNAME=$(grep -E '^(CN|C|ST|L|O|OU|serialNumber|emailAddress)=' ${OPENSSL_CONF} | tr '\n' ',' | sed 's/,$//')
SUBJ=$(grep -E '^(CN|C|ST|L|O|OU|serialNumber|emailAddress)=' "${OPENSSL_CONF}" | sed 's/^/\//' | paste -sd '' -)


mkdir -p ${OPENSSL_CERTS_PATH}
mkdir -p ${OPENSSL_CACERTS_PATH}

COMMAND=${JAVA_HOME}/bin/keytool

KEYTOOL=$(command -v $COMMAND)
echo "$COMMAND at $KEYTOOL"

echo dname is ${DNAME}
echo subj is ${SUBJ}

touch ${OPENSSL_CERTS_PATH}/${NAMECA}.txt
touch ${OPENSSL_CERTS_PATH}/${NAMESERVER}.txt
touch ${OPENSSL_CACERTS_PATH}/${NAMESERVER}.txt

rm ${OPENSSL_CERTS_PATH}/${NAMECA}*.*
rm ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.*
rm ${OPENSSL_CACERTS_PATH}/${NAMESERVER}*.*

echo "generating ca key ${NAMECA}ca.key"
openssl genrsa -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key 4096

echo "generating ca pem ${NAMECA}ca.pem"
openssl req -x509 -new -nodes -key ${OPENSSL_CERTS_PATH}/${NAMECA}ca.key -sha256 -days 3650 -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem \
  -subj "${SUBJ}"


echo "generating server key ${NAMESERVER}.key"
openssl genrsa -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key 4096

echo "generating server csr ${NAMESERVER}.csr"
openssl req -new -config ${OPENSSL_CONF} -key ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr

echo "=== Firmando certificado ${NAMESERVER}.crt con CA ==="
openssl x509 -req \
  -in "${OPENSSL_CERTS_PATH}/${NAMESERVER}.csr" \
  -CA "${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem" \
  -CAkey "${OPENSSL_CERTS_PATH}/${NAMECA}ca.key" \
  -CAcreateserial \
  -out "${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt" \
  -days 1000 -sha256


echo "generating p12 ${NAMESERVER}.p12 for elytron"
openssl pkcs12 -export -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -inkey ${OPENSSL_CERTS_PATH}/${NAMESERVER}.key -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -name ${ALIAS} -passout pass:${PASS} -CAfile ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -caname ${NAMECA}ca

# openssl pkcs12 -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -passin pass:${PASS} -nodes -nokeys | openssl x509 -noout -subject

echo "=== Generando certificado PEM  ${NAMESERVER}.pem (para Nginx u otros) ==="
cat "${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt" > "${OPENSSL_CERTS_PATH}/${NAMESERVER}.pem"
cat "${OPENSSL_CERTS_PATH}/${NAMESERVER}.key" >> "${OPENSSL_CERTS_PATH}/${NAMESERVER}.pem"

echo "=== Generando trusttore  ${NAMESERVER}trust.jks (para Wildfly) ==="
$KEYTOOL -import -trustcacerts -alias ${NAMECA}ca -file ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS} -noprompt
$KEYTOOL -import -trustcacerts -alias ${ALIAS} -file ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS} -noprompt


# echo "generating jks"
# $KEYTOOL -genkeypair -alias ${ALIAS} -keyalg RSA -keysize 4096 -dname "${DNAME}" -validity 1000 -keypass ${PASS} -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -storepass ${PASS} -storetype JKS -noprompt
# echo "changing alias password"
# $KEYTOOL -keypasswd -alias ${ALIAS} -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -storepass ${PASS} -keypass ${PASS} -new ${PASS} -noprompt

#echo "exporting jks to p12"
#$KEYTOOL -importkeystore -srckeystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.jks -destkeystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -srcstoretype JKS -deststoretype pkcs12 -srcstorepass ${PASS} -deststorepass ${PASS} -noprompt

# echo "extracting wildfly crt from p12"
# openssl pkcs12 -legacy -in ${OPENSSL_CERTS_PATH}/${NAMESERVER}.p12 -clcerts -nokeys -out ${OPENSSL_CERTS_PATH}/${NAMESERVER}-wildfly.crt -passin pass:${PASS}


# echo "importing certificates to jks"
# $KEYTOOL -importcert -noprompt -alias ${ALIAS}-nginx -keypass ${PASS} -file ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS}
# $KEYTOOL -importcert -noprompt -alias ${ALIAS}-wildfly -keypass ${PASS} -file ${OPENSSL_CERTS_PATH}/${NAMESERVER}-wildfly.crt -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS}

# # Importar el certificado de la CA en el almacén de confianza de Java
# echo "importing CA certificate into JKS"
# $KEYTOOL -import -trustcacerts -alias ${NAMECA} -file ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -keystore ${OPENSSL_CERTS_PATH}/${NAMESERVER}trust.jks -storepass ${PASS} -noprompt

# echo "importing CA certificate into trust store"
# openssl pkcs12 -in ${NGINX_SSL_KEYSTORE} -clcerts -nokeys -out ${OPENSSL_CERTS_PATH}/${NAMECA}ca.pem -passin pass:${PWD}


#mv ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.jks ${APP_FILES_BASE_FOLDER}/firma
#mv ${OPENSSL_CERTS_PATH}/${NAMESERVER}*.p12 ${APP_FILES_BASE_FOLDER}/firma

cp ${OPENSSL_CERTS_PATH}/${NAMESERVER}.crt ${OPENSSL_CACERTS_PATH}/${NAMESERVER}.crt

chmod 755 ${OPENSSL_CERTS_PATH}/*
chmod 755 ${OPENSSL_CACERTS_PATH}/*

chmod 755 ${APP_FILES_BASE_FOLDER}/firma/*
