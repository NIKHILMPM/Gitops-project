variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}


variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}

variable "ingress_ports" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))

  default = [
    { from_port = 22,    to_port = 22,    protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 80,    to_port = 80,    protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443,   to_port = 443,   protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 3000,  to_port = 3000,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 3001,  to_port = 3001,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 5000,  to_port = 5000,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 8000,  to_port = 8000,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 8001,  to_port = 8001,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 8080,  to_port = 8080,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 8081,  to_port = 8081,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 9000,  to_port = 9000,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 9090,  to_port = 9090,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 6443,  to_port = 6443,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 30000, to_port = 32767, protocol = "tcp", cidr = "0.0.0.0/0" }
  ]
}

variable "email" {
  description = "cert issuer email"
  type = string
}