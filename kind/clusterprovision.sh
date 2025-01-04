#!/bin/bash

export INSTALL_PROM=no

# Crear el clúster
if ! kind create cluster --config cluster.yaml; then
    exit 1
fi;

# Quitar la taint del master
kubectl --context kind-kind taint nodes --all node-role.kubernetes.io/master- || true

# Aplicar los manifiestos
kubectl --context kind-kind apply -f bundle
# Algunas CRDs no están disponibles de inmediato
sleep 10
kubectl --context kind-kind apply -f bundle

# Dar tiempo para registrar algunas CRDs
sleep 10
# Intentar de nuevo
kubectl --context kind-kind apply -f bundle

# Instalar el servidor de métricas
kubectl --context kind-kind apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sleep 10

# Instalar el dashboard de Kubernetes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

# Crear un ServiceAccount y un ClusterRoleBinding para el dashboard
kubectl create serviceaccount admin-user -n kubernetes-dashboard
kubectl create clusterrolebinding admin-user-binding --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

# Instalar Nginx Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Crear un Ingress para el dashboard
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: dashboard.localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port:
              number: 80
EOF

if [ "${INSTALL_PROM}" = "yes" ]; then
    # Instalar Prometheus y Grafana manualmente
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

    # Crear un Ingress para Grafana
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
EOF
fi;

kubectl apply -f vault

sleep 5
echo ""
echo "Nginx Ingress Controller: http://dashboard.localhost"
echo "Dashboard: http://dashboard.localhost"
if [ "${INSTALL_PROM}" = "yes" ]; then
    echo "http://grafana.localhost credentials: $(kubectl get secret -n monitoring grafana -oyaml | grep admin-user| cut -d: -f2|tr -d \  | base64 -d):$(kubectl get secret -n monitoring grafana -oyaml | grep admin-password| cut -d: -f2|tr -d \  | base64 -d)\n"
fi;

echo "The vault unlock secret (root token) lives in the vault/vault-unlock secret, to get the root token wait up to one minute then run"
echo "  kubectl get secret -n vault vault-unlock -ojson | jq -r .data.value | base64 -d | jq -r .root_token"