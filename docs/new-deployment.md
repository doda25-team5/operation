# Deployment Overview

This document describes the final deployment structure of the SMS application and explains how requests flow through the system. The goal is to clarify the project setup to an outsider (e.g., a new team member), such that they can understand the overall design and participate in architectural and experimental design discussions.

The documentation focuses on the conceptual deployment structure at the Kubernetes and Istio level. 

---

## 1. Deployment Scope and Assumptions

This document provides a high-level, conceptual overview of the deployed system.

- The focus is on **deployed components, their roles, and their relations**
- Request flow and traffic routing decisions are explained at an abstract level

The deployment uses Kubernetes as the orchestration platform and Istio as the service mesh for traffic management and experimentation.

---

## 2. Deployed Namespaces

### 2.1 Application Namespace (`sms`)

All application-related resources are deployed into the `sms` namespace. This namespace contains:

- Frontend and backend Deployments
- Kubernetes Services exposing these Deployments
- Istio traffic management resources (Gateway, VirtualServices, DestinationRules)
- Observability-related resources such as ServiceMonitors

This namespace represents the complete application deployment and is the primary focus of this document.

### 2.2 Monitoring Namespace (`monitoring`) -- MIGHT NEED TO CHANGE

Observability components are deployed into a separate `monitoring` namespace. This namespace contains:

- Prometheus for metrics collection
- Grafana for metrics visualization

Prometheus scrapes metrics exposed by application services in the `sms` namespace, while Grafana dashboards are used to analyze system behavior and compare experimental results.

### 2.3 Supporting System Namespaces

Additional namespaces exist to support cluster operation, such as:

- Istio control plane namespaces
- Kubernetes system namespaces

These namespaces are required for cluster functionality but are not part of the application deployment itself 

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

This section describes all Kubernetes and Istio resources that make up the SMS deployment.  
For each resource type, we first explain its **role in the system**, followed by a **concrete overview of how it is instantiated in our deployment**.

The goal is to clarify *what exists*, *why it exists*, and *how it contributes to request handling and experimentation*.

### 4.1 Deployments

Kubernetes Deployments are used to manage application workloads and ensure reliable execution of frontend and backend services.

In our deployment:
- Separate Deployments exist for the frontend and backend
- Multiple versions of the frontend (stable and canary) are deployed simultaneously
- Deployments manage pod replicas, updates, and lifecycle

**Frontend Deployments**
- **Stable frontend:** `sms-frontend`  
  Labels: `app: sms-frontend`, `version: v1`
- **Canary frontend:** `sms-frontend-canary`  
  Labels: `app: sms-frontend`, `version: v2`

**Backend Deployments**
- **Stable backend:** `sms-backend`  
  Labels: `app: sms-backend`, `version: v1`
- **Canary backend:** `sms-backend-canary`  
  Labels: `app: sms-backend`, `version: v2`

Version labels are later used by Istio to perform version-aware routing.

### 4.2 Services

Kubernetes Services provide stable network identities and load balancing over pods managed by Deployments.

They decouple service discovery from pod lifecycle and are the main abstraction used by Istio for traffic routing.

**Frontend Service**
- **Service:** `sms-frontend-svc`
- Port: `8080`
- Selector: `app: sms-frontend`
- Role:
  - Exposes the frontend internally within the cluster
  - Load balances traffic across stable and canary frontend pods

**Backend Service**
- **Service:** `sms-backend-svc`
- Port: `8081`
- Selector: `app: sms-backend`
- Role:
  - Exposes the backend internally
  - Only accessible from within the cluster (primarily by the frontend)

### 4.3 Istio Gateway

The Istio Gateway defines how external traffic enters the service mesh.

In this deployment:
- The gateway listens for HTTP traffic on port 80
- It serves as the single external entry point into the cluster
- It forwards traffic into the mesh for further routing decisions

**Gateway Resource**
- **Gateway:** `sms-gateway`
- Accepts HTTP traffic on port 80
- Matches all hosts
- Selects the Istio ingress gateway using the label `istio: ingressgateway`

The Gateway itself does not perform routing; it only admits traffic into the mesh.

### 4.4 Istio VirtualServices

Istio VirtualServices define **how requests are routed once they are inside the service mesh**.  
They are the central component for implementing dynamic routing and experimentation logic.

#### Frontend VirtualService

- **VirtualService:** `sms-frontend`
- Role:
  - Routes external traffic to the frontend service
  - Implements all routing logic for experimentation

Routing capabilities include:
- Host-based routing (e.g., forcing stable or canary versions for grading/debugging)
- Cookie-based routing for sticky sessions
- Traffic splitting for canary experiments (e.g., 90/10 split)
- Traffic mirroring for shadow experiments

All routing decisions for incoming user traffic are taken at this VirtualService.

#### Backend VirtualService

- **VirtualService:** `sms-backend`
- Role:
  - Routes requests from frontend v1/v2 to corresponding backend versions
  - Enables backend versioning consistency during experiments

### 4.5 Istio DestinationRules

DestinationRules define **subsets of a service**, typically corresponding to different versions of an application.

They enable version-aware routing when combined with VirtualServices.

**Frontend DestinationRule**
- **DestinationRule:** `sms-frontend`
- Subsets:
  - `stable` -> `version: v1`
  - `canary` -> `version: v2`

**Backend DestinationRule**
- **DestinationRule:** `sms-backend`
- Subsets:
  - `stable` -> `version: v1`
  - `canary` -> `version: v2`

VirtualServices select these subsets to route traffic to specific versions.

### 4.6 Configuration Resources

Configuration is externalized using ConfigMaps to decouple configuration from container images.

- **Frontend ConfigMap:** `sms-frontend-config`
  - Contains backend host, backend port, and image-related configuration

- **Backend ConfigMap:** `sms-backend-config`
  - Contains model and preprocessing configuration

### 4.7 Monitoring and Observability Resources

Observability is integrated using Prometheus-compatible resources.

- **ServiceMonitor:** `sms-frontend-sm`
  - Enables Prometheus to scrape frontend metrics
  - Matches services with label `app: sms-frontend`

- **PrometheusRule:** `sms-backend-rules`
  - Defines alerting rules for backend behavior

- **AlertmanagerConfig:** `sms-alerts`
  - Configures alert delivery (e.g., email notifications)
  - Deployed in the monitoring namespace

- **Grafana Dashboards ConfigMap:** `sms-grafana-dashboards`
  - Provides predefined dashboards for visualizing metrics
  - Used to compare stable and canary behavior during experiments

### 4.8 Optional and Supporting Resources

- **Optional Ingress:** `sms-frontend-ingress`
  - Used only if NGINX ingress is enabled
  - Not part of the default Istio-based request path

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
