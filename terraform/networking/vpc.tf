#####################################
# KEY PAIR
#####################################

resource "aws_key_pair" "my_public_key" {
  key_name   = "terra-key-ec2"
  public_key = file("${path.module}/../terra-key-ec2.pub")

  tags = {
    Name = "eks-key"
  }
}

#####################################
# DEFAULT VPC
#####################################

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#####################################
# SUBNETS
#####################################

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

#####################################
# SECURITY GROUP
#####################################

resource "aws_security_group" "my_security_group" {
  name        = "my-sg"
  description = "security group for EKS nodes"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}

#####################################
# OUTPUTS
#####################################

output "vpc_id" {
  value = aws_default_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "security_group_id" {
  value = aws_security_group.my_security_group.id
}