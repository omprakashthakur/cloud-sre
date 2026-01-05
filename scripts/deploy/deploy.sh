#!/bin/bash
# Cloud SRE Deployment Script - Complete deployment automation
# This script handles testing, building, and deploying to AWS

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

print_banner() {
    echo ""
    echo "=========================================="
    echo "  Cloud SRE Deployment Pipeline"
    echo "  Environment: ${ENVIRONMENT}"
    echo "  Action: ${ACTION}"
    echo "=========================================="
    echo ""
}

usage() {
    cat << EOF
Usage: $0 [environment] [action]

Environments:
  staging       Deploy to staging environment
  prod          Deploy to production environment
  dev           Local development environment

Actions:
  plan          Terraform plan only
  apply         Terraform apply (deploy infrastructure)
  destroy       Destroy infrastructure
  deploy        Full deployment (test + build + deploy)
  test          Run tests only
  build         Build Docker image only
  push          Push Docker image to ECR

Examples:
  $0 staging deploy    # Full deployment to staging
  $0 prod plan         # Plan production changes
  $0 dev test          # Run tests locally

EOF
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing=0
    local commands=("aws" "docker" "terraform" "python3" "jq")
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "$cmd is not installed"
            missing=1
        else
            log_info "✓ $cmd found"
        fi
    done
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured or expired"
        log_info "Run: aws configure"
        missing=1
    else
        local aws_account=$(aws sts get-caller-identity --query Account --output text)
        log_info "✓ AWS credentials valid (Account: $aws_account)"
    fi
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        missing=1
    else
        log_info "✓ Docker daemon running"
    fi
    
    if [ $missing -eq 1 ]; then
        log_error "Prerequisites check failed"
        exit 1
    fi
    
    log_success "All prerequisites satisfied"
}

# Run tests
run_tests() {
    log_info "Running test suite..."
    
    cd "$PROJECT_ROOT/src/app"
    
    # Create test results directory
    mkdir -p "$PROJECT_ROOT/test-results"
    
    # Install dependencies if needed
    if [ ! -d "venv" ]; then
        log_info "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    log_info "Installing Python dependencies..."
    pip install -q --upgrade pip
    pip install -q -r requirements.txt
    
    # Unit tests
    log_info "Running unit tests..."
    if pytest tests/ -v --junitxml="$PROJECT_ROOT/test-results/junit.xml" --cov=. --cov-report=html:$PROJECT_ROOT/test-results/coverage 2>&1 | tee "$PROJECT_ROOT/test-results/test-output.log"; then
        log_success "Unit tests passed"
    else
        log_error "Unit tests failed"
        return 1
    fi
    
    # Code quality checks
    log_info "Running code quality checks..."
    
    log_info "  - Linting with flake8..."
    flake8 . --max-line-length=120 --exclude=venv,__pycache__ || log_warning "Linting warnings found"
    
    log_info "  - Security scan with bandit..."
    bandit -r . -f json -o "$PROJECT_ROOT/test-results/bandit.json" -x ./venv || log_warning "Security warnings found"
    
    deactivate
    
    log_success "All tests completed"
    return 0
}

# Build Docker image
build_docker_image() {
    log_info "Building Docker image..."
    
    cd "$PROJECT_ROOT/src/app"
    
    local image_name="ai-data-processor"
    local image_tag="${IMAGE_TAG:-latest}"
    
    # Get ECR repository URL
    local ecr_repo=""
    if aws ecr describe-repositories --repository-names "$image_name-${ENVIRONMENT}" &> /dev/null; then
        ecr_repo=$(aws ecr describe-repositories --repository-names "$image_name-${ENVIRONMENT}" --query 'repositories[0].repositoryUri' --output text)
        log_info "ECR Repository: $ecr_repo"
    else
        log_warning "ECR repository not found. Building local image only."
        docker build -t "$image_name:$image_tag" .
        log_success "Local Docker image built"
        return 0
    fi
    
    # Build with multiple tags
    log_info "Building Docker image with tags..."
    docker build \
        -t "$ecr_repo:$image_tag" \
        -t "$ecr_repo:$(git rev-parse --short HEAD)" \
        -t "$image_name:$image_tag" \
        --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
        .
    
    log_success "Docker image built successfully"
    
    # Show image size
    docker images "$ecr_repo" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -n 2
}

