#!/usr/bin/env bash

#### Description: Propagates custom dist files from template
#### Written by: Guillermo de Ignacio - gdeignacio on 01-2023

### Revision 2024-08-01

######################################
###   SETUP FROM TEMPLATE UTILS    ###
######################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./app_propagate_dist.sh

Setting .template files

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


TEMPLATE_FOLDER=""
SETTINGS_FOLDER=""

main() {

    IFS=' '
    #Read the split words into an array based on space delimiter
    read -a START_ARRAY <<< ${APP_ARRAY}

    APPS_PATH=${PROJECT_PATH}/../../..
    echo ${APPS_PATH}

    TEMPLATE_FOLDER=settings.template.d
    SETTINGS_FOLDER=settings

    MAIN_START=main/1.0.0

    echo "Reading ${MAIN_START}"
    MAIN_SETTINGS=${APPS_PATH}/${MAIN_START}/dev-utils/settings

    for FILE in $MAIN_SETTINGS/[0-9]*; do

        if [[ ${FILE} == *100_app ]]
        then
            echo "Skiping app file: "$FILE
            continue
        fi

        if [[ ${FILE} == *.backup ]]
        then
            echo "Skiping backup file: "$FILE
            continue
        fi

        
        echo "Propagating: "$FILE
        echo ""
            
        for START in ${START_ARRAY[*]}; do
             
            if [[ ${START} == ${MAIN_START} ]]
            then
                echo "Skipping main settings"
                continue
            fi

            echo Updating $FILE to settings in $START
            cd ${APPS_PATH}/${START}/dev-utils/settings
            echo Target settings folder is $(pwd)
                
            FILENAME=$(basename "$FILE")
            echo "Filename is: $FILENAME"
                
            if [[ -f "$FILENAME" ]]
            then
                TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
                NEWFILEBACKUP=${FILENAME}.${TIMESTAMP}.backup
                echo "Backing up old $FILENAME to $NEWFILEBACKUP"
                mv $FILENAME $NEWFILEBACKUP
            fi

            cp $FILE $FILENAME

            cd ${APPS_PATH}
            echo Current folder now is $(pwd)
            echo ""    

        done

        echo "Propagated: "$FILE
        echo ""
        
    done

    cd $PROJECT_PATH
    echo "Current folder now is $(pwd)"

}

main "$@"
