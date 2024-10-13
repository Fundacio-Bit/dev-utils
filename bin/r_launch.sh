#!/usr/bin/env bash

#### Description: Installs R tools from scratch
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

# https://www.r-project.org/
# https://cloud.r-project.org/

######################################
###   SETUP FROM SCRATCH UTILS     ###
######################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./r_launch.sh script args

Lanunches an R script

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Setting R..."
echo ""

source $PROJECT_PATH/bin/lib_string_utils.sh
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

main() {

    isLinux=$(lib_env_utils.check_os)
    # echo $isLinux
    
    rpath=$(lib_env_utils.check_R)
    # echo $rpath

    if [[ "${rpath}" == "/dev/null" ]]; then
        echo "R not installed. Exiting"
        exit 1
    fi

    export R_PATH=$PROJECT_PATH

    case $# in
        0)
            echo "Option is needed"
            exit 1
            ;;
        1)
            Rscript $PROJECT_PATH/bin/$1.R
            ;;
        *)
            Rscript $PROJECT_PATH/bin/$1.R "${@:2}"
            ;;
    esac
}

main "$@"
