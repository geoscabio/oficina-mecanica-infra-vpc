variable "name" {
  description = "Nome da VPC."
  type        = string
}

variable "cidr_block" {
  description = "Bloco CIDR da VPC."
  type        = string
}

variable "availability_zones" {
  description = "Zonas de disponibilidade onde os recursos serão criados."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas."
  type        = list(string)
}

variable "tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
  default     = {}
}