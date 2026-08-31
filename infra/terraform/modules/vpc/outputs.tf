output "vpc_id" {
  description = "ID da VPC criada."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas."
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas."
  value       = var.private_subnet_cidrs
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway."
  value       = aws_nat_gateway.this.id
}