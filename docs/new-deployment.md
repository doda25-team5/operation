# Deployment Overview

This document describes the final deployment structure of the SMS application and explains how requests flow through the system. The goal is to clarify the project setup to an outsider (e.g., a new team member), such that they can understand the overall design and meaningfully participate in architectural and experimental design discussions.

The documentation focuses on the conceptual deployment structure at the Kubernetes and Istio level. 

---

## 1. Deployment Scope and Assumptions

This document provides a high-level, conceptual overview of the deployed system.

- The focus is on **deployed components, their roles, and their relations**
- Request flow and traffic routing decisions are explained at an abstract level

The deployment uses Kubernetes as the orchestration platform and Istio as the service mesh for traffic management and experimentation.

---

## 2. Deployed Namespaces

All application and monitoring related resources are deployed into the `default` namespace. This namespace contains:

- Frontend and backend Deployments
- Kubernetes Services exposing these Deployments
- Istio traffic management resources (Gateway, VirtualServices, DestinationRules)
- Observability-related resources such as ServiceMonitors
- Prometheus for metrics collection
- Grafana for metrics visualization
---

## 3. Application-Level Components (Logical View)

This section describes the logical components of the SMS application, independent of Kubernetes implementation details.

### 3.1 SMS Frontend

The frontend is the user-facing component of the application. It:

- Handles incoming HTTP requests from external users
- Serves the application user interface
- Communicates with the backend service for model predictions

Multiple versions of the frontend (stable and canary) may be deployed simultaneously for experimentation purposes.

### 3.2 SMS Backend

The backend service provides model predictions to the frontend. It:

- Is not directly accessible from outside the cluster
- Only receives traffic from the frontend service
- Exposes an internal HTTP endpoint used for prediction requests

### 3.3 Observability Components (Logical View)

The application exposes metrics that describe its runtime behavior, such as request counts and version-specific interactions. These metrics are collected and visualized to support monitoring and continuous experimentation.

---

## 4. Kubernetes and Istio Resources and Their Roles

This section describes the Kubernetes and Istio resource types used in the deployment and explains how each contributes to the overall system design.

### 4.1 Deployments

Kubernetes Deployments are used to manage application workloads.

- Separate Deployments exist for the frontend and backend services
- The frontend is deployed in multiple versions (e.g., stable and canary)
- Deployments manage replica scaling and pod lifecycle

### 4.2 Services

Kubernetes Services provide stable network identities and load balancing for pods.

- **Frontend Service (`sms-frontend-svc`)**
  - Exposes the frontend application on an internal cluster port
  - Load balances traffic across frontend pods

- **Backend Service (`sms-backend-svc`)**
  - Exposes the backend application internally
  - Is only accessible from within the cluster

### 4.3 Istio Gateway

An Istio Gateway defines how external traffic enters the service mesh.

- The gateway listens for incoming HTTP traffic on port 80
- It serves as the external entry point for all user requests
- Traffic is forwarded from the gateway to the appropriate VirtualService for routing decisions

### 4.4 Istio VirtualService

The VirtualService is responsible for all application-level routing decisions. It defines:

- Host-based routing (e.g., forcing traffic to stable or canary versions)
- Cookie-based routing for sticky sessions
- Traffic splitting for canary experiments (e.g., 90/10 split)
- Traffic mirroring for shadow experiments

Routing decisions are applied per request as traffic flows through the service mesh.

### 4.5 Istio DestinationRule

DestinationRules define subsets of services that correspond to different application versions.

- Frontend subsets represent stable and canary versions
- Subsets are selected by the VirtualService during routing
- DestinationRules enable version-aware traffic management

### 4.6 ServiceMonitors

ServiceMonitors are used to integrate application services with Prometheus.

- They define which services expose metrics
- They specify how Prometheus discovers and scrapes metrics endpoints
- This enables consistent monitoring across application versions
### 4.7 ConfigMaps

