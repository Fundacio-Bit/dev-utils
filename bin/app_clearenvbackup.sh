#!/usr/bin/env bash

#### Description: Clear environment backup files
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

### Revision 2024-08-01

#########################################
###   CLEAR ENVIRONMENT BACKUP UTILS  ###
#########################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./app_clearenvbackup.sh

Clear environment backup files

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at ${PROJECT_PATH}"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Clearing backup files..."
echo ""

main(){

    for FILE in settings/*.backup; do
        echo "Removing "${FILE}
        rm ${FILE}
    done
    echo ""
    
}

main "$@"
