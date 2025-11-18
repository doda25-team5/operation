# SMS Checker — Operation Repository

This repository contains the **Docker Compose** setup used to run the complete SMS Checker application, which includes:
* **model-service** (Python backend)
* **frontend** (Spring Boot UI)

---

## Requirements

The following software is required to run the application:
* **Docker**
* **Docker Compose v3+**

---

## ▶ How to Start the Application

From this directory, use the following command to start the services:

```bash
docker compose up --pull always
```

This command will:
* Pull images from **GHCR** (GitHub Container Registry).
* Start the backend on `http://localhost:8081`.
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

To run a **specific version** (for example, `v1.0.2`), set the `IMAGE_TAG` environment variable when running Compose:

```bash
IMAGE_TAG=v1.0.2 docker compose up --pull always
```

This ensures both services use the specified version:
* `ghcr.io/doda25-team5/sms-frontend:v1.0.2`
* `ghcr.io/doda25-team5/sms-backend:v1.0.2`

---

## ⚙️ Environment Variables

### Frontend
* **`MODEL_HOST`**: The backend URL (default: `http://model-service:8081`)
* **`SERVER_PORT`**: The frontend port (default: `8080`)

### Model-Service
* **`MODEL_PORT`**: The backend port (default: `8081`)

---

## Volumes

The backend uses a volume to store or load model files, mapping the host's `./model-data` directory to the container's `/app/output`:

```
./model-data:/app/output
```

**Note:** Place trained model files into the **`model-data`** folder if they need to be loaded by the model-service.

---

## 🔗 Related Repositories

* **`app`**: Contains the Spring Boot frontend application and its Dockerfile.
* **`model-service`**: Contains the Python backend application and its Dockerfile.
