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

To run a **specific version** (for example, `v1.0.2`), set the `IMAGE_TAG` environment variable when running Compose:

```bash
IMAGE_TAG=v1.0.2 docker compose up --pull always
```



## ⚙️ Environment Variables

### Frontend
| Variable      | Purpose                                    | Default                     |
| ------------- | ------------------------------------------ | --------------------------- |
| `MODEL_HOST`  | URL of model-service inside Docker network | `http://model-service:8081` |
| `SERVER_PORT` | Internal port the frontend binds to        | `8080`                      |


### Model-Service
| Variable           | Purpose                                      | Default                   |
| ------------------ | -------------------------------------------- | ------------------------- |
| `MODEL_PORT`       | Internal port Flask listens on               | `8081`                    |
| `MODEL_URL`        | Public URL of the model artifact             | set in docker-compose.yml |
| `PREPROCESSOR_URL` | Public URL of the preprocessor artifact      | set in docker-compose.yml |
| `MODEL_DIR`        | Directory for downloaded/mounted model files | `/root/sms/output`        |

Override Example:
```bash
MODEL_URL="https://example/model.joblib" \
PREPROCESSOR_URL="https://example/preprocessor.joblib" \
docker compose up -d
```

---

## Test the frontend    

Open:

```bash
http://localhost:8080/sms
```

Submit an SMS message and verify the prediction result.

## Related Repositories

* **`app`**: Contains the Spring Boot frontend application and its Dockerfile.
* **`model-service`**: Contains the Python backend application and its Dockerfile.
* **`lib-version`**: Version-aware Maven Library
