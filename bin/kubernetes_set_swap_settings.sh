#!/usr/bin/env bash

#### Description: Keep swap by default.
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
    echo 'Usage: ./kubernetes_set_swap_settings.sh

Set Swap settings for kubernetes

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

    sudo mkdir -p /etc/systemd/system/kubelet.service.d
    echo '[Service]
    Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' | sudo tee /etc/systemd/system/kubelet.service.d/99-swap.conf

    echo ""
    echo "Valores fijados a --fail-swap-on=false para desarrollo"
    echo ""

    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
    systemctl status kubelet
    
else
    echo ""
    echo "Kubernetes should be installed manually"
    echo ""
fi



