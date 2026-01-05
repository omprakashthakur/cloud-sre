# 🎯 Cloud SRE - Quick Reference Card

## 🚀 Getting Started (Copy & Paste)

```bash
cd ~/projects/cloud-sre
make dev-setup        # Start everything
make test-api         # Test it works
make open-grafana     # View monitoring
```

## 📊 Essential URLs

| Service | URL | Login |
|---------|-----|-------|
| Application | http://localhost:8080 | - |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| API Docs | http://localhost:8080/ | - |

## ⚡ Most Used Commands

```bash
# Daily Development
make docker-up           # Start all services
make docker-down         # Stop all services  
make test               # Run tests
make test-api           # Test API endpoints
make logs-app           # View app logs

# Monitoring
make open-grafana       # Open Grafana dashboard
make open-prometheus    # Open Prometheus
make load-test          # Run load test

# Deployment
make build              # Build Docker image
make deploy-staging     # Deploy to staging
make terraform-plan     # Plan infrastructure

# Troubleshooting
make status             # Check service status
make docker-restart     # Restart all services
make clean              # Clean up files
```

## 🔌 API Endpoints

```bash
# Health Check
curl http://localhost:8080/health

# Process Single Item
curl -X POST http://localhost:8080/api/v1/process \
  -H "Content-Type: application/json" \
  -d '{"data": "test"}'

# Batch Process
curl -X POST http://localhost:8080/api/v1/batch \
  -H "Content-Type: application/json" \
  -d '{"items": [{"id": 1}, {"id": 2}]}'

# View Metrics
curl http://localhost:8080/metrics

# Service Status
curl http://localhost:8080/api/v1/status
```

## 📈 Key Prometheus Queries

```promql
# Request rate (per minute)
rate(http_requests_total[1m]) * 60

# Error rate
rate(http_errors_total[5m])

# P95 Latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Active connections
active_connections

# Processing time
histogram_quantile(0.95, rate(data_processing_duration_seconds_bucket[5m]))
```

## 🎯 Interview Demo Flow

### 1. Show Local Development (5 min)
```bash
make dev-setup          # Start everything
make status             # Show services
make test-api           # Demonstrate API
make open-grafana       # Show monitoring
```

### 2. Explain Architecture (5 min)
- Point to docker-compose.local.yml
- Explain service communication
- Discuss monitoring strategy
- Show Terraform for cloud

### 3. Demonstrate Testing (3 min)
```bash
make test              # Show unit tests
make load-test         # Show load testing
# Show results in Grafana
```

### 4. Show Cloud Deployment (5 min)
```bash
# Show Terraform code
cat terraform/main.tf

# Explain deployment
./scripts/deploy/deploy.sh staging deploy

# Show monitoring integration
```

### 5. Incident Response (5 min)
```bash
# Simulate incident
docker-compose -f docker-compose.local.yml stop app

# Show detection
make open-grafana      # Show alerts

# Fix it
make docker-restart

# Verify
make test-api
```

## 🛠️ Troubleshooting Quick Fixes

```bash
# Services won't start
make clean-docker
make docker-up

# Port conflicts
sudo netstat -tulpn | grep -E '(8080|3000|9090)'
# Kill conflicting process or change ports

# Tests failing
cd src/app
rm -rf venv
make install

# Can't access Grafana
docker-compose -f docker-compose.local.yml restart grafana

# Fresh start
make clean
make docker-down
docker system prune -f
make dev-setup
```

## 📚 Key Files to Know

```
README.md                          # Project overview
SETUP_COMPLETE.md                  # This guide
docs/QUICKSTART.md                 # Quick start
docs/runbooks/incident-response.md # Incident procedures

src/app/app.py                     # Application code
docker-compose.local.yml           # Local stack
Makefile                           # All commands

terraform/main.tf                  # Infrastructure
terraform/modules/*/               # Reusable modules
```

## 🎓 Interview Talking Points

### When They Ask About...

**Monitoring:**
- "I use Prometheus for metrics collection"
- "Grafana for visualization"
- "Custom alerts for critical thresholds"
- "CloudWatch for AWS integration"

**Reliability:**
- "Auto-scaling based on CPU/memory"
- "Health checks every 30 seconds"
- "Load balancer distributes traffic"
- "Multi-AZ deployment in production"

**Deployment:**
- "Infrastructure as Code with Terraform"
- "Containerized with Docker"
- "Automated testing before deploy"
- "Rolling deployments with health checks"

**Incident Response:**
- "Comprehensive runbooks"
- "Automated monitoring and alerts"
- "Rollback procedures ready"
- "Post-mortem process"

## 🔥 Demo One-Liner

```bash
# Complete demo in one command chain:
cd ~/projects/cloud-sre && \
make dev-setup && \
sleep 30 && \
make test-api && \
make load-test && \
make open-grafana
```

## 💡 Pro Tips

1. **Before Interview**: Run `make dev-setup` 10 minutes early
2. **During Demo**: Have Grafana open in browser tab
3. **When Explaining**: Reference the code in VS Code
4. **If Asked**: Can show cloud deployment plan
5. **Always**: Mention trade-offs and improvements

## 🎯 Success Checklist

- [ ] All services start successfully
- [ ] Can access Grafana (admin/admin)
- [ ] API responds to test requests
- [ ] Tests pass (`make test`)
- [ ] Load test runs successfully
- [ ] Can explain architecture diagram
- [ ] Know where runbook is
- [ ] Can show Terraform code
- [ ] Understand auto-scaling config
- [ ] Ready to discuss improvements

## 📞 If Things Go Wrong

1. **Stay calm** - This happens in production too
2. **Check logs** - `make logs-app`
3. **Check status** - `make status`
4. **Restart services** - `make docker-restart`
5. **Explain the debug process** - Shows SRE thinking

---

## 🚀 Quick Start Reminder

```bash
cd ~/projects/cloud-sre
make dev-setup
make test-api
make open-grafana
```

**That's it! You're ready! 💪**

---

**Last Updated**: January 2026  
**For**: CloudFactory SRE Interview Preparation
