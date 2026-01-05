output "service_url" {
  description = "URL to access the deployed service"
  value       = module.ecs.service_url
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = module.ecr.repository_url
}

output "cloudwatch_dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.ecs.alb_dns_name
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    environment  = var.environment
    region       = var.aws_region
    image_tag    = var.image_tag
    cpu          = var.cpu
    memory       = var.memory
    desired_count = var.desired_count
  }
}
