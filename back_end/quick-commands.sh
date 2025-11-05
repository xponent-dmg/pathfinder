#!/bin/bash

# 1. Start Minikube
minikube start

# 2. Set Docker environment
eval $(minikube docker-env)

# 3. Build Docker image
cd back_end
docker build -t pathfinder-backend:latest .

# 4. Apply Kubernetes manifests
kubectl apply -f k8s/

# 5. Verify deployment
kubectl get pods

# Terminal 1: Backend port forward
kubectl port-forward deployment/pathfinder-backend 5050:5050

# Terminal 2: Grafana port forward
kubectl port-forward service/grafana-service 3000:3000

#FOR TESTING%

# Test health endpoint
curl http://localhost:5050/health

# Test metrics endpoint
curl http://localhost:5050/metrics

# Test root endpoint
curl http://localhost:5050/

