#!/bin/bash
set -euxo pipefail

# Create a single-node cluster
kind create cluster --name kind --config ./cluster/cluster.yaml

# Deploy Grafana:
# http://localhost:8080/grafana/
# NOTE: Helm chart numbering does not match Grafana versioning
# Helm chart version 6.1.4 includes Grafana version 7.3.1
GRAFANA_HELM_CHART_VERSION="6.1.4"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --version "${GRAFANA_HELM_CHART_VERSION}" --values ./grafana/values.yaml grafana grafana/grafana

# Kube Prometheus Stack (Prometheus Operator, Prometheus, Alertmanager)
# http://localhost:8080/prometheus/
# http://localhost:8080/alertmanager/
KUBE_PROMETHEUS_STACK_VERSION="11.1.1"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm upgrade --install --version "${KUBE_PROMETHEUS_STACK_VERSION}" --values ./kube-prometheus-stack/values.yaml kube-prometheus-stack prometheus-community/kube-prometheus-stack

# Install Loki and Promtail (Remote chart):
# http://localhost:8080/loki/
LOKI_VERSION="2.0.0"
helm repo add loki https://grafana.github.io/loki/charts
helm repo update
helm upgrade --install --version "${LOKI_VERSION}" --values ./loki-stack/values.yaml loki loki/loki-stack

# Install Ambassador and use it to set up cluster ingress
AMBASSADOR_VERSION="v1.2.9"
./ambassador/bootstrap.sh "$AMBASSADOR_VERSION"
kubectl apply -f ./ambassador/ingress.yaml

echo "Done"