#!/usr/bin/env bash

#### Description: Restoring database using pg_restore
#### Written by: Guillermo de Ignacio - gdeignacio on 04-2021

# Revision 2024-08-01

###################################
###   RESTORE UTILS             ###
###################################


set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./pg_bdclientrestore.sh

    Restoring database using pg_restore

'
    exit
fi


echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Restoring database..."
echo ""

# Taking values from .env file
source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}

FILENAME=${PROJECT_PATH}/../data/postgresql/15.2-alpine/backups/${PG_LONG_APP_NAME}.tar

cp ${FILENAME} /tmp/restore.tar

${PG_PATH}/pg_restore \
    --file=/tmp/restore.tar \
    --format=t \
    --verbose \
    --schema=${PG_DUMP_SCHEMA} \
    --host=${PG_DUMP_HOSTNAME} \
    --port=${PG_PORT} \
    --username=${PG_DUMP_NAME} \
    ${PG_DUMP_DBNAME}