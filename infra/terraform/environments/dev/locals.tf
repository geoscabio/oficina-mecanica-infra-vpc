locals {
  project_name = "OficinaMecanica"

  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "oficina-mecanica-infra-vpc"
  }

  ssm_prefix        = "/oficina-mecanica/development/vpc"
  ssm_status_prefix = "/oficina-mecanica/development/status"
}
