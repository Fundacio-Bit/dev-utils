#!/usr/bin/env bash

#### Description: Creates an .Renviron file from xx_XXenv files in alpabethical order
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022


##############################
###   SETUP ENV VALUES     ###
##############################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./r_setenv.sh

Creates an .Renviron file from xx_XXenv files in alpabethical order

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Getting to create Renviron file..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

touch .Renvironment
#for FILE in settings/[0-9]*; do
#    if [[ ${FILE} == *.backup ]]
#    then
#        echo "Skiping backup file: "$FILE
#    else
#        echo "Loading: "$FILE
#        echo $'\n' >> .environment
#        cat $FILE >> .environment
#    fi
#done
echo ""

cat assets/.Renviron.template >> .Renvironment
echo "" >> .Renvironment

mv .Renvironment .Renviron