# Cloud SRE - AI Data Processor

> **Complete SRE demonstration project** featuring microservices, monitoring, infrastructure as code, and cloud deployment for CloudFactory interview preparation.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.9+-green.svg)](https://www.python.org/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple.svg)](https://www.terraform.io/)

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[README.md](README.md)** *(this file)* | Complete setup and usage guide |
| **[SETUP_COMPLETE.md](SETUP_COMPLETE.md)** | Setup status and next steps |
| **[CHANGELOG.md](CHANGELOG.md)** | Version history and changes |
| **[FIXES_APPLIED.md](FIXES_APPLIED.md)** | Detailed fix documentation |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Command quick reference |
| **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** | Complete documentation guide |

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Local Development](#local-development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [Interview Preparation](#interview-preparation)

## 🎯 Overview

This project demonstrates a **production-grade SRE workflow** from local development to cloud deployment. It includes:

- **AI Data Processing Service** - RESTful API built with Flask
- **Complete Observability** - Prometheus, Grafana, CloudWatch
- **Infrastructure as Code** - Terraform for AWS ECS/Fargate
- **CI/CD Pipeline** - Automated testing and deployment
- **Container Orchestration** - Docker Compose (local) and ECS (cloud)
- **Auto-scaling** - Based on CPU and memory metrics

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Cloud (AWS)                             │
│  ┌────────────┐    ┌──────────────┐   ┌─────────────┐     │
│  │    ALB     │───▶│  ECS/Fargate │──▶│     ECR     │     │
│  └────────────┘    └──────────────┘   └─────────────┘     │
│        │                   │                                │
│        │           ┌───────▼────────┐                      │
│        │           │   CloudWatch    │                      │
│        │           │   Monitoring    │                      │
│        │           └────────────────┘                      │
└────────┼───────────────────────────────────────────────────┘
         │
    ┌────▼─────┐
    │  Users   │
    └──────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Local Development                          │
│  ┌──────┐  ┌────────┐  ┌────────────┐  ┌──────────┐       │
│  │ App  │──│ Redis  │  │ PostgreSQL │  │  Nginx   │       │
│  └───┬──┘  └────────┘  └────────────┘  └──────────┘       │
│      │                                                       │
│  ┌───▼──────────┐        ┌───────────┐                     │
│  │  Prometheus  │───────▶│  Grafana  │                     │
│  └──────────────┘        └───────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

## ✨ Features

### Application
- ✅ RESTful API with Flask
- ✅ Data processing simulation
- ✅ Batch processing support
- ✅ Health check endpoints
- ✅ JSON structured logging
- ✅ Prometheus metrics export

### Monitoring & Observability
- ✅ Prometheus for metrics collection
- ✅ Grafana dashboards
- ✅ CloudWatch integration
- ✅ Custom alerts and alarms
- ✅ Application Performance Monitoring (APM)

### Infrastructure
- ✅ Infrastructure as Code (Terraform)
- ✅ AWS ECS with Fargate
- ✅ Application Load Balancer
- ✅ Auto-scaling policies
- ✅ Multi-environment support (staging/prod)

### DevOps
- ✅ Docker containerization
- ✅ Docker Compose for local dev
- ✅ Automated testing
- ✅ Deployment automation
- ✅ Security scanning

## 📦 Prerequisites

### Required Software
- **Docker** 20.10+ and Docker Compose
- **Python** 3.9+
- **Terraform** 1.5+
- **AWS CLI** 2.0+
- **Git**
- **Make** (optional, for convenience)

### Installation

**Ubuntu/Debian:**
```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### AWS Setup
```bash
# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (us-east-1)
```

## 🚀 Quick Start

### 1. Clone and Setup
```bash
cd ~/projects/cloud-sre
make dev-setup
```

This will:
- Install Python dependencies
- Start all Docker services
- Initialize the development environment

### 2. Verify Services
```bash
# Check service status
make status

# Test the API
make test-api
```

### 3. Access Services
- **Application**: http://localhost:8080
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090

## 💻 Local Development

### Start Services
```bash
# Start all services
make docker-up

# View logs
make logs-app

# Stop services
make docker-down
```

### Run Application Locally (without Docker)
```bash
make install
make run-local
```

### Test API Endpoints

**Health Check:**
```bash
curl http://localhost:8080/health
```

**Process Data:**
```bash
curl -X POST http://localhost:8080/api/v1/process \
  -H "Content-Type: application/json" \
  -d '{"data": "test", "value": 123}'
```

**Batch Processing:**
```bash
curl -X POST http://localhost:8080/api/v1/batch \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"id": 1, "value": "data1"},
      {"id": 2, "value": "data2"}
    ]
  }'
