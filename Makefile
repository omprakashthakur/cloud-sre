.PHONY: help install test build run deploy clean docker-up docker-down terraform-init terraform-plan terraform-apply

# Default target
.DEFAULT_GOAL := help

# Variables
ENVIRONMENT ?= dev
IMAGE_TAG ?= latest
AWS_REGION ?= us-east-1

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo '$(BLUE)Cloud SRE Project - Available Commands$(NC)'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ''

install: ## Install Python dependencies
	@echo '$(BLUE)Installing dependencies...$(NC)'
	cd src/app && python3 -m venv venv && \
	. venv/bin/activate && \
	pip install --upgrade pip && \
	pip install -r requirements.txt
	@echo '$(GREEN)✓ Dependencies installed$(NC)'

test: ## Run tests
	@echo '$(BLUE)Running tests...$(NC)'
	./scripts/test.sh
	@echo '$(GREEN)✓ Tests completed$(NC)'

lint: ## Run linters
	@echo '$(BLUE)Running linters...$(NC)'
	cd src/app && \
	. venv/bin/activate && \
	flake8 . --max-line-length=120 --exclude=venv,__pycache__ && \
	bandit -r . -x ./venv
	@echo '$(GREEN)✓ Linting completed$(NC)'

build: ## Build Docker image
	@echo '$(BLUE)Building Docker image...$(NC)'
	cd src/app && docker build -t ai-data-processor:$(IMAGE_TAG) .
	@echo '$(GREEN)✓ Image built: ai-data-processor:$(IMAGE_TAG)$(NC)'

run-local: ## Run application locally
	@echo '$(BLUE)Starting application locally...$(NC)'
	cd src/app && \
	. venv/bin/activate && \
	python app.py

docker-up: ## Start Docker Compose services
	@echo '$(BLUE)Starting Docker Compose services...$(NC)'
	docker compose -f docker-compose.local.yml up -d
	@echo '$(GREEN)✓ Services started$(NC)'
	@echo 'Application: http://localhost:8080'
	@echo 'Grafana: http://localhost:3000 (admin/admin)'
	@echo 'Prometheus: http://localhost:9090'

docker-down: ## Stop Docker Compose services
	@echo '$(BLUE)Stopping Docker Compose services...$(NC)'
	docker compose -f docker-compose.local.yml down
	@echo '$(GREEN)✓ Services stopped$(NC)'

docker-logs: ## Show Docker Compose logs
	docker compose -f docker-compose.local.yml logs -f

docker-restart: docker-down docker-up ## Restart Docker Compose services

# Terraform commands
terraform-init: ## Initialize Terraform
	@echo '$(BLUE)Initializing Terraform for $(ENVIRONMENT)...$(NC)'
	cd terraform && \
	terraform init -reconfigure \
		-backend-config="bucket=cloud-sre-tfstate-$(ENVIRONMENT)" \
		-backend-config="region=$(AWS_REGION)"
	@echo '$(GREEN)✓ Terraform initialized$(NC)'

terraform-plan: ## Create Terraform plan
	@echo '$(BLUE)Creating Terraform plan for $(ENVIRONMENT)...$(NC)'
	cd terraform && \
	terraform plan \
		-var-file="environments/$(ENVIRONMENT)/terraform.tfvars" \
		-var="image_tag=$(IMAGE_TAG)" \
		-out=tfplan
	@echo '$(GREEN)✓ Plan created$(NC)'

terraform-apply: ## Apply Terraform changes
	@echo '$(BLUE)Applying Terraform for $(ENVIRONMENT)...$(NC)'
	cd terraform && \
	terraform apply -auto-approve tfplan
	@echo '$(GREEN)✓ Infrastructure deployed$(NC)'

terraform-destroy: ## Destroy Terraform infrastructure
	@echo '$(YELLOW)WARNING: This will destroy infrastructure for $(ENVIRONMENT)$(NC)'
	@read -p "Type '$(ENVIRONMENT)' to confirm: " confirm; \
	if [ "$$confirm" = "$(ENVIRONMENT)" ]; then \
		cd terraform && \
		terraform destroy \
			-var-file="environments/$(ENVIRONMENT)/terraform.tfvars" \
			-auto-approve; \
		echo '$(GREEN)✓ Infrastructure destroyed$(NC)'; \
	else \
		echo '$(YELLOW)Cancelled$(NC)'; \
	fi

