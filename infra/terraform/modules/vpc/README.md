# 🌐 VPC Module

Módulo Terraform responsável pela rede base da Oficina Mecânica.

## 📦 Recursos

- VPC com DNS habilitado.
- Duas subnets públicas.
- Duas subnets privadas.
- Internet Gateway.
- NAT Gateway.
- Route table pública.
- Route table privada.
- Associações entre subnets e route tables.

## 🧠 Decisão

As subnets privadas recebem a tag `kubernetes.io/role/internal-elb=1` para permitir o uso futuro de Load Balancer interno no EKS, integrado ao API Gateway por VPC Link.

As subnets públicas recebem a tag `kubernetes.io/role/elb=1` para manter compatibilidade com recursos públicos controlados quando necessário.

## 🔌 Inputs principais

| Variável | Descrição |
| --- | --- |
| `name` | Nome base da VPC e dos recursos relacionados. |
| `cidr_block` | CIDR principal da VPC. |
| `availability_zones` | Zonas de disponibilidade utilizadas. |
| `public_subnet_cidrs` | CIDRs das subnets públicas. |
| `private_subnet_cidrs` | CIDRs das subnets privadas. |
| `tags` | Tags comuns aplicadas aos recursos. |

## 📤 Outputs principais

| Output | Descrição |
| --- | --- |
| `vpc_id` | ID da VPC criada. |
| `public_subnet_ids` | IDs das subnets públicas. |
| `private_subnet_ids` | IDs das subnets privadas. |
| `private_subnet_cidrs` | CIDRs das subnets privadas. |
| `nat_gateway_id` | ID do NAT Gateway. |