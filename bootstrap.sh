#!/bin/bash
set -euxo pipefail

# Create a single-node cluster
kind create cluster --name kind --config ./cluster/cluster.yaml

# Install Prometheus Operator
PROMETHEUS_OPERATOR_VERSION="v0.43.2"
wget -O- https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${PROMETHEUS_OPERATOR_VERSION}/bundle.yaml | kubectl apply -f-

# Deploy Prometheus: http://localhost:8080/prometheus/
PROMETHEUS_IMAGE="quay.io/prometheus/prometheus:v2.22.1"
helm install --set image="${PROMETHEUS_IMAGE}" prometheus ./prometheus

# Deploy Grafana: http://localhost:8080/grafana/
GRAFANA_IMAGE="docker.io/grafana/grafana:7.3.1"
helm install --set image="${GRAFANA_IMAGE}" grafana ./grafana 

# Install Ambassador and use it to set up cluster ingress
AMBASSADOR_VERSION="v1.2.9"
./ambassador/bootstrap.sh "$AMBASSADOR_VERSION"
kubectl apply -f ./ambassador/ingress.yaml

echo "Done"