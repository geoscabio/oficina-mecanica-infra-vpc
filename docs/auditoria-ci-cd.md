# Auditoria de CI/CD — 08/09/2026

## Escopo

Comparação dos quatro repositórios Oficina Mecânica: API, VPC, Kubernetes e RDS.
Foram examinados workflows, condições, permissões, concorrência, artefatos,
Git Flow, documentação, Terraform, contratos entre esteiras e regras remotas.
Nenhum deploy, import, apply, destroy ou merge foi executado nesta auditoria.

## Correções

- Três CIs duplicadas por ambiente substituídas por um único `ci.yml`.
- PRs e pushes de branches protegidas usam o mesmo conjunto de validações.
- CD exige CI `push` bem-sucedida do SHA, branch e repositório exatos.
- Timeout, falha, cancelamento e ausência de CI bloqueiam a entrega.
- Concorrência do CD não interrompe operações Terraform em andamento.
- Promoção para release exige sucesso da operação física; deploy pulado não é sucesso físico.
- Arquivos não Markdown em `docs/` não escapam das validações de código.
- Os nomes do Git Flow e Quality gate foram mantidos, compatíveis com os rulesets.
- Testes automatizados cobrem os bloqueios entre CI e CD, inclusive respostas da API e execuções de forks.

## Governança verificada

Os quatro repositórios têm rulesets ativos `Proteção Git Flow` e `Aprovação de PR`.
A proteção de fluxo não tem bypass e exige os checks existentes e conversas
resolvidas. A regra de aprovação possui exceções explícitas para os dois membros
e papéis administrativos, conforme documentação vigente. Essas configurações não
foram alteradas. Apenas `development` existe como GitHub Environment, restrito
por política de branch. Homologação e produção são promoções lógicas (ADR-0010).

## Limites e dívidas identificadas

- A separação da infraestrutura da API ainda está em transição: a API mantém
  módulos próprios de VPC, EKS, ECR e RDS, enquanto as esteiras extraídas têm
  seus contratos SSM. A migração exige planejar a transferência de ownership e
  state conforme RFC-0003/0004/0005. Não se deve aplicar as duas topologias sobre
  os mesmos recursos. Esta auditoria não move nem importa state.
- O cache de GitHub Actions continua sendo o backend operacional de state
  conforme ADR-0012; retenção/evicção continua sendo um risco existente.
- `release` e `main` não testam runtime físico em ambientes separados. Criar
  esses ambientes exigiria infraestrutura e configuração de aprovação próprias.
- A automação de PR depende de `AUTO_PR_ENABLED` e da permissão do GitHub para
  criação de PR. Nenhuma permissão administrativa foi habilitada nesta entrega.
- Planos Terraform reais, contratos SSM vivos e rollout AWS dependem de uma
  execução autorizada de infraestrutura; não foram apresentados como validados.

## Validação

`actionlint` passou em todos os workflows. Os 13 testes do bloqueio CI/CD passaram
em cada repositório. `terraform fmt -check -recursive infra/terraform` passou.
`terraform init -backend=false -input=false` e `terraform validate` também passaram nos quatro repositórios. A validação remota do PR é a evidência dos checks de integração desta alteração.

## Operação

O CD ainda é disparado por `push` protegido, mas aguarda a CI antes de qualquer
operação. Isso preserva o payload `before` usado pelo guardrail de destroy.
Uma CI ausente ou expirada não autoriza o CD: reexecute a CI do mesmo commit e
então repita o CD. Não há fallback para outro SHA ou para uma CI de pull request.
