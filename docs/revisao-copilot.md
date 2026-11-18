# Revisão de SQL com GitHub Copilot

## Estado da configuração

Em 18/11/2026, a conta `pedropalmieri` aparece com **GitHub Copilot Free**. A interface informa que revisões de IA exigem upgrade. A revisão de PRs não foi habilitada nem testada nesta conta. Nenhuma assinatura foi contratada.

O repositório é privado e a API de rulesets respondeu que o plano atual exige GitHub Pro ou repositório público para usar essa configuração. A visibilidade permanece privada. Essa limitação é distinta da licença Copilot: ter GitHub Pro não equivale a ter Copilot Pro.

As [instruções de revisão](../.github/copilot-instructions.md) estão preparadas. Elas fornecem o contrato, os dados e os pontos de atenção do SQL. O arquivo, sozinho, não ativa um revisor.

## Papel de cada componente

| Componente | Responsabilidade |
|---|---|
| Copilot code review, quando disponível | Analisar o diff e oferecer comentários e explicações sobre possíveis problemas |
| Workflow Testes SQL | Executar a consulta e os testes no PostgreSQL e produzir evidência do resultado |
| Fellow | Interpretar a orientação, alterar o código, executar/acompanhar os testes e registrar a decisão |
| Workflow de aplicação | Aplicar o estado declarado após o merge e desfazer a tentativa quando sua validação falhar |

Para manter o papel de Tutora, use a revisão para explicação e investigação. A orientação do arquivo pede comentários conceituais e perguntas, sem implementação completa ou decisão de merge. Essas instruções orientam o comportamento do modelo, mas não garantem respostas sempre corretas ou ausência de sugestões de código. A pessoa responsável deve avaliar a resposta e preservar o papel exigido pelo workshop.

## Habilitação quando houver licença compatível

A documentação do GitHub lista Copilot Pro, Pro+, Max, Business e Enterprise para a configuração de revisão. A disponibilidade também depende das políticas da conta e do repositório.

1. Com uma licença que inclua revisão, abra um PR e escolha Copilot no campo **Reviewers**, quando disponível.
2. Mantenha habilitado o uso de instruções personalizadas para que o revisor receba `.github/copilot-instructions.md`.
3. Para revisão automática específica da main, quando rulesets estiverem disponíveis no plano do repositório privado, crie uma regra de branch com **Automatically request Copilot code review**.
4. **Review new pushes** permite nova revisão após alterações. O recurso pode consumir a cota de uso do Copilot; confira o plano antes de habilitar revisões automáticas.
5. A configuração pessoal de revisão automática é uma alternativa oferecida pelo GitHub, mas pode afetar PRs próprios em outros repositórios. Ela não foi alterada nesta preparação.

Não há necessidade de trocar o repositório para público. Não é necessário permitir aprovação automática ou que aprovações do Copilot contem para o merge para usar seus comentários de revisão.

## Como conferir a revisão de uma consulta

A revisão deve relacionar seu comentário ao contrato e aos dados. Pontos do caso: preservar Bruno e Carla, diferenciar COUNT(*) e COUNT(p.id), manter o pedido pago de valor zero de Diego e explicar ON versus WHERE.

O estado inicial é intencional e deve manter a falha conhecida do contrato. Uma correção precisa declarar o estado corrigido e passar nos dois cenários. Não aceite uma proposta de remover clientes ou flexibilizar o teste para obter um check verde.

Uma revisão efetiva só pode ser declarada depois que o Copilot publicar seus comentários no PR. O registro deve preservar o comentário real, a decisão e a evidência da validação. Não há revisão real do Copilot registrada até esta preparação.

## Referências

[Configurar revisão Copilot](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-code-review), [instruções por repositório](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions) e [capacidades e limitações](https://docs.github.com/en/copilot/responsible-use/agents).
