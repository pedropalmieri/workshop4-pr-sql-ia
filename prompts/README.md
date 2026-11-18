# Prompts do Workshop 4

Prompts de texto para usar em qualquer assistente que aceite uma conversa. Eles não dependem de Copilot Pro, extensão, integração, API ou recurso específico de um fornecedor. A qualidade da resposta varia entre modelos: o resultado deve ser analisado e validado pelo Fellow.

Cada arquivo de 01 a 08 contém o contexto completo do caso e uma tarefa delimitada. Pode ser copiado integralmente para uma nova conversa, inclusive em outra ferramenta. O arquivo 09 retoma uma conversa que saiu do papel de Tutora.

## Escolha pela tarefa

| Prompt | Objetivo | Informação a fornecer |
|---|---|---|
| [01 · Diagnosticar a consulta](01-diagnosticar-consulta.txt) | Explicar a divergência entre o SQL inicial e o contrato | Já inclui SQL, dados e resultado do caso |
| [02 · Revisar alteração humana](02-revisar-alteracao-humana.txt) | Analisar uma alteração sem delegar a implementação | SQL anterior/atual, resultado e testes reais |
| [03 · Planejar testes](03-planejar-testes-consulta.txt) | Compreender cenários e expectativas independentes | Já inclui contrato e dados do caso |
| [04 · COUNT, NULL e zero](04-explicar-count-e-zero.txt) | Responder às questões de contagem e pagamento zero | Já delimita o JOIN analisado |
| [05 · Avaliar alternativa](05-avaliar-alternativa-com-evidencia.txt) | Analisar a exclusão de totais zero | Já identifica a hipótese como proposta da pessoa |
| [06 · Interpretar plano](06-interpretar-plano-execucao.txt) | Explicar EXPLAIN e medições sem inventar performance | Consulta, comando e plano real |
| [07 · Analisar PR](07-analisar-pull-request.txt) | Relacionar diff, estado, testes e decisões | Diff, estado declarado, evidência e registro reais |
| [08 · Organizar registro](08-organizar-registro-real.txt) | Estruturar a interação realmente ocorrida | Conversa, decisão e validação reais |
| [09 · Retomar tutoria](09-redirecionar-para-tutoria.txt) | Redirecionar resposta com código pronto ou extrapolação | Contexto da conversa anterior |

## Uso

1. Abra o arquivo da tarefa e copie o texto completo para o assistente escolhido.
2. Nos arquivos com campos entre colchetes, substitua-os pelos dados reais. Não deixe o modelo adivinhar esses campos.
3. Leia a resposta, responda às perguntas e confira as alegações no PostgreSQL e nos testes.
4. Faça a alteração por conta própria quando necessário. O prompt não delega a implementação nem o merge.
5. Registre a ferramenta, o modelo exibido quando disponível, a orientação, a decisão e a evidência da validação.

Os dados do caso são fictícios. Não envie credenciais, tokens ou dados pessoais reais. Não é preciso usar todos os prompts: cada arquivo atende a uma tarefa, sem criar atividades ou entregas adicionais.

## Critério de uma resposta útil

Uma resposta útil explica o requisito afetado, relaciona o raciocínio aos dados e deixa claro o que precisa de comprovação. Respostas confiantes, por si só, não são evidência. O assistente não recebeu acesso ao banco e não pode declarar a execução de testes a partir do texto do prompt.

As [consultas comentadas](../exemplos/respostas-questoes-slides.sql) permitem conferir as questões no pgAdmin. O [modelo de registro](../docs/registro-ia-modelo.md) preserva a decisão humana. A hipótese do prompt 05 foi proposta pela pessoa que pergunta e não deve ser registrada como sugestão espontânea da IA.
