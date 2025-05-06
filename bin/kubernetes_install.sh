#!/usr/bin/env bash

#### Description: Installs kubernetes.
#### Written by: Guillermo de Ignacio - gdeignacio on 02-2025


# Revision 2025-02-25

###################################
###   KUBERNETES INSTALL UTILS  ###
###################################

set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./kubernetes_install.sh

Installs kubernetes packages

'
    exit
fi

echo ""
PROJECT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "Project path at $PROJECT_PATH"
echo ""
echo "[$(date +"%Y-%m-%d %T")] Installing kubernetes..."
echo ""

# Taking values from .env file

source $PROJECT_PATH/bin/lib_string_utils.sh 
source $PROJECT_PATH/bin/lib_env_utils.sh

lib_env_utils.loadenv ${PROJECT_PATH}
echo ""

isLinux=$(lib_env_utils.check_os)
echo $isLinux
 
# ACERCA DE SWAP
# Desactivar swap en tu equipo de desarrollo puede tener algunos efectos, dependiendo de cuánta memoria RAM tengas y cómo usas el sistema.
# ¿Por qué Kubernetes requiere desactivar swap?

# Kubernetes asume que la memoria disponible es real (RAM) y no una porción de disco (swap). Si swap está activado, el programador de Kubernetes puede tomar decisiones equivocadas sobre la asignación de recursos, causando inestabilidad en los pods.
# Efectos en tu equipo de desarrollo

# Si tienes suficiente RAM (8GB o más)
#     No notarás mucha diferencia, ya que Ubuntu usa swap solo cuando la RAM está casi llena.
#     Mejor rendimiento para Kubernetes porque evita que los contenedores se ralenticen por swapping.

# Si tienes poca RAM (menos de 8GB)
#     Puedes notar más lentitud si abres muchas aplicaciones pesadas (navegador con muchas pestañas, IDEs, etc.).
#     Sin swap, el sistema podría matar procesos si se queda sin RAM (OOM – Out of Memory).

# En caso de querer desactivar swap, descomenta las siguientes líneas:
# sudo swapoff -a
# sudo sed -i '/ swap / s/^/#/' /etc/fstab  # Desactiva swap permanentemente

# Para un entorno de desarrollo, puedes dejar swap activado, pero Kubernetes no lo recomienda oficialmente.
# ¿Es obligatorio?

# Kubernetes recomienda desactivarlo porque el programador de recursos no maneja bien el intercambio de memoria.
# Desde Kubernetes 1.22, puedes permitir swap usando --fail-swap-on=false al iniciar kubelet.

if [[ isLinux -eq 1 ]]; then


    # Habilitar módulos del kernel para Kubernetes
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
    echo "[$(date +"%Y-%m-%d %T")] Módulos del kernel habilitados..."

    # Configurar parámetros de red
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sudo sysctl --system
    echo "[$(date +"%Y-%m-%d %T")] Parámetros de red configurados..."


    # Reinstalar certificados
    sudo apt-get install --reinstall ca-certificates
    sudo update-ca-certificates
    echo "[$(date +"%Y-%m-%d %T")] Certificados actualizados..."

    sudo apt-get install -y apt-transport-https curl
    echo "[$(date +"%Y-%m-%d %T")] apt-transport-http y curl actualizados."

    # sudo apt install -y containerd
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
    sudo systemctl restart containerd
    echo "[$(date +"%Y-%m-%d %T")] containerd instalado..."

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    echo "[$(date +"%Y-%m-%d %T")] Repositorio de kubernetes añadido..."


    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo systemctl enable kubelet && sudo systemctl start kubelet
    echo "[$(date +"%Y-%m-%d %T")] kubeadm, kubelet y kubectl instalados..."
    
else
    echo ""
    echo "Kubernetes should be installed manually"
    echo ""
fi



