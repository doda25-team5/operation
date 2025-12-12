# SMS Checker — Operation Repository

This repository contains the **Docker Compose** setup used to run the complete SMS Checker application, which includes:
* **model-service** (Python backend)
* **frontend** (Spring Boot UI)

## A1: Versions, Releases & Containerization 

### Requirements

The following software is required to run the application:
* **Docker**
* **Docker Compose v2+**


### Environment Variables in .env


Defining the purpose of a few variables:

#### Frontend
| Variable      | Purpose                                    | Default                     |
| ------------- | ------------------------------------------ | --------------------------- |
| `SERVER_PORT` | Internal port the frontend binds to        | `8080`                      |


#### Model-Service
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

### How to Start the Application

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

### Using a Specific Image Tag

By default, the Compose file uses the **`latest`** image tag.


To run a **specific version** (for example, `v1.0.2`), set the `IMAGE_FRONTEND_TAG` or `IMAGE_BACKEND_TAG` environment variable in the .env when running Compose:


### Test the frontend    

Open:

```bash
http://localhost:8080/sms
```
Submit an SMS message and verify the prediction result.

### Check the version library

```bash
http://localhost:8080/lib-version
```
### Related Repositories

* **`app`**: Contains the Spring Boot frontend application and its Dockerfile.
* **`model-service`**: Contains the Python backend application and its Dockerfile.
* **`lib-version`**: Version-aware Maven Library

## A2: Provisioning a Kubernetes Cluster

From the operation repo, go into the vagrant directory in order to follow through with the rest of this section.

```bash
cd vagrant
```

In this directory, we have the ansible/ folder which holds the different playbooks for each nodes (ctrl, node-1, etc). We also have a finalization/ folder which holds all the files that pertains to the 'Finalizing the Cluster Setup'. 

First run `vagrant up` to start up the cluster and run all the playbooks.

### Network Communication

#### VM to VM

```bash
vagrant ssh ctrl # go into the ctrl node

ping -c 3 node-1
ping -c 3 node-2

exit
```

### Host to VM

```bash
ping -c 3 ctrl
ping -c 3 node-1
ping -c 3 node-2
```
### Host-Based Kubernetes Access

During provisioning, the controller’s kubeconfig (admin.conf) is copied to the shared /vagrant folder so it is accessible from the host machine.

#### Verify kubeconfig exists

```bash
ls -l admin.conf
```
#### Use kubectl from your host system

```bash
kubectl --kubeconfig=./admin.conf get nodes
```

This confirms:
- The control plane is running
- Workers joined successfully
- The host can manage the cluster


### Accessing the Kubernetes Dashboard

The dashboard is deployed via Helm and exposed through an Ingress. We assign it a stable MetalLB external IP and access it through a hostname. FIrst we must apply the finalization playbook. 

#### Apply the finalization playbook (Inginx, MetalLB, Dashboard, etc.)

From your host terminal (make sure you're in the vagrant directory), execute:

```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization/finalization.yaml
```

If you encounter an SSH error at task 'Ensure vagrant user has passwordless sudo' then do the following:

From your host machine do:

```bash
ssh-copy-id vagrant@192.168.56.100
#It will prompt you to enter a password. The password is vagrant.
```

This will enable you to not have to enter a password when SSH'ing into ctrl. 

To ensure it's good, attempt the following command and make sure it doesn't prompt you to enter a password.

```bash
ssh vagrant@192.168.56.100
```

Once this is good, you can go back and execute
```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization/finalization.yaml
```

#### Add hostname entry (on the host machine)

In your host terminal, execute the command:

```bash
nano /etc/hosts
```

and paste the following:

```bash
192.168.56.90  dashboard.local
```
#### Access the dashboard via your browser

Pase this url in your broswer to access the dashboard

```bash
https://dashboard.local
```

#### Generate an admin token for login:

First SSH into the ctrl node using:

```bash
vagrant ssh ctrl
```
Once you've done that, execute the following command to generate a token:

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

A token should be generated. Copy this and paste it into the dashboard token promp you should be able to login!

### Ingress-NGINX Controller For Dashboard

The Ingress controller receives the MetalLB external IP:

```bash
192.168.56.90
```
#### To verify the service (from host)

```bash
kubectl --kubeconfig=./admin.conf -n ingress-nginx get svc ingress-nginx-controller
```

You should see the service running with type 'LoadBalancer' and External-IP '192.168.56.90'

### MetalLB Load Balancer Configuration

MetalLB is installed using the native manifests, and the IPAddressPool defines the IP range assigned to LoadBalancer services.

Pool:

```bash
addresses:
  - 192.168.56.90-192.168.56.99
```

#### Verify MetalLB components

```bash
kubectl --kubeconfig=./admin.conf get pods -n metallb-system
```

You should see a controller and speaker running

#### Verify IP Allocation

```bash
kubectl --kubeconfig=./admin.conf get svc
```

A service of type LoadBalancer should get an IP within your pool

### Verification Commands

```bash
kubectl --kubeconfig=./admin.conf get nodes
kubectl --kubeconfig=./admin.conf get pods -A
kubectl --kubeconfig=./admin.conf get svc -A
kubectl --kubeconfig=./admin.conf get ingress -A
kubectl --kubeconfig=./admin.conf get daemonset -A
kubectl --kubeconfig=./admin.conf get deployments -A
```
## A3: Operate and Monitor Kubernetes

### Steps for running the kubernetes cluster
- minikube start --driver=docker --memory=4096 --cpus=4
- minikube addons enable ingress
- minikube addons enable metallb
- istioctl install --set profile=default -y
- helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
- helm repo update
- kubectl create namespace monitoring
- helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --wait
- helm upgrade --install sms ./helm/sms -n default --create-namespace --wait
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

### Test Mounted Shared Folder

#### Start Minikube

```bash
minikube start --driver=docker
```

#### (Important) Allow mount port through firewall (Ubuntu only)

Minikube mount uses a TCP port for communication between host ↔ node.
Some Ubuntu systems block this unless explicitly allowed.

Allow a safe port:

```bash
sudo ufw allow 20000/tcp
#(This step is harmless even if UFW is disabled.)
```

#### Start the host -> Minikube mount

Run this in a seperate terminal window
Do not close this terminal while testing

```bash
minikube mount $(pwd)/shared:/mnt/shared --port=20000
```

You should see something like ✅ Successfully mounted.

#### Deploy the application

```bash
helm upgrade --install sms ./helm/sms \
   -n default \
--create-namespace
```

If it fails due to prometheus not being installed then you must install it first.

Wait for the pod to be running:

```bash
kubectl get pods -n default
```

#### Verify the mount inside the Pod

Get the frontend pod name:

```bash
POD=$(kubectl get pod -n default -l app=sms-frontend -o jsonpath='{.items[0].metadata.name}')
```

Check the shared directory:

```bash
kubectl exec -it -n default $POD -- ls /mnt/shared
```

Expected output:

```bash
example.txt
```
  
## A4: Istio Service Mesh
  
- To test 90 / 10 split
- minikube tunnel
- for i in {1..20}; do curl -si -H "x-user: bob" http://localhost/sms | grep version; done (mac/linux)
- for ($i=1; $i -le 20; $i++) {
    curl -Headers @{"x-user"="bob"} http://localhost/sms -UseBasicParsing | Select-String version
} (windows)