Configmaps are used to store non-confidential data in key value pairs. It is used to provide the environment variables for the container images. 

### 4.8 Secrets

Secrets are used to store and manage sensitive information, such as passwords, API tokens, or SSH keys. They help prevent sensitive data from being hard-coded into application images or configuration files.

---

## 4a. Kubernetes and Istio Resources Details

This section provides a concise summary of all resource names, labels, ports, and selectors as defined in the Helm chart templates and values.yaml for the deployment of the SMS application.

### Frontend Resources

- **Deployment (Stable):** `sms-frontend` (app: sms-frontend, version: v1)
- **Deployment (Canary):** `sms-frontend-canary` (app: sms-frontend, version: v2)
- **Service:** `sms-frontend-svc` (port 8080, selector: app: sms-frontend)
- **VirtualService:** `sms-frontend` (routes external traffic to frontend service, supports host-based, cookie-based, canary, and shadow routing)
- **DestinationRule:** `sms-frontend` (subsets: stable [version: v1], canary [version: v2])
- **ConfigMap:** `sms-frontend-config` (contains backend host, port, image tag)

### Backend Resources

- **Deployment (Stable):** `sms-backend` (app: sms-backend, version: v1)
- **Deployment (Canary):** `sms-backend-canary` (app: sms-backend, version: v2)
- **Service:** `sms-backend-svc` (port 8081, selector: app: sms-backend)
- **VirtualService:** `sms-backend` (routes requests from frontend v1/v2 to backend v1/v2)
- **DestinationRule:** `sms-backend` (subsets: stable [version: v1], canary [version: v2])
- **ConfigMap:** `sms-backend-config` (contains model and preprocessor config)

### Ingress and Traffic Management

- **Gateway:** `sms-gateway` (accepts HTTP traffic on port 80 for all hosts, selector: istio: ingressgateway)
- **(Optional) Ingress:** `sms-frontend-ingress` (if enabled, for NGINX ingress)

### Monitoring and Observability

- **ServiceMonitor:** `sms-frontend-sm` (for Prometheus, matches app: sms-frontend)
- **PrometheusRule:** `sms-backend-rules` (alerting rules for backend)
- **AlertmanagerConfig:** `sms-alerts` (email alerting, in monitoring namespace)
- **Secret:** `sms-secrets` (for storing the 16 digit Google app password)
- **Grafana Dashboards ConfigMap:** `sms-grafana-dashboards`

---

## 5. External Access Model

External users access the application through the Istio IngressGateway.

- Requests are sent over HTTP on port 80
- Different hostnames may be used to influence routing behavior
  (e.g., stable-only or canary-only access for grading and debugging)
- No direct external access to backend services is allowed

This access model provides a controlled entry point into the cluster.

---

## 6. Request Flow Through the Cluster

This section explains how requests move through the system under different routing scenarios.

### 6.1 Baseline Request Flow (No Canary)

A typical request follows these steps:

1. A user sends an HTTP request to the application hostname
2. The request enters the cluster via the Istio IngressGateway
3. The Gateway forwards the request to the VirtualService
4. The VirtualService routes the request to the stable frontend service
5. The frontend service load balances the request across frontend pods
6. The frontend communicates with the backend service to retrieve predictions
7. The response is returned to the user

### 6.2 Canary Experiment Request Flow (90/10 Split)

During canary experimentation:

- The VirtualService applies a 90/10 traffic split
- 90% of requests are routed to the stable frontend version
- 10% of requests are routed to the canary frontend version
- Sticky sessions ensure consistent routing for individual users

The routing decision is taken at the VirtualService level.

### 6.3 Shadow Experiment Request Flow

In shadow mode:

- All user traffic is routed to the stable frontend version
- Requests are mirrored to the canary frontend version
- Mirrored requests do not affect the client response

This allows evaluation of new versions without exposing them to users.

---

## 7. Continuous Experimentation Design

The deployment supports continuous experimentation through canary and shadow deployments.

