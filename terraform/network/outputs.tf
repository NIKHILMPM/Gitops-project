output "vpc_id" {
  value = aws_default_vpc.this.id
}

output "subnet_ids" {
  value = data.aws_subnets.this.ids
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "key_name" {
  value = aws_key_pair.this.key_name
}
