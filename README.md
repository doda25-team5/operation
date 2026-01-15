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

This section uses virtual machines through Vagrant. 

### Prerequisites
The following tools must be installed on the host system:
- **Vagrant**, for defining and managing virtual machines
- **VirtualBox**, for virtualization 
- **Ansible** – for automated provisioning 

Verify these are installed by running:
```bash
ansible --version
vagrant --version
VBoxManage --version
```

### Enter the Vagrant Directory
Enter the directory containing the Vagrantfile and Ansible playbooks for each node (ctrl, node-1, etc). The finalization/ folder  holds all the files that pertains to the 'Finalizing the Cluster Setup' (Steps 20-23). 
```bash
cd vagrant
```

### Running the VMs
Ensure there are no previously running virtual machines.
```bash
vagrant status
```

If any VMs are running, destroy them.
```bash
vagrant destroy -f
```

To create and start all virtual machines. This will take around 5-10 minutes.
```bash
vagrant up
```

### Network Communication Testing

#### VM to VM

Enter the controler node using the SSH.
```bash
# Enter the ctrl node
vagrant ssh ctrl 

# Ping the nodes
ping -c 3 node-1
ping -c 3 node-2

# Exit the ctrl node
exit
```
If ping fails, check VM network settings and ensure all VMs are running.
```bash
vagrant status
```
If the nodes are not running reload the VMs, this will restart the VMs and reattach the host-only network.
```bash
vagrant reload
```

#### Host to VM 

In your Host terminal, ping the VMs using their IP addresses.
```bash
# Control node
ping -c 3 192.168.56.100

# Worker node 1
ping -c 3 192.168.56.101

# Worker node 2
ping -c 3 192.168.56.102
```

Once connectivity is confirmed, SSH into the control node using the IP address.
```bash
ssh vagrant@192.168.56.100
# Password: vagrant
```
If the pings fail, ensure that all virtual machines are running as before and try reseting them.
```bash
vagrant reload
```

### Kubernetes Cluster

During provisioning, the controller’s kubeconfig (admin.conf) is copied to the shared /vagrant folder so it is accessible from the host machine.

#### Verify kubeconfig exists
From the previous VS terminal (in the vagrant folder) check the kubeconfig.
```bash
ls -l admin.conf
```
#### Test kubectl (Steps 13-17)

Test kubectl for successfull Kubernetes working. 
```bash
vagrant ssh ctrl

# Check node status
kubectl get nodes

# Check system pods 
kubectl get pods -n kube-system

# Check flannel 
kubectl get pods -n kube-flannel

# Check all namespaces 
kubectl get pods --all-namespaces

# Verify helm version
helm version

# Verify helm plugin
helm plugin list

#Exit
exit
```

### Kubernetes Dashboard

The dashboard is deployed via Helm and exposed through an Ingress. We assign it a stable MetalLB external IP and access it through a hostname. 

#### Apply the finalization playbook (Inginx, MetalLB, Dashboard, etc.)

In your Host terminal navigate to the vagrant directory.
```bash
cd /path/to/your/vagrant/folder
```

Run the finalization playbook (Steps 20-23).
```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization/finalization.yaml
```

If you encounter an SSH error at task 'Ensure vagrant user has passwordless sudo' copy the SSH id.
```bash
ssh-copy-id vagrant@192.168.56.100
#Password: vagrant
```

#### Add hostname entry (on the host machine)

On your host machine, open the /etc/hosts file with a text editor.
```bash
nano /etc/hosts
```

Add the following line at the end of the file (replace the IP if your MetalLB IP differs).
```bash
192.168.56.90  dashboard.local
```
Save and close the file.

#### Access the Kubernetes dashboard

Open your web browser and navigate to the local doashboard. 

```bash
https://dashboard.local
```
If you do not see the login page, try opening the link in the Incognito tab.

#### Generate the login admin token:

Generate the login token by SSH into the ctrl node and generate an admin-user token and paste it into the login page.
```bash
vagrant ssh ctrl

# Check the namespaces
kubectl get namespaces

# Create the admin-user token
kubectl -n kubernetes-dashboard create token admin-user
```