```

**View Metrics:**
```bash
curl http://localhost:8080/metrics
```

## 🧪 Testing

### Run All Tests
```bash
make test
```

### Run Specific Tests
```bash
# Unit tests only
cd src/app && python -m pytest tests/unit/ -v

# With coverage
cd src/app && python -m pytest --cov=. --cov-report=html

# Linting
make lint
```

### Load Testing
```bash
make load-test
```

## 🚀 Deployment

### Deploy to Staging
```bash
# Plan deployment
make deploy-plan-staging

# Deploy
make deploy-staging ENVIRONMENT=staging
```

### Deploy to Production
```bash
# Plan deployment
make deploy-plan-prod

# Deploy
make deploy-prod ENVIRONMENT=prod
```

### Manual Deployment Steps

**1. Initialize Terraform:**
```bash
make terraform-init ENVIRONMENT=staging
```

**2. Build and Push Docker Image:**
```bash
make build IMAGE_TAG=v1.0.0
make ecr-login
make push-image ENVIRONMENT=staging IMAGE_TAG=v1.0.0
```

**3. Deploy Infrastructure:**
```bash
make terraform-plan ENVIRONMENT=staging IMAGE_TAG=v1.0.0
make terraform-apply ENVIRONMENT=staging
```

**4. Verify Deployment:**
```bash
# Get service URL
make terraform-output

# Test deployment
SERVICE_URL=$(cd terraform && terraform output -raw service_url)
curl $SERVICE_URL/health
```

## 📊 Monitoring

### Local Monitoring

**Grafana Dashboards:**
```bash
make open-grafana
# Login: admin/admin
# Navigate to "AI Data Processor" dashboard
```

**Prometheus:**
```bash
make open-prometheus
# Query metrics: http_requests_total, http_request_duration_seconds
```

### Cloud Monitoring (AWS)

**CloudWatch Dashboards:**
```bash
# Get dashboard URL
cd terraform
terraform output cloudwatch_dashboard_url
```

**View Logs:**
```bash
# Application logs
aws logs tail /ecs/ai-processor-staging --follow

# ECS service events
aws ecs describe-services \
  --cluster ai-processor-staging \
  --services ai-processor-service-staging
