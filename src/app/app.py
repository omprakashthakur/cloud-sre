"""
AI Data Processor - Cloud SRE Demo Application
Simulates a high-performance AI data processing service with monitoring and observability
"""
import os
import time
import logging
from flask import Flask, request, jsonify
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
from python_json_logger import jsonlogger

# Setup JSON logging for better log aggregation
logger = logging.getLogger()
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)
logger.addHandler(logHandler)
logger.setLevel(os.getenv('LOG_LEVEL', 'INFO'))

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['endpoint']
)

ERROR_COUNT = Counter(
    'http_errors_total',
    'Total HTTP errors',
    ['type']
)

ACTIVE_CONNECTIONS = Gauge(
    'active_connections',
    'Number of active connections'
)

PROCESSING_TIME = Histogram(
    'data_processing_duration_seconds',
    'Data processing duration in seconds',
    ['operation']
)

class DataProcessor:
    """Simulates AI data processing pipeline"""
    
    def __init__(self):
        self.processed_count = 0
        
    def process(self, data: dict) -> dict:
        """Process incoming data"""
        start_time = time.time()
        
        try:
            with PROCESSING_TIME.labels(operation='single').time():
                # Simulate ML processing
                time.sleep(0.05)  # 50ms processing time
                
                self.processed_count += 1
                
                # Add processing metadata
                result = {
                    "status": "success",
                    "processed_at": time.time(),
                    "processing_time_ms": round((time.time() - start_time) * 1000, 2),
                    "data_length": len(str(data)),
                    "processor_count": self.processed_count,
                    **data
                }
                
                logger.info({
                    "event": "data_processed",
                    "processing_time_ms": result["processing_time_ms"],
                    "data_length": result["data_length"]
                })
                
                return result
                
        except Exception as e:
            ERROR_COUNT.labels(type="processing_error").inc()
            logger.error({
                "event": "processing_error",
                "error": str(e)
            })
            raise
    
    def process_batch(self, items: list, max_items: int = 100) -> dict:
        """Process batch of items"""
        start_time = time.time()
        
        with PROCESSING_TIME.labels(operation='batch').time():
            results = []
            failed = 0
            
            for item in items[:max_items]:
                try:
                    result = self.process(item)
                    results.append(result)
                except Exception as e:
                    logger.warning({
                        "event": "batch_item_failed",
                        "error": str(e)
                    })
                    failed += 1
                    continue
            
            duration = time.time() - start_time
            
            logger.info({
                "event": "batch_processed",
                "total_items": len(items),
                "processed": len(results),
                "failed": failed,
                "duration_seconds": round(duration, 2)
            })
            
            return {
                "processed": len(results),
                "failed": failed,
                "total": len(items),
                "duration_seconds": round(duration, 2),
                "results": results
            }

processor = DataProcessor()

@app.before_request
def before_request():
    """Track active connections"""
    ACTIVE_CONNECTIONS.inc()
    request.start_time = time.time()

@app.after_request
def after_request(response):
    """Track request metrics"""
    ACTIVE_CONNECTIONS.dec()
    
    if hasattr(request, 'start_time'):
        duration = time.time() - request.start_time
        REQUEST_LATENCY.labels(endpoint=request.path).observe(duration)
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status=response.status_code
        ).inc()
    
    return response

@app.route('/')
def index():
    """Service information endpoint"""
    return jsonify({
        "service": "ai-data-processor",
        "version": "1.0.0",
        "status": "operational",
        "endpoints": {
            "health": "/health",
            "process": "/api/v1/process",
            "batch": "/api/v1/batch",
            "status": "/api/v1/status",
            "metrics": "/metrics"
        }
    })

@app.route('/health')
def health():
    """Health check endpoint for load balancers"""
    health_status = {
        "status": "healthy",
        "timestamp": time.time(),
        "checks": {
            "api": "ok",
            "processor": "ok",
            "memory": "ok"
        }
    }
    
    return jsonify(health_status), 200

@app.route('/api/v1/process', methods=['POST'])
def process_data():
    """Process single data item"""
    try:
        data = request.get_json()
        
        if not data:
            ERROR_COUNT.labels(type="invalid_request").inc()
            return jsonify({
                "error": "No data provided",
                "message": "Request body must contain JSON data"
            }), 400
        
        result = processor.process(data)
        
        return jsonify(result), 200
        
    except Exception as e:
        ERROR_COUNT.labels(type="server_error").inc()
        logger.error({
            "event": "api_error",
            "endpoint": "/api/v1/process",
            "error": str(e)
        })
        return jsonify({
            "error": "Internal server error",
            "message": str(e)
        }), 500

@app.route('/api/v1/batch', methods=['POST'])
def process_batch():
    """Process batch of data items"""
    try:
        data = request.get_json()
        
        if not data or 'items' not in data:
            ERROR_COUNT.labels(type="invalid_batch").inc()
            return jsonify({
                "error": "Invalid batch format",
                "message": "Request body must contain 'items' array"
            }), 400
        
        result = processor.process_batch(data['items'])
        
        return jsonify(result), 200
        
    except Exception as e:
        ERROR_COUNT.labels(type="batch_error").inc()
        logger.error({
            "event": "api_error",
            "endpoint": "/api/v1/batch",
            "error": str(e)
        })
        return jsonify({
            "error": "Batch processing failed",
            "message": str(e)
        }), 500

@app.route('/api/v1/status')
def status():
    """Detailed service status"""
    uptime = time.time() - app.config.get('start_time', time.time())
    
    return jsonify({
        "service": "ai-data-processor",
        "version": "1.0.0",
        "uptime_seconds": round(uptime, 2),
        "requests_processed": processor.processed_count,
        "metrics": {
            "total_requests": REQUEST_COUNT._value.get() if hasattr(REQUEST_COUNT, '_value') else 0,
            "total_errors": ERROR_COUNT._value.get() if hasattr(ERROR_COUNT, '_value') else 0,
            "active_connections": ACTIVE_CONNECTIONS._value.get() if hasattr(ACTIVE_CONNECTIONS, '_value') else 0
        },
        "environment": os.getenv('FLASK_ENV', 'production')
    })

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain; charset=utf-8'}

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        "error": "Not found",
        "message": f"The requested URL {request.url} was not found"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    ERROR_COUNT.labels(type="internal_server_error").inc()
    return jsonify({
        "error": "Internal server error",
        "message": "An unexpected error occurred"
    }), 500

if __name__ == '__main__':
    # Store start time for uptime calculation
    app.config['start_time'] = time.time()
    
    logger.info({
        "event": "service_starting",
        "port": int(os.getenv('PORT', 8080)),
        "environment": os.getenv('FLASK_ENV', 'production')
    })
    
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 8080)),
        debug=os.getenv('FLASK_DEBUG', 'false').lower() == 'true'
    )
