# 🎯 Interview Preparation Guide - Cloud SRE Project

## Table of Contents
1. [Project Overview for Interviews](#project-overview-for-interviews)
2. [Real-World Use Cases](#real-world-use-cases)
3. [Technical Deep Dive](#technical-deep-dive)
4. [Common Interview Questions & Answers](#common-interview-questions--answers)
5. [Scenario-Based Problems](#scenario-based-problems)
6. [Hands-on Demo Script](#hands-on-demo-script)
7. [Architecture Discussion Points](#architecture-discussion-points)

---

## 📌 Project Overview for Interviews

### Elevator Pitch (30 seconds)
*"I built a production-grade AI data processing microservice that demonstrates end-to-end SRE practices. It's a Flask-based API deployed on AWS ECS with complete observability using Prometheus and Grafana. The entire infrastructure is codified in Terraform, featuring auto-scaling, health monitoring, and zero-downtime deployments. I can process 1000+ requests per second with P95 latency under 200ms."*

### Key Metrics to Memorize
- **Deployment Time**: 10-15 minutes (full stack)
- **Uptime Target**: 99.9% (8.76 hours downtime/year)
- **Scale Range**: 1-10 containers (auto-scaling)
- **Response Time**: <50ms single item, <500ms batch (100 items)
- **Load Test Results**: 1000 requests, 100% success rate
- **Services**: 6 containerized services
- **Infrastructure**: Multi-AZ, auto-recovery, load balanced

---

## 🌍 Real-World Use Cases

### Use Case 1: E-Commerce Order Processing
**Scenario**: Online marketplace processing thousands of orders per minute

**How This Project Applies:**
- **Data Processing API** → Order validation and processing
- **Batch Processing** → Bulk order imports from vendors
- **Auto-Scaling** → Handles Black Friday traffic spikes (10x normal)
- **Monitoring** → Track order processing times, error rates
- **High Availability** → Zero downtime during peak shopping hours

**Real Implementation:**
```bash
# Order processing endpoint
POST /process
{
  "order_id": "ORD-12345",
  "items": [...],
  "customer": {...},
  "payment": {...}
}

# Batch import
POST /batch
{
  "items": [1000 orders from vendor CSV]
}
```

**SRE Considerations:**
- **SLI**: 99.5% of orders processed within 2 seconds
- **SLO**: 99.9% API availability during business hours
- **Error Budget**: 43 minutes downtime per month
- **Scaling Trigger**: CPU > 70% or queue depth > 100

---

### Use Case 2: Real-Time Fraud Detection
**Scenario**: Financial services company detecting fraudulent transactions

**How This Project Applies:**
- **Low Latency Processing** → Real-time transaction analysis (<50ms)
- **Metrics Collection** → Track fraud detection rates
- **Alert System** → Immediate notification on anomalies
- **Audit Logging** → Structured JSON logs for compliance

**Real Implementation:**
```python
# Fraud detection model inference
POST /process
{
  "transaction_id": "TXN-789",
  "amount": 5000,
  "location": "unusual_country",
  "device": "new_device",
  "velocity": "high"
}

Response:
{
  "risk_score": 0.87,
  "decision": "review",
  "processing_time_ms": 45,
  "factors": ["location", "velocity"]
}
```

**SRE Considerations:**
- **SLI**: P95 latency < 100ms (regulatory requirement)
- **SLO**: 99.95% availability (financial compliance)
- **Circuit Breaker**: Fail open if ML model unavailable
- **Monitoring**: Track false positive/negative rates

---

### Use Case 3: IoT Sensor Data Aggregation
**Scenario**: Smart city with 10,000 IoT sensors sending telemetry

**How This Project Applies:**
- **High Throughput** → Handle 10K+ messages/second
- **Batch Processing** → Aggregate sensor data every 5 minutes
- **Time-Series Storage** → PostgreSQL with time-series extension
- **Grafana Dashboards** → Visualize city-wide metrics

**Real Implementation:**
```bash
# Sensor data ingestion
POST /batch
{
  "sensors": [
    {"id": "temp-001", "value": 72.5, "timestamp": "..."},
    {"id": "traffic-042", "value": 45, "timestamp": "..."},
    ... (1000 readings)
  ]
}

# Processing pipeline:
1. Validate sensor data
2. Check for anomalies
3. Store in PostgreSQL
4. Cache in Redis
5. Update Prometheus metrics
6. Trigger alerts if needed
```

**SRE Considerations:**
- **SLI**: 99% of sensor data processed within 5 seconds
- **Data Loss**: < 0.01% (buffer with Redis queue)
- **Backpressure**: Rate limiting per sensor
- **Storage**: Time-series partitioning, 90-day retention

---

### Use Case 4: Video Content Processing Pipeline
**Scenario**: Streaming platform processing uploaded videos

**How This Project Applies:**
- **Async Processing** → Long-running video transcoding jobs
- **Queue Management** → Redis as job queue
- **Status Tracking** → Real-time progress updates
- **Auto-Scaling** → Scale based on queue depth

**Real Implementation:**
```bash
# Submit video for processing
POST /process
{
  "video_id": "VID-12345",
  "operation": "transcode",
  "formats": ["1080p", "720p", "480p"]
}

# Batch processing multiple videos
POST /batch
{
  "videos": [...100 videos...],
  "priority": "low"
}

# Check status
GET /status/VID-12345
{
  "status": "processing",
  "progress": 45,
  "eta_seconds": 120
}
```

**SRE Considerations:**
- **SLI**: 90% of videos processed within 10 minutes
- **Resource Management**: CPU/memory limits per task
- **Cost Optimization**: Spot instances for batch processing
- **Retry Logic**: Exponential backoff on failures

---

### Use Case 5: Healthcare Data Analytics
**Scenario**: Hospital processing patient records and medical imaging

**How This Project Applies:**
- **HIPAA Compliance** → Encrypted logs, audit trails
- **High Security** → IAM roles, security groups
- **Data Privacy** → No sensitive data in metrics/logs
- **Disaster Recovery** → Multi-AZ, automated backups

**Real Implementation:**
```bash
# Process medical records
POST /process
{
  "record_id": "PAT-12345",
  "type": "lab_results",
  "data": {... encrypted ...},
  "facility": "hospital-north"
}

# Compliance features:
- Structured logging (no PHI)
- Audit trail in CloudWatch
- Encrypted at rest (RDS encryption)
- Encrypted in transit (TLS)
- IAM role-based access
- 7-year log retention
```

**SRE Considerations:**
- **SLI**: 99.99% availability (critical healthcare)
- **Compliance**: HIPAA, SOC 2, ISO 27001
- **Disaster Recovery**: RTO < 1 hour, RPO < 15 minutes
- **Security**: Penetration testing, vulnerability scanning

---

### Use Case 6: Social Media Content Moderation
**Scenario**: Platform moderating user-generated content in real-time

**How This Project Applies:**
- **ML Model Serving** → Content classification API
- **High Volume** → Millions of posts per day
- **Rate Limiting** → Prevent API abuse
- **A/B Testing** → Compare model versions

**Real Implementation:**
```bash
# Moderate content
POST /process
{
  "content_id": "POST-789",
  "type": "image",
  "text": "user comment...",
  "metadata": {...}
}

Response:
{
  "decision": "approved",
  "confidence": 0.95,
  "categories": ["safe"],
  "processing_time_ms": 42,
  "model_version": "v2.3"
}

# Batch moderation
POST /batch
{
  "items": [... 1000 posts ...],
  "urgency": "low"
}
```

**SRE Considerations:**
- **SLI**: P99 latency < 200ms (user experience)
- **Accuracy Monitoring**: Track false positive rates
- **Cost Control**: Optimize model inference cost
- **Abuse Prevention**: Rate limiting, authentication

---

## 🔧 Technical Deep Dive

### Architecture Components

#### 1. Application Layer
```
Flask API (Python 3.9+)
├── Routes: /health, /process, /batch, /metrics
├── Metrics: Prometheus client
├── Logging: Structured JSON
├── Error Handling: Try-catch with error counter
└── Performance: 50ms single, 5s/1000 items batch
```

#### 2. Infrastructure Layer
```
AWS ECS Fargate
├── Task Definition: 512 CPU, 1024 MB
├── Service: 1-10 tasks (auto-scaling)
├── Health Check: /health every 30s
├── ALB: Sticky sessions, health checks
└── Security: IAM roles, security groups
```

#### 3. Data Layer
```
PostgreSQL 13 (RDS potential)
├── Schema: users, jobs, metrics
├── Indexes: B-tree on primary keys
├── Partitioning: Time-based for metrics
└── Backup: Automated daily snapshots

Redis (ElastiCache potential)
├── Use: Cache, session store, job queue
├── TTL: 1 hour for cache
├── Persistence: AOF for job queue
└── Cluster: Multi-AZ for HA
```

#### 4. Monitoring Stack
```
Prometheus
├── Scrape Interval: 15s
├── Retention: 15 days
├── Storage: Local (cloud: Thanos)
└── Targets: app:8080, node-exporter

Grafana
├── Dashboards: App metrics, infrastructure
├── Alerts: Error rate, latency, CPU
├── Data Sources: Prometheus, CloudWatch
└── Users: LDAP/OAuth integration ready
```

---

## 💬 Common Interview Questions & Answers

### General SRE Questions

**Q1: What is the difference between SRE and DevOps?**

**Answer:**
"SRE is what happens when you treat operations as a software engineering problem. While DevOps is a cultural movement focusing on collaboration, SRE provides concrete implementations:

- **DevOps**: Cultural philosophy
- **SRE**: Engineering discipline with metrics

**Key SRE Principles I've Implemented:**
1. **Error Budgets**: Track SLI/SLO violations
2. **Toil Reduction**: Automated deployments, no manual steps
3. **Monitoring**: Prometheus for observability
4. **Incident Response**: Runbooks and postmortems
5. **Capacity Planning**: Auto-scaling based on metrics

In my project, I've automated 100% of deployment tasks, established SLIs for latency and availability, and built monitoring to track error budgets."

---

**Q2: How do you define and measure SLOs?**

**Answer:**
"I follow the SLI → SLO → SLA hierarchy:

**For my project:**

**SLI (Service Level Indicator):**
- Availability: `successful_requests / total_requests`
- Latency: `P95 response time < 200ms`
- Error Rate: `error_rate < 1%`

**SLO (Service Level Objective):**
- 99.9% availability over 30 days (43 min downtime)
- 95% of requests complete in < 200ms
- Error rate < 0.1%

**Error Budget:**
- 43 minutes downtime per month
- If exceeded → focus on reliability, freeze features
- If underutilized → increase velocity, take risks

**Measurement:**
```promql
# Availability
sum(rate(http_requests_total{status=~"2.."}[30d])) /
sum(rate(http_requests_total[30d])) * 100

# Latency SLO
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
) < 0.2
```

**Dashboard shows:**
- Current SLO compliance: 99.95% ✓
- Error budget remaining: 40 minutes
- Burn rate: 0.5x (healthy)"

---

**Q3: How do you handle incidents?**

**Answer:**
"I follow a structured incident response process:

**1. Detection (MTTA: Mean Time to Acknowledge)**
- Automated alerts from Prometheus
- PagerDuty/Opsgenie integration ready
- Multiple channels: Slack, email, SMS

**2. Triage (Assess severity)**
- SEV1: Service down, customer impact
- SEV2: Degraded performance
- SEV3: Minor issues, no impact

**3. Response (MTTR: Mean Time to Resolve)**
- Follow runbook: `docs/runbooks/incident-response.md`
- War room setup (Zoom + Slack)
- Incident commander assigned
- Updates every 15 minutes

**4. Mitigation**
- Quick fix: Rollback deployment
- Database: Read replicas failover
- Scale: Increase ECS tasks manually
- Circuit breaker: Disable non-critical features

**5. Recovery Verification**
- Health checks green
- Metrics back to normal
- Customer verification

**6. Postmortem (within 48 hours)**
- Timeline of events
- Root cause analysis (5 Whys)
- Action items with owners
- No blame culture

**Example from my project:**
```bash
# Incident: API response time spike
1. Alert: P95 latency > 1s
2. Investigation: Database connection pool exhausted
3. Quick fix: Increase pool size from 10 to 50
4. Long-term: Implement connection pooling with pgBouncer
5. Postmortem: Added monitoring for pool utilization
```
"

---

**Q4: Explain your monitoring strategy (Golden Signals)**

**Answer:**
"I implement the Four Golden Signals from Google's SRE book:

**1. Latency** - How long requests take
```promql
# P50, P95, P99 latency
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
)
```
- **Target**: P95 < 200ms
- **Alert**: P95 > 500ms for 5 minutes
- **Dashboard**: Time series graph with percentiles

**2. Traffic** - How much demand
```promql
# Requests per second
rate(http_requests_total[1m])
```
- **Baseline**: 100 req/s normal
- **Peak**: 500 req/s expected
- **Alert**: Sudden 50% drop (indicates problem)

**3. Errors** - Rate of failed requests
```promql
# Error rate
sum(rate(http_requests_total{status=~"5.."}[5m])) /
sum(rate(http_requests_total[5m])) * 100
```
- **Target**: < 0.1%
- **Alert**: > 1% for 5 minutes
- **Action**: Auto-rollback on deploy

**4. Saturation** - How full the service is
```promql
# CPU and Memory utilization
container_cpu_usage_seconds_total
container_memory_usage_bytes
```
- **Target**: CPU < 70%, Memory < 80%
- **Alert**: CPU > 80% for 10 minutes
- **Action**: Auto-scale triggers

**Additional Metrics:**
- Database connection pool usage
- Redis cache hit rate
- Disk I/O and network
- Queue depth for async jobs

**Grafana Dashboard Layout:**
```
Row 1: Golden Signals (Latency, Traffic, Errors, Saturation)
Row 2: Business Metrics (Successful processing, batch completions)
Row 3: Infrastructure (CPU, Memory, Network)
Row 4: Dependencies (DB, Redis, External APIs)
```
"

---

### Docker & Containers

**Q5: Explain your Docker strategy**

**Answer:**
"I use multi-stage builds for efficiency and security:

**Development Dockerfile:**
```dockerfile
FROM python:3.9-slim
# Dev dependencies, debugging tools
# Hot reload with volume mounts
```

**Production Dockerfile:**
```dockerfile
# Stage 1: Build
FROM python:3.9-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.9-slim
COPY --from=builder /root/.local /root/.local
COPY . /app
USER nobody  # Non-root security
CMD ["python", "app.py"]
```

**Benefits:**
- 40% smaller image size (150MB vs 250MB)
- Security: Non-root user, minimal attack surface
- Caching: Layer optimization for faster builds
- Scanning: Trivy for vulnerability detection

**Container Health:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 40s
```

**Resource Limits:**
```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1G
    reservations:
      cpus: '0.5'
      memory: 512M
```
"

---

### Terraform & IaC

**Q6: How do you manage Terraform state and environments?**

**Answer:**
"I follow Terraform best practices for production:

**State Management:**
```hcl
terraform {
  backend "s3" {
    bucket         = "cloud-sre-tfstate-staging"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # State locking
  }
}
```

**Benefits:**
- **Remote State**: Team collaboration
- **Locking**: Prevents concurrent modifications
- **Encryption**: State contains secrets
- **Versioning**: S3 versioning enabled for rollback

**Environment Strategy:**
```
terraform/
├── main.tf                 # Main resources
├── variables.tf            # Variable definitions
├── outputs.tf             # Outputs
└── environments/
    ├── staging/
    │   └── terraform.tfvars  # Staging values
    └── prod/
        └── terraform.tfvars  # Production values
```

**Deployment:**
```bash
# Staging
terraform init -backend-config="bucket=tfstate-staging"
terraform workspace select staging
terraform apply -var-file="environments/staging/terraform.tfvars"

# Production (requires approval)
terraform workspace select prod
terraform apply -var-file="environments/prod/terraform.tfvars"
```

**Modules:**
```hcl
module "ecs" {
  source = "./modules/ecs"
  
  cluster_name     = "${var.environment}-cluster"
  service_name     = "${var.environment}-service"
  desired_count    = var.environment == "prod" ? 3 : 1
  container_image  = var.image_tag
}
```

**Best Practices:**
- DRY principle with modules
- Variable validation
- Outputs for cross-module references
- Tagging strategy for cost tracking
- `.terraform.lock.hcl` in version control
"

---

### Kubernetes vs ECS

**Q7: Why did you choose ECS over Kubernetes?**

**Answer:**
"I chose ECS for this project based on several factors:

**ECS Advantages:**
1. **Simplicity**: Less operational overhead
2. **AWS Integration**: Native CloudWatch, IAM, ELB
3. **Cost**: No control plane charges
4. **Serverless**: Fargate eliminates node management
5. **Learning Curve**: Faster to production

**When I'd Choose Kubernetes:**
1. **Multi-cloud**: Portability across AWS, GCP, Azure
2. **Complex workloads**: StatefulSets, DaemonSets, Jobs
3. **Ecosystem**: Helm charts, operators, service mesh
4. **Advanced networking**: Istio, Linkerd
5. **Team expertise**: If team already knows K8s

**Comparison Table:**

| Feature | ECS | Kubernetes |
|---------|-----|------------|
| Setup Time | 15 min | 2-4 hours |
| Learning Curve | Low | High |
| Flexibility | Medium | Very High |
| Cost | Lower | Higher |
| Community | AWS-specific | Large ecosystem |
| Portability | AWS-only | Multi-cloud |

**My Decision:**
For this SRE demo project with simple microservices and AWS deployment, ECS provides the best balance of simplicity and functionality. The Fargate serverless model eliminates infrastructure management, letting me focus on application reliability.

**If scaling this project:**
- 10-50 services: Stay with ECS
- 50+ services: Consider EKS
- Multi-cloud requirement: Migrate to K8s
"

---

## 🎭 Scenario-Based Problems

### Scenario 1: Database Connection Pool Exhaustion

**Problem:**
"At 2 AM, you receive alerts that your API is timing out. Investigating, you find all database connections are exhausted. How do you handle this?"

**Solution:**

**Immediate Response (15 minutes):**
```bash
# 1. Check current connections
aws ecs describe-tasks --cluster staging --tasks $(aws ecs list-tasks ...)

# 2. Verify database connections
psql -c "SELECT count(*) FROM pg_stat_activity;"

# 3. Quick fix: Increase pool size
# Edit environment variable
aws ecs update-service --cluster staging \
  --service app-service \
  --force-new-deployment \
  --task-definition app:23 \
  --environment "DB_POOL_SIZE=50"

# 4. Kill idle connections
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity 
         WHERE state = 'idle' AND state_change < now() - interval '5 minutes';"

# 5. Scale up temporarily
aws ecs update-service --cluster staging \
  --service app-service \
  --desired-count 3  # From 1 to 3
```

**Root Cause Analysis:**
- Connection pool: 10 connections
- Concurrent requests: 50+
- Leak: Connections not being released

**Long-term Fix (Next Day):**
```python
# Implement connection pooling with context manager
from contextlib import contextmanager

@contextmanager
def get_db_connection():
    conn = db_pool.get_connection()
    try:
        yield conn
    finally:
        conn.close()  # Always release

# Use it
with get_db_connection() as conn:
    cursor = conn.cursor()
    cursor.execute("SELECT ...")
```

**Prevention:**
1. **Monitoring**: Add connection pool utilization metric
2. **Alerting**: Alert when pool > 80% utilized
3. **Load Testing**: Test under connection pressure
4. **Documentation**: Add to runbook

**Postmortem:**
```markdown
## Incident: Database Connection Exhaustion
**Date**: 2026-01-06 02:00 UTC
**Duration**: 15 minutes
**Impact**: 200 failed requests, 2 customers affected

**Timeline:**
- 02:00: Alert fired
- 02:03: Oncall engineer paged
- 02:08: Root cause identified
- 02:15: Mitigation deployed
- 02:20: Service recovered

**Root Cause:** Connection pool too small (10) for load (50 concurrent)

**Action Items:**
1. [DONE] Increase pool to 50
2. [TODO] Add pool utilization monitoring
3. [TODO] Implement connection timeout
4. [TODO] Load test with connection constraints
```

---

### Scenario 2: Auto-Scaling Not Working

**Problem:**
"Your service is experiencing high load (CPU 90%) but not auto-scaling. Requests are timing out. What do you check?"

**Investigation Checklist:**

**1. Verify CloudWatch Alarms:**
```bash
aws cloudwatch describe-alarms \
  --alarm-names "app-cpu-high-staging"

# Check alarm state
{
  "AlarmName": "app-cpu-high-staging",
  "State": "ALARM",  # Should be in ALARM
  "Threshold": 70.0,
  "EvaluationPeriods": 2
}
```

**2. Check Auto-Scaling Policy:**
```bash
aws application-autoscaling describe-scaling-policies \
  --service-namespace ecs

# Verify policy exists and is active
```

**3. Check ECS Service:**
```bash
aws ecs describe-services \
  --cluster staging \
  --services app-service

# Check:
# - DesiredCount vs RunningCount
# - Health check failures
# - Deployment in progress
```

**4. Check Task Failures:**
```bash
aws ecs describe-tasks --cluster staging --tasks <task-arn>

# Look for:
# - "CannotPullContainerError"
# - "OutOfMemory"
# - Health check failures
```

**5. Check Capacity:**
```bash
# For Fargate: Check service quotas
aws service-quotas get-service-quota \
  --service-code ecs \
  --quota-code L-3032A538  # Fargate tasks per region

# Verify you haven't hit limits
```

**Common Causes & Fixes:**

**A. Cooldown Period Not Expired:**
```hcl
# Terraform: Reduce cooldown
resource "aws_appautoscaling_policy" "scale_up" {
  cooldown = 60  # Was 300, reduce to 60
}
```

**B. Health Checks Failing:**
```bash
# Check ALB target group
aws elbv2 describe-target-health \
  --target-group-arn <arn>

# Fix health check
# If /health endpoint is slow, optimize it
```

**C. Insufficient IAM Permissions:**
```json
{
  "Effect": "Allow",
  "Action": [
    "ecs:UpdateService",
    "ecs:DescribeServices",
    "cloudwatch:DescribeAlarms"
  ],
  "Resource": "*"
}
```

**D. Deployment in Progress:**
```bash
# ECS won't scale during deployment
# Wait for deployment to complete or roll back
aws ecs update-service --cluster staging \
  --service app-service \
  --force-new-deployment false
```

**Quick Workaround:**
```bash
# Manual scale-up immediately
aws ecs update-service \
  --cluster staging \
  --service app-service \
  --desired-count 5

# Then fix auto-scaling for future
```

---

### Scenario 3: Memory Leak Detection

**Problem:**
"After a deployment, memory usage keeps growing until the container is killed by OOM. How do you debug?"

**Detection:**
```bash
# 1. Check Prometheus metrics
# Graph shows memory growing linearly

# 2. Check Docker stats
docker stats app

NAME  CPU %  MEM USAGE / LIMIT     MEM %
app   15%    950MiB / 1024MiB     93%   # Growing!
```

**Debugging Steps:**

**1. Get Memory Dump:**
```python
# Add to app.py
import tracemalloc
tracemalloc.start()

@app.route('/debug/memory')
def memory_snapshot():
    snapshot = tracemalloc.take_snapshot()
    top_stats = snapshot.statistics('lineno')
    
    return jsonify([{
        'file': str(stat.traceback),
        'size_mb': stat.size / 1024 / 1024
    } for stat in top_stats[:10]])
```

**2. Enable Memory Profiling:**
```bash
# Install memory_profiler
pip install memory-profiler

# Profile specific function
@profile
def process_data(data):
    # Function code
    pass

# Run with profiler
python -m memory_profiler app.py
```

**3. Check for Common Leaks:**
```python
# ❌ BAD: Global list growing
cached_data = []  # Never cleared!

@app.route('/process')
def process():
    cached_data.append(data)  # Leak!
    
# ✅ GOOD: Use LRU cache with max size
from functools import lru_cache

@lru_cache(maxsize=1000)
def process_with_cache(data):
    return expensive_operation(data)
```

**4. Check Database Connections:**
```python
# ❌ BAD: Not closing connections
def query_db():
    conn = psycopg2.connect(...)
    cursor = conn.cursor()
    cursor.execute("SELECT ...")
    return cursor.fetchall()
    # conn never closed!

# ✅ GOOD: Use context manager
def query_db():
    with psycopg2.connect(...) as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT ...")
            return cursor.fetchall()
```

**5. Fix and Verify:**
```bash
# After fix, deploy and monitor
watch -n 5 'docker stats app --no-stream'

# Memory should stabilize
# Before: 100MB → 200MB → 400MB → 900MB (crash)
# After:  100MB → 150MB → 150MB → 150MB (stable)
```

**Prevention:**
```python
# Add memory limit check
@app.before_request
def check_memory():
    import psutil
    memory_percent = psutil.virtual_memory().percent
    if memory_percent > 90:
        logger.error(f"High memory usage: {memory_percent}%")
        # Could reject requests or trigger alert
```

---

## 🎬 Hands-on Demo Script

### 5-Minute Live Demo

**Preparation:**
```bash
# Start all services
make docker-up

# Verify running
docker compose -f docker-compose.local.yml ps

# Open monitoring
open http://localhost:3000  # Grafana
open http://localhost:9090  # Prometheus
```

**Demo Flow:**

**1. Show Architecture (30 seconds)**
```bash
# Show docker-compose structure
cat docker-compose.local.yml | grep "services:" -A 20
```
*"I have 6 microservices: App, Postgres, Redis, Prometheus, Grafana, and Nginx"*

**2. Health Check (15 seconds)**
```bash
curl http://localhost:8080/health | jq
```
*"Application is healthy, all checks passing"*

**3. Process Single Item (30 seconds)**
```bash
curl -X POST http://localhost:8080/process \
  -H "Content-Type: application/json" \
  -d '{
    "text": "demo data for interview",
    "priority": "high",
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }' | jq
```
*"Processing takes ~50ms, returns metadata and timestamp"*

**4. Show Metrics (30 seconds)**
```bash
curl http://localhost:8080/metrics | grep -E "(http_requests_total|http_request_duration)"
```
*"Prometheus metrics tracking requests, latency, errors"*

**5. Batch Processing (45 seconds)**
```bash
# Create test data
cat > /tmp/batch.json << 'EOF'
{
  "items": [
    {"id": 1, "data": "item 1"},
    {"id": 2, "data": "item 2"},
    {"id": 3, "data": "item 3"}
  ],
  "max_items": 100
}
EOF

curl -X POST http://localhost:8080/batch \
  -H "Content-Type: application/json" \
  -d @/tmp/batch.json | jq
```
*"Batch processing handles multiple items efficiently"*

**6. Show Grafana Dashboard (90 seconds)**
```
Open: http://localhost:3000
Login: admin / admin
Navigate to: Dashboards → AI Processor
```
*"Dashboard shows:*
- *Request rate increasing*
- *Latency staying under 200ms P95*
- *Zero errors*
- *CPU and memory stable"*

**7. Show Infrastructure as Code (45 seconds)**
```bash
cat terraform/main.tf | head -50
```
*"Entire infrastructure defined as code: ECS, ALB, auto-scaling, monitoring"*

**8. Show Auto-Recovery (60 seconds)**
```bash
# Simulate failure
docker compose -f docker-compose.local.yml stop app

# Show in Grafana - requests failing

# Docker automatically restarts
docker compose -f docker-compose.local.yml ps app

# Health restored
curl http://localhost:8080/health
```
*"Container auto-recovers within 30 seconds"*

---

## 📐 Architecture Discussion Points

### Design Decisions

**1. Why Flask over FastAPI?**
- Familiarity: More developers know Flask
- Ecosystem: Mature libraries and extensions
- Simplicity: Less boilerplate for simple APIs
- When I'd choose FastAPI: Async workloads, auto-documentation, type safety

**2. Why Prometheus over CloudWatch only?**
- Vendor independence: Works locally and in cloud
- Query language: PromQL more powerful than CloudWatch Insights
- Community: Large ecosystem of exporters
- Cost: Prometheus free for local dev
- Hybrid: Use both (Prometheus → CloudWatch)

**3. Why PostgreSQL over NoSQL?**
- ACID compliance: Financial/healthcare data
- Relationships: Complex queries with JOINs
- Maturity: 30+ years of development
- Extensions: PostGIS, TimescaleDB, etc.
- When NoSQL: Document storage, massive scale, flexible schema

**4. Why Terraform over CloudFormation?**
- Multi-cloud: Can deploy to AWS, GCP, Azure
- State management: Better than CFN
- Module ecosystem: Terraform Registry
- Language: HCL more readable than JSON/YAML
- Community: Larger than CFN

### Scaling Considerations

**Current State:**
- 1-10 ECS tasks
- Single database instance
- Redis single node
- 1000 req/s capacity

**Scaling to 10,000 req/s:**

**Horizontal Scaling:**
```hcl
# Increase max tasks
resource "aws_appautoscaling_target" "ecs" {
  max_capacity = 50  # From 10
  min_capacity = 5   # From 1
}

# Add read replicas
resource "aws_db_instance" "read_replica" {
  count             = 3
  replicate_source_db = aws_db_instance.main.id
}
```

**Caching Strategy:**
```python
# Redis caching layer
@app.route('/process')
def process():
    cache_key = f"result:{hash(data)}"
    
    # Check cache
    cached = redis.get(cache_key)
    if cached:
        return cached
    
    # Process and cache
    result = process_data(data)
    redis.setex(cache_key, 3600, result)
    return result
```

**Database Sharding:**
```python
# Shard by user_id
def get_shard(user_id):
    shard_count = 4
    shard_num = user_id % shard_count
    return db_connections[shard_num]

# Route to correct shard
conn = get_shard(user_id)
```

**CDN for Static Content:**
```hcl
# CloudFront distribution
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  
  origin {
    domain_name = aws_alb.main.dns_name
    origin_id   = "alb"
  }
  
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
  }
}
```

**Async Processing:**
```python
# Celery for background jobs
from celery import Celery

celery = Celery('tasks', broker='redis://localhost')

@celery.task
def process_async(data):
    # Long-running task
    time.sleep(60)
    return result

# Endpoint returns immediately
@app.route('/process/async')
def process_async_endpoint():
    task = process_async.delay(data)
    return {'task_id': task.id}
```

---

## 📚 Additional Resources

### Books to Reference
1. **Site Reliability Engineering** (Google) - SRE principles
2. **The Phoenix Project** - DevOps culture
3. **Designing Data-Intensive Applications** - System design
4. **Release It!** - Production-ready software

### Key Metrics Formulas

**Error Budget:**
```
Error Budget = (1 - SLO) × Total Time
Example: (1 - 0.999) × 30 days = 43.2 minutes
```

**Availability:**
```
Availability = Uptime / (Uptime + Downtime) × 100
Example: (43157 / 43200) × 100 = 99.9%
```

**Apdex Score:**
```
Apdex = (Satisfied + Tolerating/2) / Total
Satisfied: < 100ms
Tolerating: 100-400ms  
Frustrated: > 400ms
```

---

## ✅ Final Interview Checklist

**Before Interview:**
- [ ] Services running: `make docker-up`
- [ ] Grafana accessible: http://localhost:3000
- [ ] Test API working: `curl http://localhost:8080/health`
- [ ] AWS credentials configured: `aws sts get-caller-identity`
- [ ] Terraform initialized: `cd terraform && terraform init`
- [ ] Know your metrics: P95 latency, error rate, uptime
- [ ] Review this document
- [ ] Practice 5-minute demo
- [ ] Prepare questions for interviewer

**During Interview:**
- Explain architecture clearly
- Show live system, not just slides
- Discuss trade-offs in design decisions
- Share real metrics and numbers
- Mention real-world applications
- Ask clarifying questions
- Be honest about what you don't know

**Questions to Ask Interviewer:**
1. What does your current monitoring stack look like?
2. How do you handle incident response?
3. What's your deployment frequency?
4. How do you manage infrastructure (IaC)?
5. What's the team's SLO for the main service?
6. How do you balance reliability vs feature velocity?

---

**Good luck with your interview! 🚀**

*Remember: It's not about knowing everything, it's about demonstrating problem-solving skills and engineering judgment.*
