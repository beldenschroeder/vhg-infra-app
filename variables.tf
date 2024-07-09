variable "region" {
  description = "AWS region"
  type = string
}

variable "remote_state_bucket" {
  description = "S3 bucket to store Terraform state file"
  type = string
}

variable "remote_state_key" {
  description = "S3 key to store Terraform state file"
  type = string
}

# Application Variables for Task Definition

variable "ecs_service_name" {
  description = "ECS service name"
  type = string
}

variable "docker_image_url" {
  description = "Docker image URL"
  type = string
}

variable "memory" {
  description = "Memory for ECS task"
  type = number
}

variable "docker_container_port" {
  description = "Docker container port"
  type = number
}

variable "desired_task_number" {
  description = "Desired number of tasks"
  type = number
}

variable "vercel_env" {
  description = "Vercel environment"
  type = string
}

variable "vercel_url" {
  description = "Vercel URL"
  type = string
}