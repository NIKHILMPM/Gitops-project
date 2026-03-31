variable "key_name" {}
variable "public_key_path" {}

variable "sg_name" {
  default = "eks-sg"
}

variable "azs" {
  type = list(string)
}

variable "ingress_ports" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))
}
