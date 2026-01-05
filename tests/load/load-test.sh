#!/bin/bash
# Load test script for AI Data Processor

echo "==================================="
echo "  Load Testing AI Data Processor"
echo "==================================="

# Configuration
TARGET_URL="${1:-http://localhost:8080}"
NUM_REQUESTS="${2:-100}"
CONCURRENT="${3:-10}"

echo ""
echo "Target: $TARGET_URL"
echo "Total Requests: $NUM_REQUESTS"
echo "Concurrent: $CONCURRENT"
echo ""

# Check if service is up
echo "Checking service health..."
if ! curl -sf "$TARGET_URL/health" > /dev/null; then
    echo "❌ Service is not responding at $TARGET_URL"
    exit 1
fi
echo "✓ Service is healthy"
echo ""

# Function to make requests
make_request() {
    local endpoint=$1
    local data=$2
    
    curl -s -w "\n%{http_code},%{time_total}" \
        -X POST "$TARGET_URL$endpoint" \
        -H "Content-Type: application/json" \
        -d "$data" > /dev/null
}

# Test single processing
echo "Test 1: Single Data Processing ($NUM_REQUESTS requests)"
echo "Starting..."

start_time=$(date +%s)

for i in $(seq 1 $NUM_REQUESTS); do
    make_request "/api/v1/process" '{"id": '$i', "data": "test-data-'$i'"}' &
    
    # Control concurrency
    if [ $((i % CONCURRENT)) -eq 0 ]; then
        wait
    fi
done

wait

end_time=$(date +%s)
duration=$((end_time - start_time))
rps=$((NUM_REQUESTS / duration))

echo "✓ Completed in ${duration}s (${rps} req/s)"
echo ""

# Test batch processing
echo "Test 2: Batch Processing (10 batches of 10 items)"
echo "Starting..."

batch_data='{"items": ['
for i in $(seq 1 10); do
    batch_data+='{"id": '$i', "value": "item-'$i'"}'
    if [ $i -lt 10 ]; then
        batch_data+=','
    fi
done
batch_data+=']}'

start_time=$(date +%s)

for i in $(seq 1 10); do
    make_request "/api/v1/batch" "$batch_data" &
done

wait

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "✓ Completed in ${duration}s"
echo ""

# Show results
echo "==================================="
echo "  Load Test Summary"
echo "==================================="
echo ""
echo "Check Grafana for detailed metrics:"
echo "  - Response time distribution"
echo "  - Error rate"
echo "  - Request rate"
echo ""
echo "Grafana: http://localhost:3000"
echo "Prometheus: http://localhost:9090"
echo ""
