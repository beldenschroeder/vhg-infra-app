variable "region" {
  default = "us-east-1"
  description = "AWS region"
}

variable "remote_state_bucket" {
  description = "S3 bucket to store Terraform state file"
}

variable "remote_state_key" {
  description = "S3 key to store Terraform state file"
}

# Application Variables for Task Definition

variable "ecs_service_name" {
  description = "ECS service name"
}

variable "docker_image_url" {
  description = "Docker image URL"
}

variable "memory" {
  description = "Memory for ECS task"
}

variable "docker_container_port" {
  description = "Docker container port"
}

variable "desired_task_number" {
  description = "Desired number of tasks"
}

variable "vercel_env" {
  description = "Vercel environment"
}

variable "vercel_url" {
  description = "Vercel URL"
}