terraform-output: ## Show Terraform outputs
	@cd terraform && terraform output

# Deployment commands
deploy-staging: ## Deploy to staging
	@echo '$(BLUE)Deploying to staging...$(NC)'
	./scripts/deploy/deploy.sh staging deploy
	@echo '$(GREEN)✓ Deployed to staging$(NC)'

deploy-prod: ## Deploy to production
	@echo '$(BLUE)Deploying to production...$(NC)'
	./scripts/deploy/deploy.sh prod deploy
	@echo '$(GREEN)✓ Deployed to production$(NC)'

deploy-plan-staging: ## Plan staging deployment
	./scripts/deploy/deploy.sh staging plan

deploy-plan-prod: ## Plan production deployment
	./scripts/deploy/deploy.sh prod plan

# AWS/ECR commands
ecr-login: ## Login to ECR
	@echo '$(BLUE)Logging into ECR...$(NC)'
	aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin \
	$$(aws sts get-caller-identity --query Account --output text).dkr.ecr.$(AWS_REGION).amazonaws.com
	@echo '$(GREEN)✓ Logged into ECR$(NC)'

push-image: ecr-login ## Push Docker image to ECR
	@echo '$(BLUE)Pushing image to ECR...$(NC)'
	./scripts/deploy/deploy.sh $(ENVIRONMENT) push
	@echo '$(GREEN)✓ Image pushed$(NC)'

# Monitoring commands
logs-app: ## Show application logs (Docker)
	docker compose -f docker-compose.local.yml logs -f app

logs-prometheus: ## Show Prometheus logs
	docker compose -f docker-compose.local.yml logs -f prometheus

logs-grafana: ## Show Grafana logs
	docker compose -f docker-compose.local.yml logs -f grafana

open-grafana: ## Open Grafana in browser
	@echo '$(BLUE)Opening Grafana...$(NC)'
	@echo 'URL: http://localhost:3000'
	@echo 'Username: admin'
	@echo 'Password: admin'

open-prometheus: ## Open Prometheus in browser
	@echo '$(BLUE)Opening Prometheus...$(NC)'
	@echo 'URL: http://localhost:9090'

# Testing and validation
test-api: ## Test API endpoints
	@echo '$(BLUE)Testing API endpoints...$(NC)'
	@echo 'Health Check:'
	@curl -s http://localhost:8080/health | jq .
	@echo '\nProcess Data:'
	@curl -s -X POST http://localhost:8080/api/v1/process \
		-H "Content-Type: application/json" \
		-d '{"test": "data"}' | jq .
	@echo '$(GREEN)✓ API tests completed$(NC)'

load-test: ## Run basic load test
	@echo '$(BLUE)Running load test...$(NC)'
	@for i in {1..100}; do \
		curl -s -X POST http://localhost:8080/api/v1/process \
			-H "Content-Type: application/json" \
			-d '{"test": "data"}' > /dev/null & \
	done; \
	wait
	@echo '$(GREEN)✓ Load test completed (100 requests)$(NC)'

# Cleanup commands
clean: ## Clean up generated files
	@echo '$(BLUE)Cleaning up...$(NC)'
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name htmlcov -exec rm -rf {} + 2>/dev/null || true
	rm -rf test-results/ terraform/.terraform/ terraform/tfplan
	@echo '$(GREEN)✓ Cleanup completed$(NC)'

clean-docker: ## Remove Docker containers and volumes
	@echo '$(BLUE)Cleaning Docker resources...$(NC)'
	docker compose -f docker-compose.local.yml down -v
	docker system prune -f
	@echo '$(GREEN)✓ Docker cleanup completed$(NC)'

# Development helpers
dev-setup: install docker-up ## Complete development setup
	@echo '$(GREEN)✓ Development environment ready!$(NC)'
	@echo ''
	@echo 'Services:'
	@echo '  - Application: http://localhost:8080'
	@echo '  - Grafana: http://localhost:3000 (admin/admin)'
	@echo '  - Prometheus: http://localhost:9090'
	@echo ''
	@echo 'Next steps:'
	@echo '  make test        # Run tests'
	@echo '  make test-api    # Test API'
	@echo '  make logs-app    # View logs'

status: ## Show service status
	@echo '$(BLUE)Service Status:$(NC)'
	@docker compose -f docker-compose.local.yml ps
