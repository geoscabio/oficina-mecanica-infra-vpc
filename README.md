# 🌐 Oficina Mecânica Infra VPC

Infraestrutura de rede AWS da **Oficina Mecânica**, criada para a **Fase 3 do Tech Challenge FIAP**.

Este repositório provisiona somente a base de rede compartilhada pelos demais recursos da solução. A ideia é ser simples, previsível e fácil de operar: VPC primeiro, depois RDS, Kubernetes, Lambda/API Gateway e aplicação.

---

## 🎯 Objetivo

Criar a fundação de rede do ambiente `development` na AWS, mantendo a separação por responsabilidade definida para a Fase 3.

Este repo cuida de:

- VPC da solução.
- Subnets públicas e privadas em duas zonas de disponibilidade.
- Internet Gateway para entrada/saída pública controlada.
- NAT Gateway para saída das subnets privadas.
- Route tables públicas e privadas.
- Publicação dos outputs principais no AWS Systems Manager Parameter Store.

---

## 🧭 Papel na arquitetura

```text
Internet
   │
   ▼
API Gateway ───────────────┐
                            │
                      VPC Link futuro
                            │
                            ▼
                  NLB interno da API
                            │
                            ▼
              EKS / oficina-mecanica-api
                            │
                            ▼
                    RDS SQL Server
```

A VPC é a primeira peça da infraestrutura. Os demais repositórios devem consumir seus identificadores via **SSM Parameter Store**, evitando cópia manual de IDs entre pipelines.

---

## 📦 Recursos criados

| Recurso | Nome padrão | Responsabilidade |
| --- | --- | --- |
| VPC | `oficina-mecanica-vpc-dev` | Isolamento lógico da rede AWS. |
| Public Subnets | `oficina-mecanica-vpc-dev-public-*` | NAT Gateway e recursos públicos controlados. |
| Private Subnets | `oficina-mecanica-vpc-dev-private-*` | EKS, RDS e integrações privadas. |
| Internet Gateway | `oficina-mecanica-vpc-dev-igw` | Saída/entrada pública da VPC. |
| NAT Gateway | `oficina-mecanica-vpc-dev-nat` | Saída para internet das subnets privadas. |
| Route Tables | `oficina-mecanica-vpc-dev-*-rt` | Rotas públicas e privadas. |
| SSM Parameters | `/oficina-mecanica/development/vpc/*` | Compartilhamento dos outputs entre repositórios. |
| SSM Status | `/oficina-mecanica/development/status/vpc` | Marcador usado por repositórios dependentes. |

---

## 📁 Estrutura

```text
.
├── .github/workflows/                    # CI/CD do Terraform
└── infra/terraform/
    ├── environments/dev/                 # Ambiente development
    └── modules/vpc/                      # Módulo reutilizável de VPC
```

---

## 🚀 Execução local

Pré-requisitos:

- Terraform `1.15.8` instalado.
- AWS CLI autenticado no AWS Academy.
- Região `us-east-1`.

```powershell
terraform -chdir="infra/terraform/environments/dev" init
terraform fmt -recursive infra/terraform
terraform -chdir="infra/terraform/environments/dev" validate
terraform -chdir="infra/terraform/environments/dev" plan
```

Para aplicar localmente:

```powershell
terraform -chdir="infra/terraform/environments/dev" apply
```

Para destruir localmente:

```powershell
terraform -chdir="infra/terraform/environments/dev" destroy
```

> Preferência do projeto: usar a esteira do GitHub Actions para `apply` e `destroy`, mantendo rastreabilidade.

---

## 🔁 CI/CD

A esteira segue o mesmo modelo da API, mas focada somente em Terraform:

| Workflow | Quando roda | O que faz |
| --- | --- | --- |
| `🧪 CI Development` | Pull request para `develop` | Verifica formatação, inicialização e validação do Terraform. |
| `🔎 CI Release` | Pull request para `release` ou `release/**` | Verifica formatação, inicialização e validação do Terraform. |
| `🛡️ CI Production` | Pull request para `main` | Verifica formatação, inicialização e validação do Terraform. |
| `🚀 CD Development` | Push na `develop` | Executa `apply` ou `destroy` em `development`. |
| `☁️ AWS Deploy` | Chamado pelo CD de desenvolvimento | Executa `apply` ou `destroy` da VPC conforme controle versionado. |
| `🔀 CD Release` | Push na `release` ou `release/**` | Registra promoção lógica para homologation e abre PR para `main` quando habilitado. |
| `🏁 CD Production` | Push na `main` | Registra promoção lógica para production. |

