variable "name_prefix" {
  type        = string
  description = "Prefix to be used in the naming of some of the created resources."
}

variable "aws_region" {
  type        = string
  description = "AWS region for creating the resources"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name for tagging and resource naming"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project name for tagging"
  default     = "Static Website"
}
