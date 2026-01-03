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

### Host to VMv
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
## A3 (and some of A4): Operate and Monitor Kubernetes

### 1. Environment Setup

Set these variables in *all* terminals that you use for the following setup to ensure consistency across commands:

```bash
export STACK_NAME="sms-monitor"
export APP_NS="sms"
export MON_NS="monitoring"
```

### 2. Infrastructure Setup (Minikube & Istio)

We need the cluster and the Service Mesh installed *before* deploying the app.

```bash
# 1. Start Minikube
minikube start --driver=docker --memory=6144 --cpus=4
minikube addons enable metallb
minikube addons enable ingress

# 2. Install Istio (Required for the App's Gateway)
istioctl install --set profile=default -y
```

### 3. Install Monitoring Stack

```bash
kubectl create namespace $MON_NS

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus/Grafana
helm install $STACK_NAME prometheus-community/kube-prometheus-stack \
  -n $MON_NS \
  --wait
```

### 4. Secrets & Configuration

**A. Create Gmail Secret (For Alerts)**
Replace `YOUR_16_CHAR_CODE` with your Google App Password (from [myaccount.google.com/apppasswords - remember to remove spaces from your app password](https://myaccount.google.com/apppasswords)):

```bash
kubectl create secret generic sms-secrets \
  --from-literal=smtp_pass="YOUR_16_CHAR_CODE" \
  -n $MON_NS
```



**B. Configure values.yaml**
Ensure `helm/sms/values.yaml` matches your monitoring stack and email settings. 
**Important:** Update all three email fields to your own address.

```yaml
monitoring:
  enabled: true
  prometheusRelease: "sms-monitor" # Matches $STACK_NAME
  alerts:
    email:
      enabled: true
      to: "your.email@gmail.com"
      from: "your.email@gmail.com"      # Required for SMTP auth
      username: "your.email@gmail.com"  # Required for SMTP auth
```

### 5. Deploy SMS Application

Now that Infrastructure and Monitoring are ready, we deploy the app.

```bash
# 1. Create App Namespace with Istio Injection
kubectl create namespace $APP_NS
kubectl label namespace $APP_NS istio-injection=enabled --overwrite

# 2. Deploy the Helm Chart
helm upgrade --install sms ./helm/sms \
  -n $APP_NS \
  --create-namespace \
  --wait
```

### 6. Verification I: Alerts (A3)

Now that the app is running, we can trigger the monitoring alerts.

**1. Find Service Names:**
Run this to see the exact names of your Prometheus and Alertmanager services:
```bash
kubectl get svc -n $MON_NS
```

**2. Port Forwarding:**

(Replace `SERVICE_NAME` below with the actual names found in step 1)

** Reminder to add your stack every time you open a new terminal for the commands below.**

```bash
# Forward Prometheus (e.g., sms-monitor-kube-prometheu-prometheus)
kubectl port-forward -n $MON_NS svc/YOUR_PROMETHEUS_SERVICE_NAME 9090:9090

# Forward Alertmanager (e.g., sms-monitor-kube-prometheu-alertmanager)
# Reminde
kubectl port-forward -n $MON_NS svc/YOUR_ALERTMANAGER_SERVICE_NAME 9093:9093

# Forward Grafana and Get Password
kubectl get secret --namespace $MON_NS $STACK_NAME-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl port-forward -n $MON_NS svc/$STACK_NAME-grafana 3000:80 
```

**3. Trigger HighRequestRate Alert:**
Before running the code below, please run the following:

```bash
minikube tunnel
```

Get the External IP of the Istio Ingress Gateway
Wait until 'EXTERNAL-IP' is a real IP and not <pending>
```bash
kubectl get svc -n istio-system istio-ingressgateway
```


Add the entry to your hosts file
Replace <IP> with the value from the command above
Use the command below to open your host file in edit mode.

```bash
sudo nano /etc/hosts
```

Replace the <IP> with the External IP you recieved on running the following command above:
```bash
kubectl get svc -n istio-system istio-ingressgateway
``` 

Add this line at the bottom of your `/etc/hosts`

```bash
<IP>  sms.test.local canary.local stable.local
```


Send traffic to the Ingress to simulate load. [Please refer to the first section in A4 to add the hosts for curl]


* **Linux/Mac:**
```bash
for i in {1..200}; do 
  curl -s -X POST http://sms.test.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms":"load test message","guess":"ham"}' > /dev/null; 
  sleep 1; 
done
```

*Check [http://localhost:9090/alerts](http://localhost:9090/alerts) to see the alert fire.*

---

## A4: Istio Service Mesh & Continuous Experimentation

## Part 1: Shadow Launch 

**Goal:** Deploy V2 (Canary) and mirror real traffic to it without users knowing.

### 1. Enable Shadow Mode
We use the dynamic traffic switch to route 100% of users to Stable (V1) but mirror a copy to Canary (V2).

```bash
helm upgrade --install sms ./helm/sms -n sms --set traffic.mode=shadow
```

### 2. Generate Traffic
Run this loop to mimic user activity (POST requests).
```bash
for i in {1..20}; do 
  echo -n "Request $i: "
  curl -s -i -X POST http://sms.test.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms":"shadow launch test","guess":"ham"}' | grep -i "version:"
  sleep 0.5
done
```

### 3. Verification 
Proof that V2 received the traffic by checking its logs. We filter specifically for the **backend container** to avoid Istio noise.
Run the following in a new terminal:
```bash
# Follow the live traffic on the V2 backend (only shows new logs)
kubectl logs -n sms -l app=sms-backend,version=v2 -c backend -f --tail=0
```
*Look for lines like: `"POST /predict HTTP/1.1" 200`*

---

## Part 2: Canary Release (The Experiment)

**Goal:** Release V2 to 10% of users and measure engagement.

### 1. Enable Canary Mode (90/10 Split)
```bash
# Apply Canary Split
helm upgrade --install sms ./helm/sms -n sms --set traffic.mode=canary
```

### 2. Verify Sticky Sessions
Ensure cookies still pin users to versions.
```bash
# Should be V1
curl -I --cookie "sms-user=stable" http://sms.test.local/sms

# Should be V2
curl -I --cookie "sms-user=canary" http://sms.test.local/sms
```

### 3. Run the Experiment 
Generate the traffic for your Grafana graphs.
```bash
chmod +x run-experiment.sh
./run-experiment.sh
```

### 4. Verification
Go to [http://localhost:3000](http://localhost:3000).
* **Graph:** User Engagement (Request Rate).
* **Evidence:** Show the Green Line (Stable) high and Yellow Line (Canary) low, running in parallel.



