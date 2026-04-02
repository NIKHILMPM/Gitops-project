#####################################
# KEY PAIR
#####################################
resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#####################################
# DEFAULT VPC (SAFE READ)
#####################################
data "aws_vpc" "default" {
  default = true
}

#####################################
# SUBNETS
#####################################
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = var.azs
  }
}

#####################################
# SECURITY GROUP
#####################################
resource "aws_security_group" "this" {
  name   = var.sg_name
  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