```

### Key Metrics

- **Request Rate**: `rate(http_requests_total[1m])`
- **Error Rate**: `rate(http_errors_total[5m])`
- **Latency P95**: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
- **Processing Time**: `data_processing_duration_seconds`

## 📁 Project Structure

```
cloud-sre/
├── src/
│   ├── app/                    # Application code
│   │   ├── app.py             # Main Flask application
│   │   ├── Dockerfile         # Production Dockerfile
│   │   ├── Dockerfile.dev     # Development Dockerfile
│   │   └── requirements.txt   # Python dependencies
│   └── monitoring/            # Monitoring configuration
│       ├── prometheus/        # Prometheus config
│       ├── alerts/           # Alert rules
│       └── dashboards/       # Grafana dashboards
├── terraform/                 # Infrastructure as Code
│   ├── main.tf               # Main Terraform config
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output values
│   ├── modules/              # Terraform modules
│   │   ├── ecr/             # ECR repository
│   │   ├── ecs/             # ECS cluster and service
│   │   └── monitoring/      # CloudWatch monitoring
│   └── environments/         # Environment configs
│       ├── staging/
│       └── prod/
├── scripts/                   # Automation scripts
│   ├── deploy/               # Deployment scripts
│   │   └── deploy.sh        # Main deployment script
│   ├── test.sh              # Test runner
│   └── monitor/             # Monitoring scripts
├── tests/                     # Test suite
│   ├── unit/                 # Unit tests
│   ├── integration/          # Integration tests
│   └── load/                 # Load tests
├── docs/                      # Documentation
│   ├── architecture/         # Architecture diagrams
│   ├── runbooks/            # Operational runbooks
│   └── api/                 # API documentation
├── docker-compose.local.yml  # Local development stack
├── nginx.conf                # Nginx configuration
├── Makefile                  # Build automation
└── README.md                 # This file
```

## 🎓 Interview Preparation

### Key SRE Concepts Demonstrated

1. **Infrastructure as Code**
   - Terraform modules and best practices
   - Multi-environment management
   - State management

2. **Containerization**
   - Multi-stage Dockerfile
   - Docker Compose for local development
   - Container security best practices

3. **Monitoring & Observability**
   - Metrics collection (Prometheus)
   - Visualization (Grafana)
   - Alerting and incident response
   - Structured logging

4. **Cloud Architecture**
   - Microservices design
   - Load balancing
   - Auto-scaling
   - High availability

5. **DevOps Practices**
   - CI/CD automation
   - Testing strategies
   - Deployment automation
   - Rollback procedures

### Common Interview Questions

**Q: How do you ensure high availability?**
- Multiple availability zones
- Auto-scaling based on metrics
- Health checks and auto-recovery
- Load balancing across instances

**Q: How do you monitor service health?**
- Prometheus metrics collection
- Grafana dashboards for visualization
- CloudWatch alarms for critical metrics
- Application logging with structured format

**Q: How do you handle deployments?**
- Blue-green deployments via ECS
- Rolling updates with health checks
- Automated rollback on failures
- Canary deployments for gradual rollout

**Q: How do you debug production issues?**
- CloudWatch log aggregation
- Distributed tracing
- Metrics analysis
- Health check endpoints

### Hands-On Practice Scenarios

1. **Simulate an Incident**
   ```bash
   # Generate high load
   make load-test
   
   # Monitor metrics
   make open-grafana
   
   # Check alerts
   make logs-prometheus
   ```

2. **Scale the Service**
   ```bash
   # Modify desired count
   cd terraform
   terraform apply -var="desired_count=5"
   ```

3. **Deploy a New Version**
   ```bash
   # Build new image
   make build IMAGE_TAG=v2.0.0
   
   # Deploy
   make deploy-staging IMAGE_TAG=v2.0.0
   ```

4. **Respond to an Alert**
   ```bash
   # Check logs
   make logs-app
   
   # Check metrics
   curl localhost:9090/api/v1/query?query=http_errors_total
   
   # Restart service
   make docker-restart
   ```

## 🛠️ Troubleshooting

### Common Issues & Solutions

#### ❌ Issue: `docker-compose: command not found`
**Cause**: System uses Docker Compose v2 (integrated into Docker CLI)  
**Solution**: All commands updated to use `docker compose` instead of `docker-compose`
```bash
# ✅ Correct (v2)
docker compose up -d
docker compose ps
docker compose logs app

# ❌ Old syntax (v1)
docker-compose up -d
```
**Status**: ✅ Fixed in Makefile and all scripts

---

#### ❌ Issue: `ModuleNotFoundError: No module named 'pythonjsonlogger'`
**Cause**: Package name mismatch between pip and import statement  
**Solution**: Removed dependency, using standard Python logging
```python
# ✅ New implementation (standard library)
import logging
formatter = logging.Formatter(
    '{"time": "%(asctime)s", "level": "%(levelname)s", "message": "%(message)s"}'
)

# ❌ Old implementation (removed)
from pythonjsonlogger import jsonlogger
```
**Status**: ✅ Fixed in [src/app/app.py](src/app/app.py)

---

#### ❌ Issue: `psycopg2-binary` build fails
**Cause**: Missing PostgreSQL development libraries (`libpq-dev`, `gcc`)  
**Solution**: Commented out for local dev (Docker image has it pre-installed)
```txt
# requirements.txt
flask>=2.3.0
prometheus-client>=0.17.0
# psycopg2-binary>=2.9.0  # Commented: Docker image includes this
```
**Note**: Only affects local Python environment, not Docker containers  
**Status**: ✅ Fixed in [requirements.txt](requirements.txt)

---

#### ⚠️ Warning: `version` field is obsolete
**Cause**: Docker Compose v2 doesn't use version field  
**Solution**: Removed from docker-compose.local.yml
```yaml
# ✅ New format (no version)
services:
  app:
    build: .

