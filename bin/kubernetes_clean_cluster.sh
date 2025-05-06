#!/usr/bin/env bash

#### Description: Init kubernetes cluster.
#### Written by: Guillermo de Ignacio - gdeignacio on 02-2025


# Revision 2025-02-25

###################################
###   KUBERNETES CLUSTER UTILS  ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./kubernetes_init_cluster.sh

Init kubernetes cluster

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Configuring kubernetes..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux
 


if [[ isLinux -eq 1 ]]; then

    sudo systemctl stop kubelet

    # ACERCA DE SWAP
    sudo swapoff -a
    # sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    sudo rm -rf /etc/kubernetes/*
    sudo rm -rf /var/lib/etcd/*
    sudo rm -rf /var/lib/etcd/member

    sudo kubeadm reset -f



else
    echo ""
    echo "Kubernetes should be installed manually"
    echo ""
fi



