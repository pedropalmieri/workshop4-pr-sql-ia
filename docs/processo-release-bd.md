# Pessoas, aprovação e release de banco

Uma mudança de banco afeta quem produz e quem consome os dados. O processo relaciona a necessidade, o SQL, as evidências e a autorização para executar a mudança.

## Identidades individuais

Cada pessoa utiliza sua própria conta GitHub. A autora envia commits e abre o PR com sua identidade. Uma pessoa diferente revisa o impacto, comenta e registra a aprovação com a própria conta. O responsável pela liberação também registra sua decisão individualmente. Não se utiliza uma conta universal para representar essas pessoas.

Configure nome e e-mail Git associados à sua conta. Uma identidade de commit é metadado; assinatura de commits, contas protegidas e revisão autenticada fortalecem a confiança. O PR mostra a conta que o abriu e as contas que revisaram. O workflow usa uma identidade técnica de automação, ligada ao commit e à execução; isso não substitui a identidade dos participantes.

## Sequência de uma release

| Etapa | Responsável e evidência |
|---|---|
| 1. Abrir o card | Solicitante descreve objetivo, critérios de aceite, risco, dependências e release planejada |
| 2. Implementar na develop | Autor cria novo script numerado e teste, preservando versões anteriores |
| 3. Validar a proposta | Workflow verifica sintaxe, execução, contratos de resultado e regressões |
| 4. Revisar o PR | Outra pessoa avalia o diff, evidências e impacto, pede ajustes ou aprova |
| 5. Aprovar a liberação | Responsável confirma no card o escopo, a versão, a janela e o plano de recuperação |
| 6. Promover e executar | Após as aprovações, merge para main e workflow de deploy da versão autorizada |
| 7. Conferir e encerrar | Equipe verifica o banco, registra execução/commit e encerra o card |

Em um ambiente corporativo, o card pode registrar título, objetivo, critérios de aceite, release planejada, PR, evidências, plano de recuperação e decisão de liberação. Relacione esse card no PR. Uma release pode reunir mais de um script, como a alteração de coluna e a consulta adaptada. A numeração do script identifica a ordem de execução; a versão da release identifica o conjunto aprovado. São identificadores diferentes.

O card pode estar no GitHub Issues ou na ferramenta de trabalho da equipe. A decisão deve ser registrada na ferramenta usada, sem inventar uma aprovação. Uma tag/release do Git deve apontar para o commit efetivamente liberado e conter os scripts e as evidências daquele pacote.

## Exemplo: coluna alterada e relatório incompatível

Card: “Renomear description para name mantendo o contrato do relatório de clientes”. O autor apresenta o ALTER e o novo SELECT com alias no mesmo PR. A validação demonstra que o ALTER isolado quebra a consulta anterior e que a adaptação preserva Ana e Bruno. Outro usuário revisa, aprova e registra sua decisão. O responsável autoriza a release. Somente então a equipe promove e executa o deploy. O histórico relaciona card, PR, participantes, commit, release e execução.

## Configuração deste laboratório

A main exige PR e quatro checks aprovados, inclusive para administradores. O merge é manual; o workflow aplica os scripts pendentes depois dele. A demonstração usa a conta do proprietário, por isso a proteção está com **zero aprovações externas obrigatórias**. Isso permite testar a esteira com uma única conta; não demonstra uma aprovação independente que não aconteceu.

O processo de equipe acima prevê outro revisor e aprovação de liberação. Para torná-los barreiras técnicas em um ambiente real, configure ao menos uma aprovação obrigatória no PR e a aprovação do ambiente de deploy, além do controle do card. O workflow atual não consulta o card nem impõe uma aprovação separada de ambiente. Enquanto essas barreiras não estiverem configuradas, a conferência dessas aprovações é uma responsabilidade explícita antes do merge.

## Mudanças fora do processo

A autoria dos commits, PRs e aprovações fica no GitHub com as contas individuais. Um comando executado diretamente no banco não passa a ter autoria no Git automaticamente. Identificar esse acesso exige contas individuais também no banco, permissões adequadas e auditoria de DDL. A proteção da main protege o repositório, não as credenciais de acesso direto ao PostgreSQL.
