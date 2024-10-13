#!/usr/bin/env bash

#### Description: Backup database using pg_dump
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   BACKUP UTILS              ###
###################################


set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pg_bdclientbackup.sh

    Backup database using pg_dump

'
    exit
fi


echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Saving database..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}


echo Saving with $PG_DUMP_SCHEMA_ONLY option
${PG_PATH}/pg_dump $PG_DUMP_SCHEMA_ONLY \
    --file=${PG_DUMP_FILENAME} \
    --format=t \
    --verbose \
    --schema=${PG_DUMP_SCHEMA} \
    --column-inserts \
    --host=${PG_DUMP_HOSTNAME} \
    --port=${PG_DUMP_PORT} \
    --username=${PG_DUMP_NAME} \
    ${PG_DUMP_DBNAME}