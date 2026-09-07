# Instruções do repositório

## Escopo e autonomia

- Trabalhe somente no escopo solicitado e preserve alterações locais existentes.
- Quando a tarefa estiver clara, proponha um plano curto com arquivos, estratégia, validações e riscos; após aprovação explícita do plano, execute alterações locais e validações não destrutivas sem microaprovações.
- Decisões pequenas, reversíveis e dentro do plano aprovado podem ser tomadas tecnicamente e registradas no resumo final.
- Pare e peça direcionamento diante de risco de perda de dados, impacto externo não autorizado, divergência de repositório ou branch, ambiguidade relevante ou decisão arquitetural.

## Git e documentação

- Não crie branch, commit, tag, push, merge ou Pull Request sem autorização explícita.
- Antes de uma tarefa dependente de repositório ou branch, valide `origin`, branch atual e status Git.
- Commits autorizados devem seguir Conventional Commits e nunca atribuir autoria a IA.
- Escreva em português brasileiro, preserve UTF-8 e não remova acentuação para contornar encoding.

## Terraform, AWS e VPC

- Não execute `terraform apply`, `terraform destroy`, operações AWS reais ou `kubectl apply` sem autorização explícita.
- Preserve state; nunca execute `terraform state mv`, `terraform import` ou renomes que afetem state sem aprovação. Use `moved` blocks quando uma alteração autorizada renomear endereços Terraform.
- Antes do destroy da VPC, confirme que as esteiras dependentes foram removidas ou estão explicitamente fora de uso; a VPC deve ser a última infraestrutura compartilhada a sair.
- Prefira validações locais de menor impacto: `terraform fmt -check -recursive` e `terraform init -backend=false -input=false` seguido de `terraform validate` quando os providers estiverem acessíveis.
- Diferencie falhas da configuração de falhas de rede, registry, provider, credenciais ou AWS Academy.
- Nunca exponha secrets, tokens, state com dados sensíveis ou arquivos `.env`.

## Destroy parcial e guardrails

- `TERRAFORM_ACTION=destroy` deve manter o guardrail de alteração dedicada no `terraform-action.env`.
- O destroy deve gerar exclusivamente `terraform plan -destroy -input=false -out=tfplan` e aplicar apenas esse `tfplan` salvo.
- Não introduza, durante destroy, `apply` normal, apply direcionado ou fluxo que transforme recuperação em provisionamento.
- Trate VPC e parâmetros SSM já ausentes como recuperação idempotente somente quando a resposta AWS confirmar `InvalidVpcID.NotFound` ou `ParameterNotFound`; `AccessDenied`, token expirado, credencial inválida e demais falhas reais devem bloquear.
- Confirme a limpeza de todos os parâmetros VPC compartilhados no SSM sem mascarar falhas de consulta como ausência.
