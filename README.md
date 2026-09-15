# Oficina Mecânica — Infraestrutura VPC

Rede base da solução Oficina Mecânica. A visão geral está no
[README da API](https://github.com/geoscabio/oficina-mecanica-api#readme).

## Responsabilidade e arquitetura

Este repositório cria a VPC, sub-redes públicas e privadas, NAT Gateway e os
contratos SSM que desacoplam os demais repositórios. Ele não cria EKS, RDS,
API Gateway nem carga de aplicação.

`Internet -> sub-redes públicas/NAT -> workloads em sub-redes privadas`

## Repositórios da solução

| Repositório | Responsabilidade |
|---|---|
| [API](https://github.com/geoscabio/oficina-mecanica-api) | Aplicação .NET e documentação de entrada. |
| [Auth Lambda](https://github.com/geoscabio/oficina-mecanica-auth-lambda) | Autenticação por documento e JWT. |
| [VPC](https://github.com/geoscabio/oficina-mecanica-infra-vpc) | Rede base compartilhada. |
| [Kubernetes](https://github.com/geoscabio/oficina-mecanica-infra-kubernetes) | EKS, ECR e NLB interno. |
| [RDS](https://github.com/geoscabio/oficina-mecanica-infra-rds) | SQL Server privado. |
| [API Gateway](https://github.com/geoscabio/oficina-mecanica-infra-api-gateway) | Entrada HTTP e VPC Link. |

## Tecnologias e pré-requisitos

Terraform, AWS VPC, AWS Systems Manager Parameter Store e GitHub Actions.
Para execução local, instale Terraform e AWS CLI e configure credenciais com
permissão para os recursos de rede.

## Configuração, secrets e contratos

| Nome | Tipo e escopo | Obrigatório | Finalidade |
|---|---|---:|---|
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` | GitHub Environment Secrets (`development`) | Sim | Credenciais AWS do workflow. |
| `AWS_SESSION_TOKEN` | GitHub Environment Secret (`development`) | Quando temporário | Token de sessão AWS. |
| `AWS_REGION` | GitHub Variable | Sim | Região AWS. |
| `AUTO_PR_ENABLED`, `RELEASE_BRANCH` | GitHub Variables | Não | Fluxo de promoção. |

Após o apply, este repositório publica os contratos abaixo no Parameter Store:

| Parâmetro SSM |
|---|
| `/oficina-mecanica/development/vpc/vpc_id` |
| `/oficina-mecanica/development/vpc/public_subnet_ids` |
| `/oficina-mecanica/development/vpc/private_subnet_ids` |
| `/oficina-mecanica/development/vpc/private_subnet_cidrs` |
| `/oficina-mecanica/development/vpc/nat_gateway_id` |
| `/oficina-mecanica/development/status/vpc` |

EKS, RDS, Auth Lambda e API Gateway consomem esses contratos; nenhum valor
sensível é publicado aqui.

## Execução, CI/CD, deploy e validações

O workflow `aws-deploy.yml` preserva os fluxos de `plan`, `apply` e `destroy`.
No diretório Terraform, execute:

```powershell
terraform fmt -check
terraform validate
terraform plan
```

Os sinais operacionais são os serviços nativos AWS; Datadog não é configurado
neste repositório. A validação de infraestrutura deve incluir os checks do
workflow e `git diff --check`.

Documentação relacionada: [API principal](https://github.com/geoscabio/oficina-mecanica-api#readme),
[AWS VPC](https://docs.aws.amazon.com/vpc/) e
[Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).
