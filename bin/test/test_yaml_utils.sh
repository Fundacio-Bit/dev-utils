#!/usr/bin/env bash

#### Description: Test for yaml utils
### Usage: ./test_yaml_utils.sh
### This script is used to test the yaml utils functions.

#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2026-06-26: Update LIB_PATH to bin/lib

###################################
###   Test yaml utils           ###
###################################

set -o nounset
set -o errexit

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Testing yaml utils..."
echo ""

LIB_PATH=$PROJECT_PATH/bin/lib

for lib in $LIB_PATH/lib*.sh; do
    source ${lib}
done

lib_yaml_utils.check_yaml
echo ""
lib_env_utils.check_os
echo ""
lib_env_utils.check_docker
echo ""
value=$(lib_yaml_utils.get_yaml_key "settings.yaml" "app.long_name" "app")
echo value: $value
echo ""
keyvalue=$(lib_yaml_utils.value_to_env "LONG_APP_NAME" "hola")
echo keyvalue is $keyvalue
rm -f .environment
touch .environment
lib_yaml_utils.setenv_app_values "settings.yaml" ".environment"
mv .environment .env



