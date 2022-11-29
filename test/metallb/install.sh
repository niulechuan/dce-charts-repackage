#!/bin/bash

CURRENT_FILENAME=$( basename $0 )
CURRENT_DIR_PATH=$(cd $(dirname $0); pwd)

CHART_DIR=$1
KIND_KUBECONFIG=$2

[ -d "$CHART_DIR" ] || { echo "error, failed to find chart $CHART_DIR " ; exit 1 ; }
[ -f "$KIND_KUBECONFIG" ] || { echo "error, failed to find kubeconfig $KIND_KUBECONFIG " ; exit 1 ; }

echo "CHART_DIR: $CHART_DIR"
echo "KIND_KUBECONFIG: $KIND_KUBECONFIG"

HELM_MUST_OPTION=" --timeout 5m0s --wait --debug --kubeconfig ${KIND_KUBECONFIG} "

#==================== add your deploy code bellow =============
#==================== notice , prometheus CRD has been deployed , so you no need to =============

set -x

# deploy the metallb
helm install metallb ${CHART_DIR}  ${HELM_MUST_OPTION}   --namespace metallb-system  --create-namespace \
  --set instances.enabled=true \
  --set instances.arp.nodeSelectors.key=kubernetes.io/arch \
  --set instances.arp.nodeSelectors.value=amd64 \
  --set instances.arp.interfaces="{eth0,eth1}" \
  --set instances.ipAddressPools.addresses="{192.168.1.0/24,172.16.20.1-172.16.20.100,fd00:81::172:81:0:110-fd00:81::172:81:0:120}"

if (($?==0)) ; then
  echo "succeeded to deploy $CHART_DIR"
  exit 0
else
  echo "error, faild to deploy $CHART_DIR"
  exit 1
fi
