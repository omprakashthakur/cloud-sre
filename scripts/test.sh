#!/bin/bash
# Test script for local development
set -e

echo "==================================="
echo "  Running Local Tests"
echo "==================================="

cd "$(dirname "$0")/../src/app"

# Create venv if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

echo "Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt

echo ""
echo "Running tests..."
pytest tests/ -v

echo ""
echo "Running linter..."
flake8 . --max-line-length=120 --exclude=venv,__pycache__

echo ""
echo "Running security scan..."
bandit -r . -x ./venv

deactivate

echo ""
echo "✓ All tests passed!"
