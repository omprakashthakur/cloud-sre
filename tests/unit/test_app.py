"""
Unit tests for the AI Data Processor application
"""
import pytest
import json
from app import app, processor

@pytest.fixture
def client():
    """Create test client"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_index(client):
    """Test index endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['service'] == 'ai-data-processor'
    assert data['version'] == '1.0.0'

def test_health_check(client):
    """Test health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'healthy'
    assert 'timestamp' in data
    assert 'checks' in data

def test_process_data_success(client):
    """Test successful data processing"""
    test_data = {
        'input': 'test data',
        'value': 123
    }
    response = client.post(
        '/api/v1/process',
        data=json.dumps(test_data),
        content_type='application/json'
    )
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['status'] == 'success'
    assert 'processing_time_ms' in data
    assert data['input'] == 'test data'

def test_process_data_no_input(client):
    """Test processing without input data"""
    response = client.post('/api/v1/process')
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_batch_processing(client):
    """Test batch data processing"""
    test_data = {
        'items': [
            {'id': 1, 'value': 'test1'},
            {'id': 2, 'value': 'test2'},
            {'id': 3, 'value': 'test3'}
        ]
    }
    response = client.post(
        '/api/v1/batch',
        data=json.dumps(test_data),
        content_type='application/json'
    )
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['processed'] == 3
    assert data['failed'] == 0
    assert len(data['results']) == 3

def test_batch_processing_invalid(client):
    """Test batch processing with invalid input"""
    response = client.post(
        '/api/v1/batch',
        data=json.dumps({}),
        content_type='application/json'
    )
    assert response.status_code == 400
    data = json.loads(response.data)
    assert 'error' in data

def test_status_endpoint(client):
    """Test status endpoint"""
    response = client.get('/api/v1/status')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data['service'] == 'ai-data-processor'
    assert 'uptime_seconds' in data
    assert 'requests_processed' in data

def test_metrics_endpoint(client):
    """Test Prometheus metrics endpoint"""
    response = client.get('/metrics')
    assert response.status_code == 200
    assert b'http_requests_total' in response.data

def test_not_found(client):
    """Test 404 error handling"""
    response = client.get('/nonexistent')
    assert response.status_code == 404
    data = json.loads(response.data)
    assert 'error' in data

def test_processor_single_item():
    """Test processor directly"""
    test_item = {'test': 'data'}
    result = processor.process(test_item)
    assert result['status'] == 'success'
    assert result['test'] == 'data'
    assert 'processing_time_ms' in result

def test_processor_batch():
    """Test batch processor directly"""
    items = [{'id': i} for i in range(5)]
    result = processor.process_batch(items)
    assert result['processed'] == 5
    assert result['failed'] == 0
    assert len(result['results']) == 5
