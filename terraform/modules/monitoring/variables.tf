variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}
