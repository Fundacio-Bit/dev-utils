#!/usr/bin/env bash

#### Description: Creates custom elytron configuration files for Wildfly
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   SETUP UTILS               ###
###################################

set -o errexit
set -o nounset
set -o pipefail


if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./jboss_elytronsetup.sh


'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Setting .template files..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

$PROJECT_PATH/bin/mvn_compile_module.sh $PROJECT_PATH/builds/wildfly-dist/wildfly/source/elytronkeycloakbridge/pom.xml
cp $PROJECT_PATH/builds/wildfly-dist/wildfly/source/elytronkeycloakbridge/target/KeycloakAuthServletExtension.jar $PROJECT_PATH/builds/wildfly-dist/wildfly/modules/org/fundaciobit/elytronkeycloakbridge/main/

echo ""

