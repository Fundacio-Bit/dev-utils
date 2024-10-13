#!/usr/bin/env bash

#### Description: Creates custom settings files from template
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
    echo 'Usage: ./app_settings.sh

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

TEMPLATE_FOLDER=""
SETTINGS_FOLDER=""

main(){

    TEMPLATE_FOLDER=settings.template.d
    SETTINGS_FOLDER=settings

    mkdir -p $SETTINGS_FOLDER
    for FILE in $TEMPLATE_FOLDER/*; do

        if [ "${FILE##*.}" = "ignore" ]; then
            echo "Skipping $FILE"
            continue
        fi

        echo "Loading: "$FILE
        MASK=${FILE%.template}
        FILENAME=${MASK##*/}
        NEWFILE=$SETTINGS_FOLDER/$FILENAME

        # Checking if previous version of NEWFILE exists
        if [[ -f "$NEWFILE" ]]
        then
        TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
        NEWFILEBACKUP=${NEWFILE}.${TIMESTAMP}.backup
        echo "Backing up old $NEWFILE to $NEWFILEBACKUP"
        mv $NEWFILE $NEWFILEBACKUP
        fi
        echo "Transforming filename from $FILE to $NEWFILE"
        cp $FILE $NEWFILE
    done
    echo ""

}

main "$@"
