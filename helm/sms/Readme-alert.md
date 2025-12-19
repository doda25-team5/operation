
# SMS App Monitoring

## Phase 1: Infrastructure Setup

We use a simple stack name: `sms-monitor`.

**1. Define Stack Name**
```bash
export STACK_NAME="sms-monitor"
```

**2. Clean Start**
```bash
minikube delete && minikube start --cpus=4 --memory=6000 --addons=ingress
```
**3. Install Istio**

```bash
istioctl install --set profile=demo -y
```

**4. Install Monitoring Stack**
```bash
kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install $STACK_NAME prometheus-community/kube-prometheus-stack -n monitoring
```
*(Wait 2-3 minutes. Run `kubectl get pods -n monitoring` to ensure all pods are Running).*

---

## Phase 2: Security (CRITICAL - Do FIRST)

We create the email password secret **before** installing the app. This prevents the "Rejected" error in Alertmanager.

**Action:** Replace the placeholder below.
* `<your_google_app_password>`: Your 16-character Google App Password.


```bash
kubectl create secret generic sms-secrets \
  --from-literal=smtp_pass="<your_google_app_password>" \
  -n monitoring
```

---

## Phase 3: Install Your App

Now we install your chart. Because of your manual edits in Phase 0 (Code Checklist), the monitoring configs will automatically go to the `monitoring` namespace.

**Action:** Replace `<email_address>` with your Gmail.

```bash
helm install sms helm/sms \
  --set monitoring.prometheusRelease=$STACK_NAME \
  --set monitoring.alerts.email.to="<email_address>" \
  --set monitoring.alerts.email.from="<email_address>" \
  --set monitoring.alerts.email.username="<email_address>" \
  --set secrets.create=false
```

---

## Phase 4: Verification (The 6-Terminal Split)

Open **5 NEW terminal tabs** (6 total). This ensures you see errors immediately.

### Terminal 2: Check Config Status
Verify the Operator accepted your config.
```bash
kubectl get alertmanagerconfig -n monitoring sms-alerts -o yaml
```
* **Success:** Scroll to the bottom. It should **NOT** say `Rejected`.

### Terminal 3: Traffic Generator
Run this to trigger the alert (sustained load).
```bash
echo "Sending traffic (3 mins)..."
for i in {1..200}; do 
   curl -s -o /dev/null -X POST -H "Content-Type: application/json" -d '{"sms":"hello"}' http://localhost:8080/sms
   echo " - Request $i sent"
   sleep 1
done
```

### Terminal 4: Frontend Access
Keep the tunnel open for the traffic.
```bash
kubectl port-forward svc/sms-frontend-svc 8080:8080
```

### Terminal 5: Prometheus (The Watcher)
1.  **Find the Service:**
    ```bash
    kubectl get svc -n monitoring
    ```
    *Look for the service ending in `-prometheus` (ignore node-exporter).*
2.  **Run Port Forward:**
    *(Type the name manually below)*
    ```bash
    kubectl port-forward svc/YOUR_PROMETHEUS_SERVICE_NAME 9090:9090 -n monitoring
    ```
3.  **Check:** Go to `http://localhost:9090/alerts`. Watch `HighRequestRate` turn Red.

### Terminal 6: Alertmanager (The Email Sender)
1.  **Find the Service:**
    ```bash
    kubectl get svc -n monitoring
    ```
    *Look for the service ending in `-alertmanager`.*
2.  **Run Port Forward:**
    *(Type the name manually below)*
    ```bash
    kubectl port-forward svc/YOUR_ALERTMANAGER_SERVICE_NAME 9093:9093 -n monitoring
    ```
3.  **Manual Test (Immediate):**
    Run this to test email delivery instantly (v2 API):
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '[{"labels":{"alertname":"ManualTest","severity":"warning","namespace":"monitoring"},"annotations":{"description":"Test"},"generatorURL":"http://localhost:9090/graph"}]' http://localhost:9093/api/v2/alerts
    ```

**Final Success:**
* **Immediate:** You should get a "ManualTest" email.
* **After 2 mins:** You should get a "HighRequestRate" email.
