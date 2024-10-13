#!/usr/bin/env bash

#### Description: Installs ssh tools from scratch
#### Written by: Guillermo de Ignacio - gdeignacio on 12-2022

# https://www.r-project.org/
# https://cloud.r-project.org/

######################################
###     SSH FROM SCRATCH UTILS     ###
######################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./ssh_install.sh

Installs ssh tools from scratch

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

export OPENSSL_CERTS_PATH=${APP_FILES_BASE_FOLDER}/assets/ssl


get_ca(){
    # Install the ca-certificates package:
    sudo apt-get install ca-certificates
}

main_install(){

    sudo apt-get update
    sudo apt-get upgrade

    sudo apt-get install openssl openssh-server openssh-client
    sudo service ssh start
    sudo service ssh enable
    sudo apt-get install net-tools
}

fetch_cert(){
    openssl s_client -showcerts -connect intranet.caib.es:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > ${OPENSSL_CERTS_PATH}/certificate.pem
    
}

main() {

    isLinux=$(lib_env_utils.check_os)
    echo $isLinux
    # get_ca
    main_install
    fetch_cert
}

main "$@"
