# Knowledge Catalog - Metadata Engine (`kc-metadata-engine-v2`)

This repository acts as the automated GitOps bridge for our Data Governance architecture. It dynamically reads the governance logic (YAML) from the App Governance repository and maps it to the blueprints in the Infrastructure Hub using Terraform and GitHub Actions.

## 📌 Overview
This engine eliminates the need for manual metadata entry in the Google Cloud Console. It uses Terraform's `yamldecode` function to parse external YAML dictionaries and `for_each` loops to dynamically generate `google_dataplex_entry` resources with their attached aspects.

## 🏗️ Architecture & CI/CD Pipeline

This repository is fully automated via GitHub Actions and authenticates securely to Google Cloud using **Workload Identity Federation (WIF)**. 

### 1. The Plan Phase (`terraform-plan.yml`)
* **Trigger:** Automatically runs when a Pull Request is opened against the `main` or `dev` branch.
* **Action:** Checks out both this engine code *and* the remote `kc-app-governance-v2` YAML repository. It initializes the remote backend and runs `terraform plan`.
* **Result:** Provides a safe, read-only preview in the PR comments of exactly what metadata will be added, changed, or destroyed in Dataplex.

### 2. The Apply Phase (`terraform-apply.yml`)
* **Trigger:** Automatically runs when code is **merged** into the target branch.
* **Action:** Authenticates via WIF, retrieves the Terraform state, and runs `terraform apply -auto-approve`.
* **Result:** Physically creates or updates the Dataplex Entries and Aspects in the live Google Cloud environment.

## 📂 Repository Structure
* `.github/workflows/`: Contains the CI/CD pipeline definitions (`terraform-plan.yml` and `terraform-apply.yml`).
* `environments/`: Contains the state backend configurations (`backend.tfvars`) and variable definitions (`terraform.tfvars`) isolated by environment (dev, test, prod).
* `locals.tf`: Contains the logic to pull and decode the external `business_rules.yaml` file.
* `main.tf`: Contains the dynamic Terraform generation logic for the Dataplex Entries.
* `provider.tf`: Configures the Google Cloud provider and GCS backend block.
* `variables.tf`: Declares the inputs required to route resources to the correct Google Cloud Project.
