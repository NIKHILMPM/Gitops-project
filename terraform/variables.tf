#####################################
# GENERAL
#####################################

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

#####################################
# GITHUB (Image Updater)
#####################################

variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}