- Canary experiments compare stable and new frontend versions under real traffic
- Shadow experiments observe behavior without impacting users
- Metrics collected during experiments are used to evaluate performance and behavior differences

---

## 8. Observability and Metrics Flow

Metrics flow through the system as follows:

1. Frontend and backend pods expose metrics via HTTP endpoints
2. Prometheus scrapes these metrics using ServiceMonitors
3. Metrics are stored and queried by Prometheus
4. Grafana dashboards visualize metrics and compare experimental variants

This observability setup enables data-driven evaluation of deployment changes.
---
## 9. Metrics

### Frontend Metrics Overview

- **Frontend Processing Requests (Absolute)**  
  Shows the current number of SMS requests that actively being processed by different front-end versions.

- **Request Rate (Relative)**  
  Displays the per-second rate of incoming SMS requests over time, broken down by frontend version.

- **Total Requests (Absolute)**  
  Tracks the total number of SMS requests grouped by version.

- **Spam vs Ham Rate (Relative)**  
  Shows the classification rate of SMS messages as spam or ham over time among different application versions.

- **SMS Input Length Distribution (Absolute)**  
  Visualizes the SMS messages by input length buckets over the selected interval.

- **SMS Input Length Distribution (Relative)**  
  Shows the rate at which SMS messages of different input lengths are received, highlighting changes in message size patterns over time.
#### SMS Backend Metrics Overview

- **Model File Size (bytes)**  
  Shows the size of each deployed model file in bytes, grouped by model version.

- **Total Predictions per Version**  
  Tracks the cumulative number of predictions made by each model version over time.

- **P95 Prediction Latency**  
  Displays the 95th percentile of model prediction latency over time for each version.

- **Shadow Consistency Ratio**  
  Compares the number of predictions made by the shadow model (v3) against the combined predictions of models stable (v1) and canary (v2), used to validate shadow traffic alignment.
#### A4 Continuous Experimentation – UI Engagement Test Metrics

- **Request Rate per Version (Key Metric)**  
  Shows the per-second request rate for v1 and v2; v2 should exceed v1 despite receiving only 10% of traffic if the new UI drives higher per-user engagement.

- **Engagement Multiplier**  
  Normalizes request rates by traffic allocation to estimate per-user engagement, where values greater than 1 indicate v2 users are more engaged than v1 users.

- **Decision Recommendation**  
  Provides an automated accept/reject recommendation based on the engagement multiplier, translating the metric into a decision.

- **Ham vs Spam Classification Rate**  
  Compares spam and ham classification rates between versions to ensure the UI change does not introduce unintended changes in model behavior.

- **Total Requests per Version (Cumulative)**  
  Displays cumulative request volume over time for each version, helping visualize whether v2 overtakes v1 as engagement increases.

- **P95 Latency per Version (Safety Metric)**  
  Tracks the 95th percentile frontend request latency for each version to confirm that the new UI does not degrade performance.


## 9. Deployment Diagrams

### 9.1 Overall Deployment Structure

> **Figure 1: Deployment Structure and Request Flow of the SMS Application**

![Deployment Structure and Request Flow](./images/sms-deploy-diagram.png)

The diagram illustrates:
- External traffic entering through the Istio IngressGateway
- Routing decisions taken at the VirtualService
- Traffic flow to frontend and backend services
- Canary and shadow routing paths

### 9.2 Request Flow Variant

Additional annotations may be used to highlight:
- Stable request paths
- Canary request paths
- Shadow traffic mirroring

---

## 10. Summary for New Team Members

In summary:

- External traffic enters through the Istio IngressGateway
- Routing decisions are centralized in the VirtualService
- Canary and shadow experiments are implemented using Istio traffic management
- Metrics are collected via Prometheus and visualized in Grafana

After reading this document, a new team member should be able to understand the deployment structure, reason about request flow, and participate in discussions about routing and experimentation design.
