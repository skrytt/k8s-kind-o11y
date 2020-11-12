#!/bin/bash
set -euxo pipefail

# Create a single-node cluster
kind create cluster --name kind --config ./cluster/cluster.yaml

# Install Prometheus Operator
PROMETHEUS_OPERATOR_VERSION="v0.43.2"
wget -O- https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${PROMETHEUS_OPERATOR_VERSION}/bundle.yaml | kubectl apply -f-

# Deploy Prometheus: 
# http://localhost:8080/prometheus/
PROMETHEUS_IMAGE="quay.io/prometheus/prometheus:v2.22.1"
helm upgrade --install --set image="${PROMETHEUS_IMAGE}" prometheus ./prometheus

# Deploy Grafana:
# http://localhost:8080/grafana/
# NOTE: Helm chart numbering does not match Grafana versioning
# Helm chart version 6.1.4 includes Grafana version 7.3.1
GRAFANA_HELM_CHART_VERSION="6.1.4"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --version "${GRAFANA_HELM_CHART_VERSION}" --values ./grafana/values.yaml grafana grafana/grafana

# Install Loki and Promtail (Remote chart):
# http://localhost:8080/loki/
# http://localhost:8080/promtail/
LOKI_VERSION="2.0.0"
helm repo add loki https://grafana.github.io/loki/charts
helm repo update
helm upgrade --install --version "${LOKI_VERSION}" --values ./loki-stack/values.yaml loki loki/loki-stack

# Install Ambassador and use it to set up cluster ingress
AMBASSADOR_VERSION="v1.2.9"
./ambassador/bootstrap.sh "$AMBASSADOR_VERSION"
kubectl apply -f ./ambassador/ingress.yaml

echo "Done"