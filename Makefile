TF_DIR  := terraform
COMPOSE := docker compose -f airflow/docker-compose.yml

.DEFAULT_GOAL := help

.PHONY: help fmt validate lint tf-init tf-plan upload airflow-up airflow-down

help:
	@echo "Targets:"
	@echo "  fmt           terraform fmt (recursive)"
	@echo "  validate      terraform validate (no backend)"
	@echo "  lint          tflint (recursive)"
	@echo "  tf-init       terraform init"
	@echo "  tf-plan       terraform plan"
	@echo "  upload        push source CSVs from data/ to Azure Blob"
	@echo "  airflow-up    start local Airflow (docker compose)"
	@echo "  airflow-down  stop local Airflow"
	@echo ""
	@echo "Note: terraform apply is intentionally not a target (gated, manual Azure consent handoff)."

fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

validate:
	terraform -chdir=$(TF_DIR) init -backend=false
	terraform -chdir=$(TF_DIR) validate

lint:
	cd $(TF_DIR) && tflint --recursive

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-plan:
	terraform -chdir=$(TF_DIR) plan

upload:
	python ingestion/load_to_blob.py

airflow-up:
	$(COMPOSE) up -d

airflow-down:
	$(COMPOSE) down
