#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail


packageUpdate() {

    echo "update apt cache"
    apt update >> /dev/null
}

installSnap() {

    echo "install snapd"
    apt install -y snapd
    snap install microk8s --classic
    snap install kubectl --classic
}

preparation() {

    iptables -P FORWARD ACCEPT
    mkdir -p /usr/share/elasticsearch/data
    chown 1000:2000 /usr/share/elasticsearch/data

}

installMicrok8s() {

    microk8s status --wait-ready >> /dev/null
    microk8s enable dns
    microk8s enable ingress
    microk8s enable hostpath-storage
}

postTasks() {

 microk8s config > kubeconfig

 echo "microk8s installed and configured"
 echo "run export KUBECONFIG=kubeconfig to configure kubectl"

}

cd "$(dirname "$0")"

main() {

    packageUpdate
    installSnap
    preparation
    installMicrok8s
    postTasks
}

main "$@"
