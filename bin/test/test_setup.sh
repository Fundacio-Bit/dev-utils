#!/usr/bin/env bash

#### Description: Checks Java and Maven version
#### Usage: ./test_setup.sh

#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2026-06-26: Update LIB_PATH to bin/lib

###################################
###   Test setup values         ###
###################################

set -o nounset
set -o errexit

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] testing setup..."
echo ""

LIB_PATH=$PROJECT_PATH/bin/lib

for lib in $LIB_PATH/lib*.sh; do
    source ${lib}
done

lib_env_utils.loadenv ${PROJECT_PATH}

lib_env_utils.check_os

lib_env_utils.check_docker


echo ""
echo Checking Java version
echo ""
java -version
echo ""
echo Checking Maven version
echo ""
mvn -version
echo ""
echo Checking Maven settings
mvn help:effective-settings --settings $PROJECT_PATH/builds/maven-dist/maven/conf/settings.xml
echo ""

echo ""
echo Docker username $DOCKER_CUSTOM_USERNAME
echo Docker username on install $DOCKER_CUSTOM_USERNAME_ON_INSTALL

echo ""
echo Checking Docker version
echo ""
docker version
echo ""

echo ""
echo Checking Docker Compose Version
echo ""
docker compose version
echo ""
