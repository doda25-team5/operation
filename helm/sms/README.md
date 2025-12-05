## Steps for running the kubernetes cluster
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

## Helm chart for SMS app. Usage:
  - helm upgrade --install sms ./ -n default --create-namespace --set ingress.host=sms.test.local
  
### Secrets:
  - Do NOT put secrets in values.yaml. 
  - Create Kubernetes secret instead:  
  kubectl create secret generic sms-secrets --from-literal=smtp_user='<USER>' --from-literal=smtp_pass='<PASS>' -n default
Monitoring:
  Enable with --set monitoring.enabled=true
