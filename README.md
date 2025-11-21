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


To run a **specific version** (for example, `v1.0.2`), set the `IMAGE_FRONTEND_TAG` or `IMAGE_BACKEND_TAG` environment variable in the .env when running Compose:


## ⚙️ Environment Variables in .env


Defining the purpose of a few variables:

### Frontend
| Variable      | Purpose                                    | Default                     |
| ------------- | ------------------------------------------ | --------------------------- |
| `SERVER_PORT` | Internal port the frontend binds to        | `8080`                      |


### Model-Service
| Variable           | Purpose                                      | Default                   |
| ------------------ | -------------------------------------------- | ------------------------- |
| `MODEL_PORT`       | Internal port Flask listens on               | `8081`                    |
| `MODEL_URL`        | Public URL of the model artifact             | set in docker-compose.yml |
| `PREPROCESSOR_URL` | Public URL of the preprocessor artifact      | set in docker-compose.yml |
| `MODEL_DIR`        | Directory for downloaded/mounted model files | `/root/sms/output`        |


All variables are mentioned and configured in the `.env` file. Create a `.env` file next to the Dockerfile. 


Example `.env`:

```bash
IMAGE_FRONTEND=ghcr.io/doda25-team5/sms-frontend
IMAGE_FRONTEND_TAG=latest

IMAGE_BACKEND=ghcr.io/doda25-team5/sms-backend
IMAGE_BACKEND_TAG=latest

MODEL_DIR=./model-data
MODEL_FILENAME=model.joblib
PREPROCESSOR_FILENAME=preprocessor.joblib

MODEL_URL=https://example/model.joblib
PREPROCESSOR_URL=https://example/preprocessor.joblib

MODEL_PORT=8081
SERVER_PORT=8080
FRONTEND_HOST_PORT=8080
```


---

## Test the frontend    

Open:

```bash
http://localhost:8080/sms
```
Submit an SMS message and verify the prediction result.

## Check the version library

```bash
http://localhost:8080/lib-version
```


## Related Repositories

* **`app`**: Contains the Spring Boot frontend application and its Dockerfile.
* **`model-service`**: Contains the Python backend application and its Dockerfile.
* **`lib-version`**: Version-aware Maven Library
