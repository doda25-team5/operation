# SMS Checker — Operation Repository

This repository contains the **Docker Compose** setup used to run the complete SMS Checker application, which includes:
* **model-service** (Python backend)
* **frontend** (Spring Boot UI)

---

## Requirements

The following software is required to run the application:
* **Docker**
* **Docker Compose v2+**

---


## ⚙️ Environment Variables in .env


Defining the purpose of a few variables:

### Frontend
| Variable      | Purpose                                    | Default                     |
| ------------- | ------------------------------------------ | --------------------------- |
| `SERVER_PORT` | Internal port the frontend binds to        | `8080`                      |


### Model-Service
| Variable           | Purpose                                      | Default                   |
| ------------------ | -------------------------------------------- | ------------------------- |
| `MODEL_PORT`       | Internal port Flask listens on               | `8081`                    |
| `MODEL_URL`        | Public URL of the model artifact             | set in docker-compose.yml |
| `PREPROCESSOR_URL` | Public URL of the preprocessor artifact      | set in docker-compose.yml |
| `MODEL_DIR`        | Directory for downloaded/mounted model files | `/root/sms/output`        |


All variables are mentioned and configured in the `.env` file.

Example `.env`:

```bash

IMAGE_BACKEND_TAG=latest
IMAGE_FRONTEND_TAG=latest
MODEL_DIR=/root/sms/output
MODEL_FILENAME=model.joblib
PREPROCESSOR_FILENAME=preprocessor.joblib
MODEL_URL=https://github.com/doda25-team5/model-service/releases/download/test-f9-ghcli/model.joblib
PREPROCESSOR_URL=https://github.com/doda25-team5/model-service/releases/download/test-f9-ghcli/preprocessor.joblib
MODEL_PORT=8081
FRONTEND_HOST_PORT=8080
SERVER_PORT=8080

```
---
## ▶ How to Start the Application

From this directory, use the following command to start the services:

```bash
docker compose up --pull always
```

This command will:
* Pull images from **GHCR** (GitHub Container Registry).
* Set up the internal network
* Start both services
* Start the frontend on `http://localhost:8080/sms`.


To start the application in **detached mode** (running in the background):

```bash
docker compose up -d
```

To **stop** and remove the containers, networks, and volumes:

```bash
docker compose down
```

---

## Using a Specific Image Tag

By default, the Compose file uses the **`latest`** image tag.


To run a **specific version** (for example, `v1.0.2`), set the `IMAGE_FRONTEND_TAG` or `IMAGE_BACKEND_TAG` environment variable in the .env when running Compose:


---

## Test the frontend    

Open:

```bash
http://localhost:8080/sms
```
Submit an SMS message and verify the prediction result.

## Check the version library

```bash
http://localhost:8080/lib-version
```
---

## Related Repositories

* **`app`**: Contains the Spring Boot frontend application and its Dockerfile.
* **`model-service`**: Contains the Python backend application and its Dockerfile.
* **`lib-version`**: Version-aware Maven Library

## Accessing the Kubernetes Cluster and Services
After running the finalization.yml playbook, the Kubernetes cluster exposes its services through MetalLB and the Ingress-NGINX controller.

### Kubernetes Dashboard

The dashboard is exposed through an Ingress with the hostname:

```bash
dashboard.local
```

1. Add to /etc/hosts:
   
```bash
192.168.56.90  dashboard.local
```

2. Open in your browser:
   
```bash
https://dashboard.local
```

### Ingress-NGINX Controller

The Ingress controller receives the MetalLB external IP:

```bash
192.168.56.90
```


### MetalLB IPAddressPool Manifest

Pool:

```bash
 - 192.168.56.90-192.168.56.99
```

### Verification Commands

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```
## A3
### Steps for running the kubernetes cluster
- minikube start driver=docker
- minikube addons enable ingress
- minikube addons enable metallb
- helm upgrade --install sms ./helm/sms -n default --create-namespace --wait (check the directory)
- helm template ./helm/sms -s templates/grafana-dashboards-configmap.yaml | kubectl apply -n monitoring -f -
- POD=$(kubectl get pod -n default -l app=sms-frontend -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward -n default pod/$POD 8080:8080
- POD=$(kubectl get pod -n default -l app=sms-backend -o jsonpath='{.items[0].metadata.name}')
kubectl port-forward -n default pod/$POD 8081:8081
- kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
- kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80
- kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo (for getting the password to the grafana)

### Helm chart for SMS app. Usage:
  - helm upgrade --install sms ./ -n default --create-namespace --set ingress.host=sms.test.local
  
#### Secrets:
  - Do NOT put secrets in values.yaml. 
  - Create Kubernetes secret instead:  
  kubectl create secret generic sms-secrets --from-literal=smtp_user='<USER>' --from-literal=smtp_pass='<PASS>' -n default
Monitoring:
  Enable with --set monitoring.enabled=true