# Push Docker image to ECR
push_docker_image() {
    log_info "Pushing Docker image to ECR..."
    
    local image_name="ai-data-processor"
    local image_tag="${IMAGE_TAG:-latest}"
    
    # Get ECR repository URL
    local ecr_repo=$(aws ecr describe-repositories --repository-names "$image_name-${ENVIRONMENT}" --query 'repositories[0].repositoryUri' --output text 2>/dev/null || echo "")
    
    if [ -z "$ecr_repo" ]; then
        log_error "ECR repository not found. Run terraform apply first."
        exit 1
    fi
    
    # Login to ECR
    log_info "Logging into ECR..."
    local aws_region=$(aws configure get region || echo "us-east-1")
    local aws_account=$(aws sts get-caller-identity --query Account --output text)
    
    aws ecr get-login-password --region "$aws_region" | docker login --username AWS --password-stdin "$aws_account.dkr.ecr.$aws_region.amazonaws.com"
    
    # Push images
    log_info "Pushing image: $ecr_repo:$image_tag"
    docker push "$ecr_repo:$image_tag"
    
    log_info "Pushing image: $ecr_repo:$(git rev-parse --short HEAD)"
    docker push "$ecr_repo:$(git rev-parse --short HEAD)"
    
    log_success "Docker image pushed to ECR"
}

# Terraform operations
terraform_init() {
    log_info "Initializing Terraform..."
    
    cd "$PROJECT_ROOT/terraform"
    
    terraform init -reconfigure \
        -backend-config="bucket=cloud-sre-tfstate-${ENVIRONMENT}" \
        -backend-config="region=us-east-1" \
        -backend-config="encrypt=true"
    
    log_success "Terraform initialized"
}

terraform_plan() {
    log_info "Creating Terraform plan..."
    
    cd "$PROJECT_ROOT/terraform"
    
    terraform plan \
        -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
        -var="image_tag=${IMAGE_TAG:-latest}" \
        -out="tfplan"
    
    log_success "Terraform plan created. Review before applying."
}

terraform_apply() {
    log_info "Applying Terraform configuration..."
    
    cd "$PROJECT_ROOT/terraform"
    
    if [ ! -f "tfplan" ]; then
        log_warning "No plan file found. Running plan first..."
        terraform_plan
    fi
    
    terraform apply -auto-approve "tfplan"
    
    # Save outputs
    terraform output -json > "$PROJECT_ROOT/terraform-outputs.json"
    
    log_success "Infrastructure deployed successfully"
    
    # Display important outputs
    echo ""
    log_info "Deployment outputs:"
    echo "  Service URL: $(terraform output -raw service_url)"
    echo "  ECR Repository: $(terraform output -raw ecr_repository_url)"
    echo ""
}

terraform_destroy() {
    log_warning "This will destroy all infrastructure for ${ENVIRONMENT}"
    read -p "Are you sure? Type '${ENVIRONMENT}' to confirm: " confirmation
    
    if [ "$confirmation" != "$ENVIRONMENT" ]; then
        log_info "Destruction cancelled"
        exit 0
    fi
    
    cd "$PROJECT_ROOT/terraform"
    
    terraform destroy \
        -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
        -var="image_tag=${IMAGE_TAG:-latest}" \
        -auto-approve
    
    log_success "Infrastructure destroyed"
}

# Full deployment workflow
full_deployment() {
    log_info "Starting full deployment workflow..."
    
    print_banner
    check_prerequisites
    
    # Run tests
    if ! run_tests; then
        log_error "Tests failed. Aborting deployment."
        exit 1
    fi
    
    # Build Docker image
    build_docker_image
    
    # Initialize Terraform
    terraform_init
    
    # Create plan
    terraform_plan
    
    # Apply infrastructure
    terraform_apply
    
    # Push Docker image
    push_docker_image
    
    # Force ECS service update
    log_info "Updating ECS service..."
    local cluster_name=$(terraform output -raw ecs_cluster_name)
    local service_name=$(terraform output -raw ecs_service_name)
    
    aws ecs update-service \
        --cluster "$cluster_name" \
        --service "$service_name" \
        --force-new-deployment \
        --region us-east-1 > /dev/null
    
    log_success "Deployment completed successfully!"
    
    echo ""
    log_info "Access your application at: $(terraform output -raw service_url)"
    echo ""
}

# Main script
main() {
    if [ $# -lt 2 ]; then
        usage
    fi
    
    export ENVIRONMENT=$1
    export ACTION=$2
    export IMAGE_TAG="${3:-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S)}"
    
    case $ENVIRONMENT in
        staging|prod|dev)
            ;;
        *)
            log_error "Invalid environment: $ENVIRONMENT"
            usage
            ;;
    esac
    
    case $ACTION in
        test)
            check_prerequisites
            run_tests
            ;;
        build)
            check_prerequisites
            build_docker_image
            ;;
        push)
            check_prerequisites
            push_docker_image
            ;;
        plan)
            check_prerequisites
            terraform_init
            terraform_plan
            ;;
        apply)
            check_prerequisites
            terraform_init
            terraform_apply
            ;;
        destroy)
            check_prerequisites
            terraform_init
            terraform_destroy
            ;;
        deploy)
            full_deployment
            ;;
        *)
            log_error "Invalid action: $ACTION"
            usage
            ;;
    esac
}

# Run main function
main "$@"
