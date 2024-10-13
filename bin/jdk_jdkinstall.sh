#!/usr/bin/env bash

#### Description: Downloads and installs jdk binaries
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

###################################
###   JDK INSTALL UTILS         ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./jdk_jdkinstall.sh

Downloads and installs jdk binaries

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at ${PROJECT_PATH}"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing JDK..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

if [ -d "$JDK_TARGET" ]; then
    ### Take action if $DIR exists ###
    echo --------- COPIANT FITXERS AL DESTÍ $JDK_TARGET ---------
else
    ###  Control will jump here if dir does NOT exists ###
    echo "${JDK_TARGET} not found. Creating ..."
    mkdir -p $JDK_TARGET
fi

isLinux=$(lib_env_utils.check_os)
# echo "Var islinux value= ${isLinux}"

if [[ isLinux -eq 1 ]]; then
    JDK_FILE=${JDK_LINUX_FILE}
    JDK_URL=${JDK_BASEURL}${JDK_FILE}
    echo ""
    echo "Downloading" $JDK_URL "to" $JDK_TARGET
    echo ""
    wget $JDK_URL -P $JDK_TARGET
    tar -zxvf $JDK_TARGET/$JDK_FILE --directory $JDK_TARGET
else
    JDK_FILE=${JDK_WINDOWS_FILE}
    JDK_URL=${JDK_BASEURL}${JDK_FILE}
    echo ""
    echo "Downloading" $JDK_URL "to" $JDK_TARGET
    echo ""
    curl $JDK_URL > $JDK_TARGET/$JDK_FILE
    unzip -o $JDK_TARGET/$JDK_FILE -d $JDK_TARGET
fi  

rm $JDK_TARGET/$JDK_FILE