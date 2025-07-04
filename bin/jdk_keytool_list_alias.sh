#!/usr/bin/env bash

#### Description: Lists alias from jks keystore and validates private key access
#### Updated by: gdeignacio - 2025-06-30

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./jdk_keytool_list.sh [-keystore=name] [-alias=name] [-keypass=pass]'
    exit
fi

PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
isLinux=$(lib_env_utils.check_os)
echo $isLinux

KEYSTORE_FOLDER=$APP_FILES_BASE_FOLDER/firma
mkdir -p "$KEYSTORE_FOLDER"
echo "Keystore folder at $KEYSTORE_FOLDER"

COMMAND=keytool
KEYTOOL=$(command -v $COMMAND)
echo "$COMMAND at $KEYTOOL"

# Defaults
KEYSTORE=""
ALIAS=""
KEYPASS=""

# Parse args
for i in "$@"; do
    case $i in
        -keystore=*)
        KEYSTORE="${i#*=}"
        shift
        ;;
        -alias=*)
        ALIAS="${i#*=}"
        shift
        ;;
        -keypass=*)
        KEYPASS="${i#*=}"
        shift
        ;;
        *)
        ;;
    esac
done

# Set default keystore if not passed
if [[ -z "$KEYSTORE" ]]; then
    KEYSTORE="${APP_PROJECT_NAME}.jks"
fi
KEYSTORE_PATH="$KEYSTORE_FOLDER/$KEYSTORE"

# List aliases
echo ""
echo "🔍 Listing aliases in keystore: $KEYSTORE_PATH"
$KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -storepass "${NGINX_KEYSTORE_PASS}" | grep 'Alias name' | awk '{print $3}' | sort -u

# If alias is passed, validate it
if [[ -n "$ALIAS" ]]; then
    echo ""
    echo "🔐 Checking alias '$ALIAS'..."
    if ! $KEYTOOL -list -keystore "$KEYSTORE_PATH" -storepass "${NGINX_KEYSTORE_PASS}" | grep -q "$ALIAS"; then
        echo "❌ Alias '$ALIAS' not found in keystore."
        exit 2
    else
        echo "✅ Alias '$ALIAS' exists."
    fi

    if [[ -n "$KEYPASS" ]]; then
        echo "🔐 Validating key password..."
        if $KEYTOOL -keypasswd -alias "$ALIAS" -keystore "$KEYSTORE_PATH" -storepass "${NGINX_KEYSTORE_PASS}" -keypass "$KEYPASS" -new "$KEYPASS" > /dev/null 2>&1; then
            echo "✅ Password for alias '$ALIAS' is valid."
        else
            echo "❌ ERROR: Password for alias '$ALIAS' is incorrect or alias is not a private key."
            exit 3
        fi
    else
        echo "ℹ️ No key password provided. Skipping password validation."
    fi
fi
