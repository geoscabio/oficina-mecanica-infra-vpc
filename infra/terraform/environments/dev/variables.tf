variable "aws_region" {
  description = "Região AWS onde a VPC será provisionada."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente provisionado."
  type        = string
  default     = "development"
}

variable "vpc_name" {
  description = "Nome da VPC da Oficina Mecânica."
  type        = string
  default     = "oficina-mecanica-vpc-dev"
}

variable "vpc_cidr_block" {
  description = "Bloco CIDR principal da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade usadas pela rede."
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas."
  type        = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}