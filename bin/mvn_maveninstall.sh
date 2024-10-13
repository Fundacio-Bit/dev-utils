#!/usr/bin/env bash

#### Description: Downloads and installs mvn binaries
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   MAVEN INSTALL UTILS         ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./mvn_maveninstall.sh

    Downloads and installs mvn binaries

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing Maven..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux


if [ -d "$MAVEN_TARGET" ]; then
    ### Take action if $DIR exists ###
    echo --------- COPIANT FITXERS AL DESTÍ $MAVEN_TARGET ---------
else
    ###  Control will jump here if dir does NOT exists ###
    echo "${MAVEN_TARGET} not found. Creating ..."
    mkdir -p $MAVEN_TARGET
fi

if [[ isLinux -eq 1 ]]; then
    MAVEN_FILE=${MAVEN_LINUX_FILE}
    MAVEN_URL=${MAVEN_BASEURL}${MAVEN_FILE}
    echo ""
    echo "Downloading" $MAVEN_URL "to" $MAVEN_TARGET
    echo ""
    wget $MAVEN_URL -P $MAVEN_TARGET
    tar -zxvf $MAVEN_TARGET/$MAVEN_FILE --directory $MAVEN_TARGET
else
    MAVEN_FILE=${MAVEN_WINDOWS_FILE}
    MAVEN_URL=${MAVEN_BASEURL}${MAVEN_FILE}
    echo ""
    echo "Downloading" $MAVEN_URL "to" $MAVEN_TARGET
    echo ""
    curl --insecure $MAVEN_URL > $MAVEN_TARGET/$MAVEN_FILE
    unzip -o $MAVEN_TARGET/$MAVEN_FILE -d $MAVEN_TARGET
fi  

rm $MAVEN_TARGET/$MAVEN_FILE

mkdir -p $M2_REPO