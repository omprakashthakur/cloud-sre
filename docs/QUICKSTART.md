# 🚀 Quick Start Guide - CloudFactory SRE Interview Prep

## Step 1: Initial Setup (5 minutes)

```bash
cd ~/projects/cloud-sre

# Install dependencies and start services
make dev-setup
```

Wait for all services to start. You should see:
- ✅ Application running on port 8080
- ✅ Grafana on port 3000
- ✅ Prometheus on port 9090

## Step 2: Test Locally (2 minutes)

```bash
# Test the API
make test-api

# Check service status
make status

# View application logs
make logs-app
```

## Step 3: Access Monitoring (2 minutes)

### Grafana Dashboard
1. Open: http://localhost:3000
2. Login: `admin` / `admin`
3. Navigate to "AI Data Processor" dashboard
4. Observe metrics updating in real-time

### Prometheus
1. Open: http://localhost:9090
2. Try queries:
   - `http_requests_total`
   - `rate(http_requests_total[1m])`
   - `http_request_duration_seconds`

## Step 4: Run Tests (3 minutes)

```bash
# Run all tests
make test

# Run load test
make load-test

# Watch metrics update in Grafana
```

## Step 5: Cloud Deployment (Optional - 15 minutes)

**Prerequisites:**
- AWS account configured (`aws configure`)
- Sufficient AWS permissions for ECS, ECR, CloudWatch

```bash
# Deploy to staging
make deploy-staging

# Get service URL
cd terraform
terraform output service_url

# Test production endpoint
curl <service_url>/health
```

## Common Commands Cheat Sheet

```bash
# Development
make docker-up          # Start all services
make docker-down        # Stop all services
make run-local          # Run app without Docker
make test              # Run tests
make logs-app          # View app logs

# Monitoring
make open-grafana      # Open Grafana UI
make open-prometheus   # Open Prometheus UI
make test-api          # Test API endpoints
make load-test         # Run load test

# Deployment
make deploy-staging    # Deploy to staging
make deploy-prod       # Deploy to production
make terraform-plan    # Plan infrastructure changes

# Cleanup
make clean             # Clean generated files
make docker-down       # Stop services
```

## Troubleshooting

**Services won't start:**
```bash
# Check if ports are already in use
sudo netstat -tulpn | grep -E '(8080|3000|9090)'

# Stop any conflicting services
make docker-down
docker system prune -f
make docker-up
```

**Tests failing:**
```bash
# Reinstall dependencies
cd src/app
rm -rf venv
make install
```

**Can't access Grafana:**
```bash
# Check if service is running
docker-compose -f docker-compose.local.yml ps

# Restart Grafana
docker-compose -f docker-compose.local.yml restart grafana
```

## Interview Practice Scenarios

### 1. Incident Response (5 minutes)
```bash
# Generate high load
make load-test

# Monitor in Grafana (watch response time increase)
# Check Prometheus alerts
# Analyze logs: make logs-app
```

### 2. Deploy New Version (10 minutes)
```bash
# Make a code change in src/app/app.py
# Test locally
make docker-restart
make test-api

# Deploy to staging
make build IMAGE_TAG=v2.0.0
make deploy-staging IMAGE_TAG=v2.0.0
```

### 3. Debugging Issues (5 minutes)
```bash
# Check health
curl localhost:8080/health

# Check metrics
curl localhost:8080/metrics

# Check logs
make logs-app

# Check Prometheus for anomalies
# Open http://localhost:9090
```

## What to Demonstrate in Interview

✅ **Local development workflow** - Docker Compose, Make commands  
✅ **Testing strategy** - Unit tests, load tests, code quality  
✅ **Monitoring setup** - Prometheus metrics, Grafana dashboards  
✅ **Cloud architecture** - ECS/Fargate, ALB, auto-scaling  
✅ **Infrastructure as Code** - Terraform modules, multi-environment  
✅ **Deployment automation** - CI/CD pipeline, rollback strategy  
✅ **Incident response** - Logs, metrics, debugging  

## Key Talking Points

1. **Observability**: "I set up Prometheus for metrics and Grafana for visualization"
2. **Reliability**: "Auto-scaling based on CPU/memory, health checks for recovery"
3. **Security**: "Non-root containers, security scanning, least privilege IAM"
4. **Efficiency**: "Multi-stage Docker builds, infrastructure as code, automation"
5. **Best Practices**: "12-factor app, structured logging, proper monitoring"

---

## Next Steps

- [ ] Complete local setup
- [ ] Test all API endpoints
- [ ] Review Grafana dashboards
- [ ] Practice deployment scenarios
- [ ] Review architecture diagram
- [ ] Prepare to explain design decisions

**Good luck with your interview! 🎯**
