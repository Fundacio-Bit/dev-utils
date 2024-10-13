#!/usr/bin/env bash

#### Description: Build from source and deploy to github repo
#### Written by: Guillermo de Ignacio - gdeignacio on 11-2021

# Revision 2024-08-01

###################################
###   BUILD MVN UTILS           ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./mvn_deploy.sh

Build from source and deploy to github repo

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Build and deploy project..."
echo ""

# Taking values from .env file
source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}

echo off
if [[ -f help.txt ]]
then
  cat help.txt
else
  echo "help.txt no existe"
fi

# Array to compile
# POM_ARRAY=($APP_POM_FILE $SAR_POM_FILE)
POM_ARRAY=($APP_POM_FILE)
# Array to deploy
FILE_ARRAY=($APP_EAR_FILE $APP_SAR_FILE $DS_FILE)

# POM compile section
for POM in ${POM_ARRAY[*]}; do
  if [[ -f "$POM" ]]
  then
      echo "Compiling $POM"
      env mvn -f $POM -DskipTests $@ deploy \
        --settings $PROJECT_PATH/builds/maven-dist/maven/conf/settings.xml \
        --toolchains $PROJECT_PATH/builds/maven-dist/maven/conf/toolchains.xml
  fi
done
# end of POM compile section


