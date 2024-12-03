#!/usr/bin/env bash

#### Description: Creates custom deploy files from template
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
    echo 'Usage: ./dbt_deploysetup.sh


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





CONF_PATH_ARRAY=($DBT_PROFILES_DIR)
# echo $JBOSS_EAP_52_CONF_PATH
for CFPATH in ${CONF_PATH_ARRAY[*]}; do
    echo ""
    echo "Processing: "$CFPATH
    echo ""
    #TEMPLATE_FOLDER=$DEPLOY_CONF_PATH.template.d
    #SETTINGS_FOLDER=$DEPLOY_CONF_PATH
    TEMPLATE_FOLDER=$CFPATH.template.d
    SETTINGS_FOLDER=$CFPATH

    mkdir -p $SETTINGS_FOLDER
    for FILE in $TEMPLATE_FOLDER/*; do
        echo "Loading: "$FILE
        MASK=${FILE%.template}
        FILENAME=${MASK##*/}
        NEWFILE=$SETTINGS_FOLDER/$FILENAME
        echo "Transforming filename from $FILE to $NEWFILE"
        cp $FILE $NEWFILE
    done

done


echo ""

