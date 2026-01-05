terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Configuration will be provided via backend config file
    key = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "cloud-sre-demo"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "SRE-Team"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Configuration (using default VPC for demo)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Modules
module "ecr" {
  source = "./modules/ecr"
  
  repository_name = "ai-data-processor"
  environment     = var.environment
  image_tag_mutability = "MUTABLE"
}

module "ecs" {
  source = "./modules/ecs"
  
  environment      = var.environment
  ecr_repository   = module.ecr.repository_url
  vpc_id           = data.aws_vpc.default.id
  subnets          = data.aws_subnets.default.ids
  cpu              = var.cpu
  memory           = var.memory
  desired_count    = var.desired_count
  image_tag        = var.image_tag
  
  # Container configuration
  container_port   = 8080
  health_check_path = "/health"
}

module "monitoring" {
  source = "./modules/monitoring"
  
  environment   = var.environment
  cluster_name  = module.ecs.cluster_name
  service_name  = module.ecs.service_name
  alb_arn       = module.ecs.alb_arn
  target_group_arn = module.ecs.target_group_arn
}

# Outputs
output "service_url" {
  value       = module.ecs.service_url
  description = "URL to access the service"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}

output "cloudwatch_dashboard_url" {
  value       = module.monitoring.dashboard_url
  description = "CloudWatch dashboard URL"
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = module.ecs.service_name
  description = "ECS service name"
}
