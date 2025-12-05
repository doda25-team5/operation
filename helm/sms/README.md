Helm chart for SMS app. Usage:
  helm upgrade --install sms ./ -n default --create-namespace --set ingress.host=sms.test.local
Secrets:
  Do NOT put secrets in values.yaml. Create Kubernetes secret instead:
  kubectl create secret generic sms-secrets --from-literal=smtp_user='<USER>' --from-literal=smtp_pass='<PASS>' -n default
Monitoring:
  Enable with --set monitoring.enabled=true
