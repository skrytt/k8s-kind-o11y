#!/bin/bash
set -euxo pipefail

AMBASSADOR_VERSION=$1

kubectl apply -f https://github.com/datawire/ambassador-operator/releases/download/${AMBASSADOR_VERSION}/ambassador-operator-crds.yaml
kubectl apply -n ambassador -f https://github.com/datawire/ambassador-operator/releases/download/${AMBASSADOR_VERSION}/ambassador-operator-kind.yaml
kubectl wait --timeout=180s -n ambassador --for=condition=deployed ambassadorinstallations/ambassador
