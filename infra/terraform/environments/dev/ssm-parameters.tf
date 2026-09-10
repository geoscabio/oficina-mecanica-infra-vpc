resource "aws_ssm_parameter" "vpc_id" {
  name        = "${local.ssm_prefix}/vpc_id"
  description = "ID da VPC compartilhada da Oficina Mecânica."
  type        = "String"
  value       = module.vpc.vpc_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "${local.ssm_prefix}/public_subnet_ids"
  description = "IDs das subnets públicas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.public_subnet_ids)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "${local.ssm_prefix}/private_subnet_ids"
  description = "IDs das subnets privadas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.private_subnet_ids)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "private_subnet_cidrs" {
  name        = "${local.ssm_prefix}/private_subnet_cidrs"
  description = "CIDRs das subnets privadas da Oficina Mecânica."
  type        = "StringList"
  value       = join(",", module.vpc.private_subnet_cidrs)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "nat_gateway_id" {
  name        = "${local.ssm_prefix}/nat_gateway_id"
  description = "ID do NAT Gateway da Oficina Mecânica."
  type        = "String"
  value       = module.vpc.nat_gateway_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "status" {
  # Publicar ready somente após concluir a infraestrutura e seus contratos SSM.
  depends_on = [
    module.vpc,
    aws_ssm_parameter.vpc_id,
    aws_ssm_parameter.public_subnet_ids,
    aws_ssm_parameter.private_subnet_ids,
    aws_ssm_parameter.private_subnet_cidrs,
    aws_ssm_parameter.nat_gateway_id,
  ]

  name        = "${local.ssm_status_prefix}/vpc"
  description = "Status operacional da VPC compartilhada da Oficina Mecânica."
  type        = "String"
  value       = "ready"

  tags = local.common_tags
}
