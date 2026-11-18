# Validação das respostas SQL dos slides

Data: 18/11/2026. PostgreSQL do laboratório no estado inicial.

Os 16 blocos de [respostas-questoes-slides.sql](../../exemplos/respostas-questoes-slides.sql) foram executados com psql e `ON_ERROR_STOP=1`. Além da execução, foram conferidos os resultados abaixo:

| Verificação | Resultado observado |
|---|---|
| Cadastro | Ana, Bruno, Carla e Diego |
| Pedidos | Cinco registros |
| Relatório correto calculado sem aplicar alteração | Quatro clientes |
| Junção inicial, antes do WHERE | Seis linhas |
| Consulta inicial calculada | Ana e Diego |
| COUNT(*) e COUNT(p.id) para Carla | 1 e 0 |
| COUNT(*) e COUNT(p.id) para Diego | 1 e 1, com soma zero |
| Exclusão de total zero | Eliminaria Bruno, Carla e Diego |
| Pagamento de valor zero | Pedido 105, de Diego, pago, 0.00 |
| Comparação das versões | Duas linhas iniciais e quatro corrigidas |
| Verificação de Carla na implementação aplicada | FAIL esperado no estado inicial |
| Comparação da implementação aplicada com o contrato | Duas diferenças, Bruno e Carla |
| Consulta do commit aplicado | Metadado presente |
| EXPLAIN e EXPLAIN ANALYZE | Planos produzidos sem erro |
| Dados das tabelas antes e depois | Assinatura do conteúdo preservada |

As consultas não alteraram o estado do laboratório. Os blocos que leem a implementação aplicada dependem do estado inicial ou corrigido, conforme explicado nos comentários SQL.
