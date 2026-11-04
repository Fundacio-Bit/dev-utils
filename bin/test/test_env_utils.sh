#!/usr/bin/env bash

#### Description: Test for env utils
### Usage: ./test_env_utils.sh
### This script is used to test the env utils functions.

#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2026-06-26: Update LIB_PATH to bin/lib

###################################
###   Test environment utils   ###
###################################

set -o nounset
set -o errexit

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Testing env utils..."
echo ""

LIB_PATH=$PROJECT_PATH/bin/lib

for lib in $LIB_PATH/lib*.sh; do
    source ${lib}
done

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""
lib_env_utils.check_os
echo ""
lib_env_utils.check_docker
#echo ""
#lib_env_utils.check_docker_compose

echo ""
lib_env_utils.check_some "java"

echo ""
lib_env_utils.check_some "uv"