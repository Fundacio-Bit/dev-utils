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
    echo 'Usage: ./r_install.sh

Installs R tools from scratch

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


get_repositories(){
    # update indices
    sudo apt update -qq
    # install two helper packages we need
    sudo apt install --no-install-recommends software-properties-common dirmngr
    # add the signing key (by Michael Rutter) for these repos
    # To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
    # Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
    # add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
    sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
}

main_install(){
    sudo apt-get install --no-install-recommends r-base
    sudo apt-get install libxml2 libxml2-dev xml2
    sudo apt-get install libpcre2-dev liblzma-dev libbz2-dev
}

extra_repo(){
    # Run this command (as root or by prefixing sudo) to add the current R 4.0 or later ‘c2d4u’ repository:
    sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+
}

main() {

    isLinux=$(lib_env_utils.check_os)
    echo $isLinux
    get_repositories
    main_install
    extra_repo
}

main "$@"
