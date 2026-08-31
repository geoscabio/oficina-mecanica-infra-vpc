output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas."
  value       = module.vpc.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas."
  value       = module.vpc.private_subnet_cidrs
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway."
  value       = module.vpc.nat_gateway_id
}

output "ssm_vpc_prefix" {
  description = "Prefixo dos parâmetros SSM publicados para os demais repositórios."
  value       = local.ssm_prefix
}