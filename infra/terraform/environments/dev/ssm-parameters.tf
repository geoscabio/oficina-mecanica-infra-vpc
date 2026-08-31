resource "aws_ssm_parameter" "vpc_id" {
  name        = "${local.ssm_prefix}/id"
  description = "ID da VPC compartilhada da Oficina Mecânica."
  type        = "String"
  value       = module.vpc.vpc_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "${local.ssm_prefix}/public-subnet-ids"
  description = "IDs das subnets públicas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.public_subnet_ids)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "${local.ssm_prefix}/private-subnet-ids"
  description = "IDs das subnets privadas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.private_subnet_ids)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "private_subnet_cidrs" {
  name        = "${local.ssm_prefix}/private-subnet-cidrs"
  description = "CIDRs das subnets privadas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.private_subnet_cidrs)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "nat_gateway_id" {
  name        = "${local.ssm_prefix}/nat-gateway-id"
  description = "ID do NAT Gateway da Oficina Mecânica."
  type        = "String"
  value       = module.vpc.nat_gateway_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "status" {
  name        = "${local.ssm_prefix}/status"
  description = "Status operacional da VPC compartilhada da Oficina Mecânica."
  type        = "String"
  value       = "ready"

  tags = local.common_tags
}