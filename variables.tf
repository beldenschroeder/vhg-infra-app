variable "region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "remote_state_bucket" {
  description = "S3 bucket to store Terraform state file"
  default = null
}

variable "remote_state_key" {
  description = "S3 key to store Terraform state file"
  default = null
}

# Application Variables for Task Definition

variable "ecs_service_name" {
  description = "ECS service name"
  default = null
}

variable "docker_image_url" {
  description = "Docker image URL"
  default = null
}

variable "memory" {
  description = "Memory for ECS task"
  default = null
}

variable "docker_container_port" {
  description = "Docker container port"
  default = null
}

variable "desired_task_number" {
  description = "Desired number of tasks"
  default = null
}

variable "vercel_env" {
  description = "Vercel environment"
  default = null
}

variable "vercel_url" {
  description = "Vercel URL"
  default = null
}