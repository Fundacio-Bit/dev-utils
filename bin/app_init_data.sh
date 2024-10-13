#!/usr/bin/env bash

#### Description: Init data folders
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

### Revision 2024-08-01

###################################
###   DATA FOLDER INSTALL UTILS ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./app_init_data.sh

Creates data folders

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Getting to create folder..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

DATA_FOLDER=$APP_FILES_BASE_FOLDER

mkdir -p $DATA_FOLDER

IFS=' '
#Read the split words into an array based on space delimiter
read -a SUBFOLDER_ARRAY <<< ${APP_FILES_SUBFOLDER_ARRAY}

# VERSIONS_ARRAY=${APP_PROJECT_DB_PATCH_ARRAY}

SUBFOLDER_PATH=${DATA_FOLDER}

for SUBFOLDER in ${SUBFOLDER_ARRAY[*]}; do
  SF=${SUBFOLDER_PATH}/${SUBFOLDER}  
  echo "Creating "$SF" folder"
  mkdir -p $SF
done