# ❌ Old format
version: '3.8'
services:
  app:
    build: .
```
**Status**: ✅ Fixed in [docker-compose.local.yml](docker-compose.local.yml)

---

### Local Development Issues

**Docker services won't start:**
```bash
# Check Docker daemon
sudo systemctl status docker

# Check ports in use
sudo ss -tulpn | grep -E '(8080|3000|9090|5432|6379)'

# Clean and restart
make clean-docker
make docker-up

# Force rebuild if needed
docker compose -f docker-compose.local.yml up --build -d
```

**Application errors:**
```bash
# Check logs for all services
make logs-app
docker compose -f docker-compose.local.yml logs

# Check specific service
docker compose -f docker-compose.local.yml logs app
docker compose -f docker-compose.local.yml logs postgres

# Check container health
docker compose -f docker-compose.local.yml ps

# Rebuild app container
docker compose -f docker-compose.local.yml up --build app -d
```

**Requirements installation fails:**
```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y python3-dev libpq-dev gcc

# For Docker builds (already handled)
# Just rebuild: docker compose -f docker-compose.local.yml up --build -d
```

**Port already in use:**
```bash
# Find process using port 8080
sudo ss -tulpn | grep 8080

# Kill process if needed
sudo kill -9 <PID>

# Or change port in docker-compose.local.yml
ports:
  - "8081:8080"  # Use 8081 on host instead
```

### Deployment Issues

**Terraform errors:**
```bash
# Reinitialize
make terraform-init ENVIRONMENT=staging

# Check AWS credentials
aws sts get-caller-identity

# Validate configuration
cd terraform && terraform validate
```

**ECS deployment fails:**
```bash
# Check ECS service
aws ecs describe-services --cluster ai-processor-staging --services ai-processor-service-staging

# Check task logs
aws logs tail /ecs/ai-processor-staging --follow

# Check target group health
aws elbv2 describe-target-health --target-group-arn <arn>
```

### Monitoring Issues

**Grafana can't connect to Prometheus:**
```bash
# Check Prometheus is running
docker compose -f docker-compose.local.yml ps prometheus
curl http://localhost:9090/-/healthy

# Add data source in Grafana
# URL: http://prometheus:9090
# Access: Server (default)
```

**Metrics not showing:**
```bash
# Check app is exposing metrics
curl http://localhost:8080/metrics

# Check Prometheus targets
# Open: http://localhost:9090/targets
# Should see: app:8080 with state=UP
```

---

### 📋 Quick Reference

| Service    | Local URL                  | Docker Service Name |
|------------|----------------------------|---------------------|
| App API    | http://localhost:8080      | app                 |
| Grafana    | http://localhost:3000      | grafana             |
| Prometheus | http://localhost:9090      | prometheus          |
| Nginx      | http://localhost:80        | nginx               |
| PostgreSQL | localhost:5432             | postgres            |
| Redis      | localhost:6379             | redis               |

**Default Credentials:**
- Grafana: admin / admin (change on first login)

**Useful Commands:**
```bash
# View all logs
docker compose -f docker-compose.local.yml logs -f

# Restart single service
docker compose -f docker-compose.local.yml restart app

# Check service health
curl http://localhost:8080/health

# Run tests
make test-api
make load-test
```

---

**For detailed fix information, see [CHANGELOG.md](CHANGELOG.md)**

## 🤝 Contributing

This is a personal project for interview preparation, but suggestions are welcome!

## 📝 License

MIT License - feel free to use this project for your own learning and interview preparation.

## 📞 Contact

**Your Name** - Preparing for CloudFactory Nepal SRE Position

---

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Site Reliability Engineering Book](https://sre.google/books/)

---

**Good luck with your CloudFactory interview! 🚀**

### Next Steps for Interview Prep

1. ✅ Complete the setup (`make dev-setup`)
2. ✅ Test locally (`make test-api`)
3. ✅ Deploy to staging (`make deploy-staging`)
4. ✅ Practice incident response scenarios
5. ✅ Review monitoring dashboards
6. ✅ Prepare to explain architecture decisions
# cloud-sre
