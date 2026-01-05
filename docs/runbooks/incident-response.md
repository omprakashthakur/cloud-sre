# Incident Response Runbook

## Overview
This runbook provides step-by-step procedures for responding to common incidents in the AI Data Processor service.

## Alert Response Matrix

| Alert | Severity | Response Time | Action |
|-------|----------|---------------|--------|
| Service Down | Critical | Immediate | See [Service Down](#service-down) |
| High Error Rate | Warning | 5 minutes | See [High Error Rate](#high-error-rate) |
| High Latency | Warning | 10 minutes | See [High Latency](#high-latency) |
| High CPU/Memory | Warning | 15 minutes | See [Resource Issues](#resource-issues) |

---

## Service Down

### Symptoms
- Service unreachable
- Health check failing
- Prometheus alert: `ServiceDown`

### Diagnosis Steps

1. **Check ECS Service Status**
   ```bash
   aws ecs describe-services \
     --cluster ai-processor-staging \
     --services ai-processor-service-staging
   ```

2. **Check Task Status**
   ```bash
   aws ecs list-tasks \
     --cluster ai-processor-staging \
     --service-name ai-processor-service-staging
   ```

3. **Check Logs**
   ```bash
   aws logs tail /ecs/ai-processor-staging --follow
   ```

### Resolution Steps

**Local Environment:**
```bash
# Check service
make status

# Restart services
make docker-restart

# Check logs
make logs-app
```

**Cloud Environment:**
```bash
# Force new deployment
aws ecs update-service \
  --cluster ai-processor-staging \
  --service ai-processor-service-staging \
  --force-new-deployment

# Or rollback to previous version
cd terraform
terraform apply -var="image_tag=previous-working-tag"
```

### Verification
```bash
# Test health endpoint
curl http://<service-url>/health

# Check metrics
curl http://<service-url>/metrics
```

---

## High Error Rate

### Symptoms
- Error rate > 10%
- Prometheus alert: `HighErrorRate`
- Increased 5XX responses

### Diagnosis Steps

1. **Check Error Types**
   ```bash
   # In Prometheus
   sum by (type) (rate(http_errors_total[5m]))
   ```

2. **Check Recent Logs**
   ```bash
   make logs-app | grep ERROR
   ```

3. **Check Recent Deployments**
   ```bash
   aws ecs describe-services \
     --cluster ai-processor-staging \
     --services ai-processor-service-staging \
     --query 'services[0].deployments'
   ```

### Resolution Steps

1. **If caused by bad deployment:**
   ```bash
   # Rollback to previous version
   cd terraform
   terraform apply -var="image_tag=<previous-stable-tag>"
   ```

2. **If caused by dependency issues:**
   ```bash
   # Check database connectivity
   docker-compose -f docker-compose.local.yml ps
   
   # Restart dependencies
   make docker-restart
   ```

3. **If caused by load:**
   ```bash
   # Scale up manually
   aws ecs update-service \
     --cluster ai-processor-staging \
     --service ai-processor-service-staging \
     --desired-count 5
   ```

### Verification
```bash
# Monitor error rate
watch -n 5 'curl -s http://localhost:9090/api/v1/query?query=rate\(http_errors_total[5m]\)'
```

---

## High Latency

### Symptoms
- P95 latency > 1 second
- Prometheus alert: `HighLatencyP95`
- Slow API responses

### Diagnosis Steps

1. **Check Current Latency**
   ```bash
   # In Prometheus
   histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
   ```

2. **Check Resource Usage**
   ```bash
   # CPU usage
   rate(container_cpu_usage_seconds_total[5m])
   
   # Memory usage
   container_memory_usage_bytes
   ```

3. **Check Database Performance**
   ```bash
   # Local
   docker-compose -f docker-compose.local.yml exec postgres pg_stat_activity
   ```

### Resolution Steps

1. **Scale horizontally:**
   ```bash
   # Increase task count
   aws ecs update-service \
     --cluster ai-processor-staging \
     --service ai-processor-service-staging \
     --desired-count 4
   ```

2. **Scale vertically:**
   ```bash
   # Update task resources
   cd terraform
   terraform apply -var="cpu=512" -var="memory=1024"
   ```

3. **Optimize queries/code:**
   - Review slow endpoints in Grafana
   - Identify bottlenecks
   - Deploy optimized code

### Verification
```bash
# Test response time
time curl http://<service-url>/api/v1/process \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

---

## Resource Issues

### Symptoms
- CPU > 80%
- Memory > 85%
- Container restarts
- Auto-scaling triggered

### Diagnosis Steps

1. **Check Current Resource Usage**
   ```bash
   # Grafana dashboard
   make open-grafana
   
   # Or Prometheus
   avg(rate(container_cpu_usage_seconds_total[5m])) * 100
   container_memory_usage_bytes / container_spec_memory_limit_bytes * 100
   ```

2. **Check for Memory Leaks**
   ```bash
   # Monitor over time
   watch -n 10 'docker stats --no-stream'
   ```

### Resolution Steps

1. **Immediate: Scale horizontally**
   ```bash
   aws ecs update-service \
     --cluster ai-processor-staging \
     --service ai-processor-service-staging \
     --desired-count 5
   ```

2. **Short-term: Scale vertically**
   ```bash
   cd terraform
   terraform apply \
     -var="cpu=512" \
     -var="memory=1024"
   ```

3. **Long-term: Optimize application**
   - Profile code
   - Optimize memory usage
   - Add caching

### Verification
```bash
# Monitor resource usage
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=ai-processor-staging \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

---

## Database Connection Issues

### Symptoms
- Connection timeout errors
- "Too many connections" errors
- Database unavailable

### Diagnosis Steps

1. **Check database status**
   ```bash
   # Local
   docker-compose -f docker-compose.local.yml exec postgres pg_isready
   
   # Check connections
   docker-compose -f docker-compose.local.yml exec postgres \
     psql -U admin -d sre_demo -c "SELECT count(*) FROM pg_stat_activity;"
   ```

2. **Check application logs**
   ```bash
   make logs-app | grep -i "database\|connection\|postgres"
   ```

### Resolution Steps

1. **Restart database**
   ```bash
   docker-compose -f docker-compose.local.yml restart postgres
   ```

2. **Increase connection pool**
   - Update application configuration
   - Redeploy

3. **Check for connection leaks**
   - Review application code
   - Ensure proper connection closing

---

## Deployment Rollback

### When to Rollback
- Critical bugs in production
- High error rates after deployment
- Service degradation
- Security vulnerabilities

### Rollback Procedure

1. **Identify last known good version**
   ```bash
   # List recent deployments
   aws ecs describe-services \
     --cluster ai-processor-prod \
     --services ai-processor-service-prod
   
   # Or check Git tags
   git tag -l --sort=-version:refname | head -5
   ```

2. **Execute rollback**
   ```bash
   cd terraform
   terraform apply -var="image_tag=<previous-stable-tag>"
   ```

3. **Force ECS update**
   ```bash
   aws ecs update-service \
     --cluster ai-processor-prod \
     --service ai-processor-service-prod \
     --force-new-deployment
   ```

4. **Monitor rollback**
   ```bash
   # Watch deployment status
   aws ecs describe-services \
     --cluster ai-processor-prod \
     --services ai-processor-service-prod \
     --query 'services[0].deployments'
   ```

### Verification
```bash
# Check health
curl http://<service-url>/health

# Check error rate
# In Prometheus: rate(http_errors_total[5m])

# Check logs
aws logs tail /ecs/ai-processor-prod --follow
```

---

## Communication Template

### Incident Started
```
🔴 INCIDENT: [Service Down/High Error Rate/etc]
Time: <timestamp>
Environment: <staging/prod>
Impact: <description>
Status: Investigating

Initial observations:
- <observation 1>
- <observation 2>

Next steps:
- <action 1>
- <action 2>
```

### Incident Update
```
🟡 UPDATE: [Incident Name]
Time: <timestamp>
Status: <investigating/identified/mitigating>

Progress:
- <completed action 1>
- <completed action 2>

Current action:
- <current action>

ETA: <estimated resolution time>
```

### Incident Resolved
```
🟢 RESOLVED: [Incident Name]
Time: <timestamp>
Duration: <time>
Status: Resolved

Resolution:
- <what was done>

Root cause:
- <brief description>

Next steps:
- Post-incident review scheduled
- Preventive measures to implement
```

---

## Post-Incident Review

After resolving any incident, conduct a blameless post-mortem:

1. **Timeline of events**
   - When did the incident start?
   - When was it detected?
   - What actions were taken?
   - When was it resolved?

2. **Root cause analysis**
   - What was the underlying cause?
   - Why did monitoring not catch it earlier?
   - What can be improved?

3. **Action items**
   - Immediate fixes
   - Long-term improvements
   - Monitoring enhancements
   - Documentation updates

---

## Emergency Contacts

- **On-call SRE**: [Contact info]
- **DevOps Lead**: [Contact info]
- **AWS Support**: [Support plan details]

## Useful Links

- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- CloudWatch Console: https://console.aws.amazon.com/cloudwatch
- ECS Console: https://console.aws.amazon.com/ecs
- Project Repository: [Git URL]

---

**Last Updated**: January 2026
**Owner**: SRE Team