A ação real do Terraform é controlada por:

```text
infra/terraform/environments/dev/terraform-action.env
```

Valores aceitos:

```env
TERRAFORM_ACTION=apply
TERRAFORM_ACTION=destroy
```

### Proteção de branches

As branches `develop`, `release`, `release/*` e `main` usam dois rulesets ativos:

- **🔒 Proteção Git Flow, sem bypass:** PR obrigatório, conversas resolvidas, checks `🔀 01 · Validar fluxo de branches` e `🚦 03 · Quality gate` aprovados e bloqueio de push direto, force push e deleção. A lista de bypass fica vazia, inclusive para admins e maintainers.
- **👥 Aprovação de PR:** uma aprovação humana, descarte de aprovações antigas e aprovação por alguém diferente do último autor do push. Somente esta regra permite bypass via PR para `geoscabio`, `sousagabriel14`, maintainers e admins.

O bypass dispensa a revisão de outra pessoa, nunca o fluxo ou os checks. O GitHub permite abrir um PR fora do caminho `branch de trabalho -> develop -> release -> main`, mas a validação bloqueia seu merge. Hotfix permanece pós-entrega, sem exceção habilitada.

O ruleset de fluxo usa `strict_required_status_checks_policy=false` para não exigir promoção inversa entre branches; checks continuam obrigatórios e conflitos reais precisam ser resolvidos. O proprietário ainda pode alterar as configurações administrativas: o bloqueio depende dos rulesets ativos e da integridade dos workflows de validação.

Repetir este padrão em cada novo repositório. A configuração detalhada está no [guia de GitHub Actions da API](https://github.com/geoscabio/oficina-mecanica-api/blob/develop/docs/deploy/github-actions.md#-proteções-obrigatórias-recomendadas).

O título de execução do `🔀 CD Release` é `🔀 Registrar deploy em release`; produção só é registrada depois do merge em `main`.

---

## 🧨 Ordem de operação

### Apply da solução completa

```text
1. oficina-mecanica-infra-vpc
2. oficina-mecanica-infra-rds e oficina-mecanica-infra-kubernetes
3. oficina-mecanica-auth-lambda
4. oficina-mecanica-api
5. oficina-mecanica-infra-api-gateway
```

### Destroy da solução completa

```text
1. oficina-mecanica-infra-api-gateway
2. oficina-mecanica-api
3. oficina-mecanica-auth-lambda
4. oficina-mecanica-infra-kubernetes e oficina-mecanica-infra-rds
5. oficina-mecanica-infra-vpc
```

A VPC deve ser a última a ser destruída, porque os demais recursos dependem dela.

---

## 🔐 Secrets e variáveis

Configurar no GitHub Environment `development`:

| Tipo | Nome | Uso |
| --- | --- | --- |
| Secret | `AWS_ACCESS_KEY_ID` | Autenticação AWS. |
| Secret | `AWS_SECRET_ACCESS_KEY` | Autenticação AWS. |
| Secret | `AWS_SESSION_TOKEN` | Sessão temporária do AWS Academy. |
| Variable | `AWS_REGION` | Região AWS, padrão `us-east-1`. |
| Variable | `AUTO_PR_ENABLED` | Abre PR automático para `release` quando `true`. |
| Variable | `RELEASE_BRANCH` | Branch de release, padrão `release`. |

Nenhum segredo deve ser versionado no repositório.

---

## ✅ Boas práticas adotadas

- Responsabilidade única por repositório e por pipeline.
- Terraform separado por `environment` e `module`.
- Tags padronizadas em todos os recursos.
- Outputs compartilhados por SSM Parameter Store.
- Controle explícito de `apply` e `destroy`.
- Validação real da VPC após `apply` e após `destroy`.
- Nomenclatura com prefixo `oficina-mecanica-*`.
