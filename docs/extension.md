# Extension Proposal: Automated Environment Consistency Validation

## 1. Extension Description
We propose an **Automated Environment Consistency Validation** system for our deployment pipeline.

**Change:** Introduce a validation tool that checks for mismatches in environment variables, image tags, ports, secrets, and URLs across all major configuration sources:
* `docker-compose.yml` (operation)
* `helm/sms/values.yaml` (operation)
* `Vagrantfile` (operation)
* CI/CD workflow files for both frontend and backend:
	* `app/.github/workflows/release.yml` (frontend)
	* `model-service/.github/workflows/build.yml` and `train_and_release.yml` (backend)

**Goal:** Ensure that all environments (local, VM, Kubernetes, CI/CD for both frontend and backend) remain consistent, reducing deployment errors and configuration drift.

**Method:** The tool will parse each config file (including docker-compose.yml, helm values.yaml, Vagrantfile, and both frontend/backend CI/CD workflow files), compare key variables, and generate a report. If inconsistencies are found, deployment will be blocked until resolved. Optionally, the tool can auto-generate a summary table for documentation.

## 2. Hypothesis & Metric
**Hypothesis:** Automated validation of environment consistency will reduce deployment failures and speed up onboarding.

**Metric: Consistency Check Pass Rate**
We define "Consistency" as all key variables matching across config sources.
* **Metric Query:** Number of successful validation runs vs. failures (tracked in CI/CD logs).
* **Success Condition:** No mismatches detected in any deployment pipeline run.
* **Improvement Condition:** Fewer environment-related errors reported by team members.

## 3. Implementation Setup
All major configuration files will be included in the validation process:

### Config Sources
* **Docker Compose:** `docker-compose.yml` (operation)
* **Kubernetes:** `helm/sms/values.yaml` (operation)
* **VM Setup:** `vagrant/Vagrantfile` (operation)
* **CI/CD:**
	* `app/.github/workflows/release.yml` (frontend)
	* `model-service/.github/workflows/build.yml` and `train_and_release.yml` (backend)

### Validation Logic
* **Key Variables:** Image tags, ports, secrets, URLs, replica counts (across all sources).
* **Comparison:** Parse and compare values across all sources.
* **Reporting:** Output a summary table and block deployment if mismatches are found. The report should cover both frontend and backend config sources.

## 4. Decision Process
The validation tool will be integrated into the CI/CD pipeline. Each deployment run will:
1. **Run Consistency Check:**
	* Parse all config files.
	* Compare key variables.
	* **IF** all values match, deployment proceeds.
	* **IF** mismatches are found, deployment is blocked and a report is generated.
2. **Monitor Improvement:**
	* Track reduction in environment-related errors over time.

## 5. Expected Results
* **Consistency:** All environments use matching configuration values.
* **Reliability:** Fewer deployment failures due to config drift.
* **Onboarding:** New team members can set up environments faster and with fewer errors.

## 6. References
* [Environment Consistency in DevOps](https://martinfowler.com/bliki/EnvironmentConsistency.html)
* [Helm Best Practices](https://helm.sh/docs/chart_best_practices/values/)
* [CI/CD Environment Validation](https://docs.github.com/en/actions/learn-github-actions/environment-variables)

## 7. Implementation Steps
1. Identify key variables to validate (image tags, ports, secrets, URLs).
2. Write a script to parse and compare values across `docker-compose.yml`, `values.yaml`, `Vagrantfile`, and workflow files.
3. Integrate the script into the CI/CD pipeline (e.g., as a pre-deploy check).
4. Document the validation process and add a summary table to deployment docs.