### Ingress-NGINX Controller For Dashboard

The Ingress controller receives the MetalLB external IP.
```bash
192.168.56.90
```
#### To verify the service (from host)

Ensure the service running with type 'LoadBalancer' and External-IP '192.168.56.90'.
```bash
kubectl --kubeconfig=./admin.conf -n ingress-nginx get svc ingress-nginx-controller
```

### MetalLB Load Balancer Configuration

MetalLB is installed using the native manifests, and the IPAddressPool defines the IP range assigned to LoadBalancer services.

Pool:

```bash
addresses:
  - 192.168.56.90-192.168.56.99
```
This range should match your host-only network and not conflict with other devices.

#### 3. Verify MetalLB Components
Check that the MetalLB controller and speaker pods are running:
```bash
kubectl --kubeconfig=./admin.conf get pods -n metallb-system
```
You should see pods with names like `controller` and `speaker` in the `Running` state.

#### 4. Verify LoadBalancer IP Allocation
When you create a service of type LoadBalancer, MetalLB will assign it an external IP from your pool. To check:
```bash
kubectl --kubeconfig=./admin.conf get svc
```

### Verification Commands

```bash
kubectl --kubeconfig=./admin.conf get nodes
kubectl --kubeconfig=./admin.conf get pods -A
kubectl --kubeconfig=./admin.conf get svc -A
kubectl --kubeconfig=./admin.conf get ingress -A
kubectl --kubeconfig=./admin.conf get daemonset -A
kubectl --kubeconfig=./admin.conf get deployments -A
```

### Test Istio configuration (Step 23)

Running the finalization playbook verify if Istio was correctly configured. 
```bash
# Ensure to SSH into the ctrl node
vagrant ssh ctrl

# Check istio version
istioctl version

# Ensure istio-system is Active
kubectl --kubeconfig /home/vagrant/.kube/config get ns

# Ensure all istio pods are running
kubectl get pods -n istio-system

# Verify istio ingress gateway
kubectl get svc -n istio-system istio-ingressgateway
```


## A3 (and some of A4): Operate and Monitor Kubernetes

### Scope & Assumptions

This section assumes:
- **Minikube** is running with MetalLB and Ingress enabled
- **Istio** is installed and operational
- **kube-prometheus-stack** is installed in the monitoring namespace
- Infrastructure provisioning (A2) is complete

The application is deployed via a **single Helm chart** that controls all behavior through `values.yaml`.

---

### 1. Environment Setup

Set these variables in *all* terminals that you use for the following setup to ensure consistency across commands:

```bash
export STACK_NAME="sms-monitor"
export APP_NS="sms"
export MON_NS="monitoring"
```
These variables ensure ServiceMonitors, PrometheusRules, and AlertmanagerConfig resources correctly reference the monitoring stack.


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
---
Note:
The Istio Ingress Gateway is treated as cluster-level infrastructure and is not managed by the Helm chart.

It is applied once after Istio is installed and before deploying the application: 

While using Minikube to test:
```bash
kubectl apply -f istio/gateway.yaml
```

⚠️ Important: VirtualServices [in A4] must reference the Gateway using its full name (including the namespace), like
`istio-system/sms-gateway`, not just `sms-gateway`.

The Helm chart does not create the Gateway.
Instead, it references an existing Gateway by name, which is configurable via values.yaml.

---

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

---

### 4. Secrets & Configuration

