# Prompts do Workshop 4

O contexto do caso é enviado uma vez. Depois, cada pergunta fica em um prompt curto, de 4 a 9 linhas, para leitura e discussão com a turma. Os textos podem ser usados em qualquer assistente de linguagem, sem integração ou licença específica.

## Como usar

1. Envie [00 · Contexto do caso](00-contexto-do-caso.txt) ao iniciar a conversa.
2. Escolha uma tarefa abaixo. Substitua os campos entre colchetes por SQL, resultados ou evidências reais e envie o prompt na mesma conversa.
3. Confira a resposta com os dados e os testes. O Fellow implementa, executa e decide.

Ao abrir outra conversa ou mudar de ferramenta, envie novamente o contexto 00. Os prompts curtos dependem desse contexto; não precisam repetir as tabelas e as regras em cada pergunta.

## Perguntas por tarefa

| Prompt | Objetivo | O que acrescentar |
|---|---|---|
| [01 · Diagnóstico](01-diagnosticar-consulta.txt) | Investigar a ausência de Bruno e Carla | O SELECT da versão inicial |
| [02 · Revisão da alteração](02-revisar-alteracao-humana.txt) | Examinar a mudança feita pelo Fellow | SQL anterior/atual, resultado e testes |
| [03 · Testes](03-planejar-testes-consulta.txt) | Definir cenários e expectativas | O contexto 00 já fornece os dados |
| [04 · Contagem e zero](04-explicar-count-e-zero.txt) | Explicar COUNT, NULL, SUM e COALESCE | O contexto 00 já fornece os dados |
| [05 · Análise crítica](05-avaliar-alternativa-com-evidencia.txt) | Avaliar a exclusão de totais zero | A hipótese já está identificada como proposta da pessoa |
| [06 · Plano de execução](06-interpretar-plano-execucao.txt) | Interpretar EXPLAIN | Consulta, comando e plano real |
| [07 · Pull Request](07-analisar-pull-request.txt) | Relacionar diff, estado, testes e decisões | Evidências reais do PR |
| [08 · Registro](08-organizar-registro-real.txt) | Organizar a interação ocorrida | Conversa, decisão e validação reais |
| [09 · Retomar tutoria](09-redirecionar-para-tutoria.txt) | Redirecionar uma resposta fora do papel | Use na conversa em andamento |

Para o diagnóstico, envie a [consulta inicial](../exemplos/consulta-inicial.sql) junto com o prompt 01. O arquivo contém a consulta e comentários sobre o resultado observado.

As respostas devem explicar e orientar a investigação, sem entregar a implementação pronta. Não envie credenciais nem invente sugestões ou resultados para preencher o registro. As [consultas comentadas](../exemplos/respostas-questoes-slides.sql) ajudam a conferir as respostas no pgAdmin, e o [modelo de registro](../docs/registro-ia-modelo.md) preserva a decisão humana.
