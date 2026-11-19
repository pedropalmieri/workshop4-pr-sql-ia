# Questões dos slides e consultas de apoio

O arquivo [respostas-questoes-slides.sql](../exemplos/respostas-questoes-slides.sql) reúne consultas prontas, comentadas e compatíveis com o Query Tool do pgAdmin. Selecione um bloco por vez e execute. Todas são de leitura, incluindo o EXPLAIN ANALYZE sobre um SELECT.

As expectativas usam a base fictícia original: quatro clientes e cinco pedidos. As consultas que calculam versões do relatório não alteram o banco. As que leem `ws4.resumo_clientes` mostram a implementação efetivamente aplicada, que pode estar no estado inicial ou corrigido.

| Slide/questão | Bloco SQL | Resposta e evidência |
|---|---|---|
| 14 e 16: qual é o cadastro atual? | Q01 e Q02 | Quatro clientes. Pedidos pertencem a Ana, Bruno e Diego. Carla não tem pedidos. |
| 15 e 17: qual resultado atende ao objetivo? | Q03 | Todos os clientes, somente pagos no cálculo. Ana 2/150, Bruno 0/0, Carla 0/0 e Diego 1/0. |
| 18 e 19: por que os clientes desaparecem? | Q04 e Q05 | O WHERE elimina Bruno (cancelado) e Carla (status nulo). |
| 20: como a correção preserva todos? | Q03, Q04 e Q09 | O filtro de status no ON seleciona os pedidos pagos durante a junção. O LEFT JOIN preserva o cliente sem correspondência. |
| 21 e 25: o que muda com COUNT(*)? | Q06 | Bruno e Carla teriam contagem 1. COUNT(p.id) ignora os identificadores nulos e retorna zero. |
| 25: excluir total zero preserva o requisito? | Q07 e Q08 | Não. Excluiria Bruno, Carla e Diego. O pedido 105 comprova que Diego tem um pagamento válido de valor zero. |
| 22: o que muda antes e depois? | Q09 | A inicial retorna Ana e Diego. A corrigida também preserva Bruno e Carla. Os dados das tabelas permanecem. |
| 23 e 25: qual teste garante a presença de Carla? | Q10 e Q11 | A verificação direta exige Carla com zero. O contrato completo também detecta sua ausência. |
| 4, 13 e 22: qual implementação chegou ao banco? | Q12 e Q13 | O resultado aplicado e o comentário do objeto identificam o estado, o commit e a execução. |
| 8: diferença entre EXPLAIN e EXPLAIN ANALYZE | Q14 e Q15 | O primeiro mostra o plano estimado. O segundo executa o SELECT e apresenta medições reais. |
| 11 e 24: qual contexto ajuda a IA? | Q16, SQL atual e contrato | Requisito, dados, resultado observado e esperado. O pedido delimita a ajuda ao diagnóstico da Tutora. |

## Questões conceituais

As perguntas sobre finalidade do PR, qualidade da revisão e decisões com IA não têm uma resposta comprovável apenas por SQL. O PR compara versões e reúne revisão e evidência. A rastreabilidade relaciona requisito, alteração, teste e aplicação. O registro de IA mostra tarefa, justificativa, orientação, validação, falhas e retrabalho.

O [guia da automação](arquitetura-automacao.md) explica o fluxo e os motivos. O [modelo de registro](registro-ia-modelo.md) documenta a decisão humana. As [consultas explicadas](consultas-explicadas.md) aprofundam cada operação do caso.