**A. Create Gmail Secret (For Alerts)**
Replace `YOUR_16_CHAR_CODE` with your Google App Password (from [myaccount.google.com/apppasswords - remember to remove spaces from your app password](https://myaccount.google.com/apppasswords)):

```bash
kubectl create secret generic sms-secrets \
--from-literal=password="YOUR_16_CHAR_CODE_WITHOUT_SPACES" \
  -n $MON_NS
```

**Why pre-deployed?**
Email alert credentials are not configured via values.yaml.

The Helm chart expects a pre-existing Kubernetes Secret (sms-secrets) that contains SMTP field credentials.
No email addresses or credentials are stored in the repository or in Helm values.

**B. Configure values.yaml**
Ensure `helm/sms/values.yaml` matches your monitoring stack.

```yaml
monitoring:
  enabled: true
  prometheusRelease: "sms-monitor" # Matches $STACK_NAME
  alerts:
    email:
      enabled: true
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
**This single command deploys:**
- Frontend (stable v1 + canary v2 deployments)
- Backend (stable v1 + canary v2 + shadow v3 deployments)
- ConfigMaps for application configuration
- Istio resources (VirtualServices, DestinationRules)
- Monitoring resources (ServiceMonitors, PrometheusRules, AlertmanagerConfig)
- Grafana dashboards (auto-imported)

Note: The Istio Gateway is (supposed to be) provisioned separately as cluster infrastructure and is not managed by the Helm chart.

---

### 6. Configuration via values.yaml
The name of the Istio Gateway used by the application is configurable via values.yaml.
All application behavior is controlled through `helm/sms/values.yaml`. You can modify these values and redeploy using `helm upgrade`.

#### 6.1 Traffic Modes

```yaml
traffic:
  mode: canary  # Options: standard | canary
```

**Traffic mode behavior:**

| Mode | Frontend Split | Backend Split | Shadow (v3) Behavior |
|------|----------------|---------------|----------------------|
| `standard` | 100% stable (v1) | 100% stable (v1) | Receives mirrored copy of all v1 traffic |
| `canary` | 90% stable (v1), 10% canary (v2) | 90% stable (v1), 10% canary (v2) | Receives mirrored copy of all v1 + v2 traffic |

**Key point:** Shadow (v3) is **always running** and receives mirrored traffic from both v1 and v2. Shadow responses are discarded (zero user impact).

**To change modes:**
```bash
# Switch to canary mode
helm upgrade --install sms ./helm/sms -n $APP_NS --set traffic.mode=canary

# Switch back to standard
helm upgrade --install sms ./helm/sms -n $APP_NS --set traffic.mode=standard
```

#### 6.2 Scaling Replicas

```yaml
frontend:
  replicas: 1          # Stable frontend replicas
  canaryReplicas: 1    # Canary frontend replicas

backend:
  replicas: 1          # Stable backend replicas
  canaryReplicas: 1    # Canary backend replicas
  shadow:
    replicas: 1        # Shadow backend replicas
```

**Understanding replicas:**
- Each replica is an independent pod with its own counters
- Metrics are per-pod, not globally shared
- Prometheus aggregates metrics across all pods using `sum by (version)`
- Increasing replicas improves throughput and fault tolerance

**To scale:**
```bash
# Scale stable backend to 3 replicas
helm upgrade --install sms ./helm/sms -n $APP_NS \
  --set backend.replicas=3

# Scale all components
helm upgrade --install sms ./helm/sms -n $APP_NS \
  --set frontend.replicas=2 \
  --set backend.replicas=2 \
  --set backend.canaryReplicas=2 \
  --set backend.shadow.replicas=2
```

#### 6.3 Shadow Traffic

Shadow (v3) is always enabled and receives mirrored traffic:

```yaml
backend:
  shadow:
    enabled: true
    replicas: 1
```

**How shadow works:**
- Shadow (v3) is a **separate deployment** that runs continuously
- Istio mirrors **all traffic** (from both v1 and v2) to v3
- Shadow processes requests but its responses are **discarded**
- Users never see shadow responses (zero impact)
- This enables safe testing of new models in production

**Expected metrics:** `shadow_requests ≈ v1_requests + v2_requests`

**To disable shadow:**
```bash
helm upgrade --install sms ./helm/sms -n $APP_NS \
  --set backend.shadow.enabled=false
```

#### 6.4 Enable/Disable Monitoring

```yaml
monitoring:
  enabled: true
```

**To disable monitoring resources:**
```bash
helm upgrade --install sms ./helm/sms -n $APP_NS \
  --set monitoring.enabled=false
```

This removes ServiceMonitors, PrometheusRules, and AlertmanagerConfig from deployment.

---

### 7. Verification I: Alerts (A3)

Now that the app is running, we can trigger the monitoring alerts.

**1. Find Service Names:**
Run this to see the exact names of your Prometheus and Alertmanager services:
```bash
kubectl get svc -n $MON_NS
```

**2. Port Forwarding:**

Replace `YOUR_PROMETHEUS_SERVICE_NAME` and `YOUR_ALERTMANAGER_SERVICE_NAME` with the actual names from step 1 (e.g., `sms-monitor-kube-prometheu-prometheus`, `sms-monitor-kube-prometheu-alertmanager`).

** Reminder to add your stack every time you open a new terminal for port forwarding using the commands below**
```bash
export STACK_NAME="sms-monitor"
export APP_NS="sms"
export MON_NS="monitoring"
```

```bash
# Forward Prometheus (e.g., sms-monitor-kube-prometheu-prometheus)
kubectl port-forward -n $MON_NS svc/YOUR_PROMETHEUS_SERVICE_NAME 9090:9090

# Forward Alertmanager (e.g., sms-monitor-kube-prometheu-alertmanager)
kubectl port-forward -n $MON_NS svc/YOUR_ALERTMANAGER_SERVICE_NAME 9093:9093

# Forward Grafana and Get Password
kubectl get secret --namespace $MON_NS $STACK_NAME-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl port-forward -n $MON_NS svc/$STACK_NAME-grafana 3000:80 
```


**Access dashboards:**
- Prometheus: [http://localhost:9090](http://localhost:9090)
- Alertmanager: [http://localhost:9093](http://localhost:9093)
- Grafana: [http://localhost:3000](http://localhost:3000) (username: `admin`, password from command above)

**3. Trigger HighRequestRate Alert:**
Before running the code below, start **minikube tunnel** in a separate terminal and keep it running:

```bash
minikube tunnel
```
Get the External IP of the Istio Ingress Gateway
Wait until 'EXTERNAL-IP' is a real IP and not <pending>
```bash
kubectl get svc -n istio-system istio-ingressgateway
```

Add the entry to your hosts file
Note the External IP from the command above and use the command below to open your host file in edit mode.

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


Send traffic to the Ingress to simulate load. 


* **Linux/Mac:**
```bash
seq 1 200 | xargs -n1 -P10 -I{} bash -c '
  echo "Sending request #{}"
  curl -s -X POST http://sms.test.local/sms \
    -H "Content-Type: application/json" \
    -d "{\"sms\":\"load test message\",\"guess\":\"ham\"}"
  echo ""
'
```

**Verification:**

Check [http://localhost:9090/alerts](http://localhost:9090/alerts) to see the `HighRequestRate` alert fire. You should also receive an email notification.


---

## A4: Istio Service Mesh & Continuous Experimentation

## Part 1: Shadow Launch 

**Goal:** Use V3 (Shadow) and mirror real traffic to it without users knowing.

### 1. Validation
Ensure that `backend.shadow.enabled = true` in values.yaml 

### 2. Generate Traffic
Run this loop to mimic user activity (POST requests). Immediately after running this loop, run step 3 on a new terminal to verify the mirroring.
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
Go to [http://localhost:9090](http://localhost:9090) (Prometheus).

Run this query to verify Shadow (V3) received the mirrored traffic:

```promql
sum by (version) (rate(model_predictions_total[1m]))
```

*You should see shadow traffic rate matching stable traffic rate.*

---

## Part 2: Canary Release (The Experiment)

**Goal:** Release V2 to 10% of users and measure engagement.

### 1. Enable Canary Mode (90/10 Split)
Please note that by default, this is already done from the get-go, so you may not have to run the code below.
```bash
# Apply Canary Split
helm upgrade --install sms ./helm/sms -n sms --set traffic.mode=canary
```

### 2. Test Canary Mode on Mac/Linux(90/10 Split)
```bash
# Should see many v1 headers and very limited amount of v2 headers
for i in {1..20}; do 
  echo -n "Request $i: "
  curl -s -i -X POST http://sms.test.local/sms \
    -H "Content-Type: application/json" \
    -d '{"sms":"canary split 90-10 test","guess":"ham"}' \
  | grep -i "version:"
done
```

### 3. Test Sticky Sessions
```bash
# Should see v2 headers in 10 of the requests.
for i in {1..10}; do
  echo "Canary request $i:"
  curl -s -i \
    -H "Cookie: sms-user=canary" \
    http://sms.test.local/sms | grep -i version
done
```

### 4. Run the Experiment 
Generate the traffic for your Grafana graphs.
Note: Ensure that the host name matches the one in values.yaml
```bash
chmod +x run-experiment.sh
./run-experiment.sh
```

### 5. Verification
Go to [http://localhost:3000](http://localhost:3000).
* **Graph:** User Engagement (Request Rate).
* **Evidence:** Show the Green Line (Stable) high and Yellow Line (Canary) low, running in parallel.

[Note: You may even validate the Shadow Launch through the `SMS Model Overview` dashboard in Grafana with the above experiment. The value `v3 / (v2 + v1)` in this dashboard should be equal to `1`. If the numbers don't match, see [Shadow Traffic Discrepancies](#issue-shadow-traffic-doesnt-equal-v1--v2).]

---


### Discrepancies and Troubleshooting

#### Issue: Alert not firing

**Check:**
```bash
# Verify ServiceMonitor is discovered
kubectl get servicemonitor -n $MON_NS

# Check Prometheus targets
# Go to http://localhost:9090/targets and look for sms-backend
```

**Fix:** Ensure `monitoring.prometheusRelease` in `values.yaml` matches your Prometheus Helm release name (`$STACK_NAME`).

#### Issue: No external IP for Ingress Gateway

**Check:**
```bash
kubectl get svc -n istio-system istio-ingressgateway
```

**Fix:** Ensure `minikube tunnel` is running in a separate terminal.

#### Issue: Requests failing with connection errors

**Check hosts file:**
```bash
cat /etc/hosts | grep sms.test.local
```

**Verify Gateway:**
```bash
kubectl get gateway -n $APP_NS
kubectl get virtualservice -n $APP_NS
```

#### Issue: Shadow traffic not appearing

**Check shadow deployment:**
```bash
kubectl get pods -n $APP_NS -l version=shadow
```

**Verify shadow is enabled in values.yaml:**
```yaml
backend:
  shadow:
    enabled: true
```

**Redeploy if needed:**
```bash
helm upgrade --install sms ./helm/sms -n $APP_NS
```

**Check Istio VirtualService for mirroring:**
```bash
kubectl get virtualservice -n $APP_NS -o yaml | grep -A 5 mirror
```

#### Issue: Shadow traffic doesn't equal v1 + v2

This is expected behavior. Shadow receives **mirrored** traffic which means:
- Shadow processes the same requests as v1 and v2
- Metrics should show: `shadow_count ≈ v1_count + v2_count`
- Small differences are normal due to timing and network conditions

#### Issue: Port forwarding fails

**Ensure environment variables are set:**
```bash
export STACK_NAME="sms-monitor"
export MON_NS="monitoring"
```

**Verify service names match:**
```bash
kubectl get svc -n $MON_NS
```

---

### Reset & Cleanup

To completely reset the environment:

#### Application-only reset (recommended)

Use this when you want to redeploy the app, change traffic modes, replicas, or values.

```bash
# Delete application release
helm uninstall sms -n $APP_NS

# Delete application namespace
kubectl delete namespace $APP_NS
```

#### Full Environment Reset

```bash
# Delete application
helm uninstall sms -n $APP_NS

# Delete monitoring stack
helm uninstall $STACK_NAME -n $MON_NS

# Delete namespaces
kubectl delete namespace $APP_NS
kubectl delete namespace $MON_NS

# Delete Minikube cluster
minikube delete
```

**To start fresh:** Return to Section 2 (Infrastructure Setup).