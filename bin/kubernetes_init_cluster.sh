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

    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --node-name 127.0.0.1
    # Cuando termine, verás un comando kubeadm join ... que necesitarás más tarde para agregar nodos.



    
    # Instalar un complemento de red
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml --validate=false


    sudo tee /etc/cni/net.d/10-calico.conflist <<EOF
{
  "cniVersion": "0.3.1",
  "name": "k8s-pod-network",
  "plugins": [
    {
      "type": "calico",
      "etcd_endpoints": "http://127.0.0.1:2379",
      "log_level": "info",
      "ipam": {
        "type": "calico-ipam"
      },
      "policy": {
        "type": "k8s"
      },
      "kubernetes": {
        "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    }
  ]
}
EOF



      # Configurar el entorno de Kubernetes
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    sudo chmod 600 $HOME/.kube/config

  

    # En cada nodo de trabajo, usa el comando que te dio kubeadm init, por ejemplo:

    # sudo kubeadm join <IP_MAESTRO>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>

    # Si perdiste el comando, en el nodo maestro puedes obtenerlo con:

    # kubeadm token create --print-join-command


   

else
    echo ""
    echo "Kubernetes should be installed manually"
    echo ""
fi



