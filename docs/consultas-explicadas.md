# Consultas SQL do Workshop 4

Este documento explica as consultas do caso de clientes e pedidos, seus resultados e sua relação com os testes e o Pull Request. O caso aplica o escopo do workshop; ele não substitui o enunciado do Desafio Final.

## 1. Contexto, objetivo e dados

`ws4.clientes` contém o cadastro. `ws4.pedidos` contém os pedidos e referencia o cadastro por `cliente_id`. Um cliente pode ter vários pedidos ou nenhum. O objetivo do relatório é apresentar todos os clientes, contando e somando apenas pedidos pagos.

```sql
SELECT id, nome FROM ws4.clientes ORDER BY id;
SELECT id, cliente_id, status, valor FROM ws4.pedidos ORDER BY id;
```

Execute os dois SELECTs separadamente no Query Tool. O primeiro mostra quatro clientes. O segundo mostra cinco pedidos. `SELECT` escolhe as colunas, `FROM` indica a tabela e `ORDER BY` organiza a exibição. Esses comandos apenas leem os dados.

Ana tem dois pagamentos, de 100 e 50, e um cancelamento de 900. Bruno tem somente um cancelamento de 80. Carla não tem pedidos. Diego tem um pagamento de zero. Essas situações permitem distinguir ausência, cancelamento e pagamento válido de valor zero.

O resultado esperado, calculado diretamente dessas regras, é:

| Cliente | Pedidos pagos | Total pago |
|---|---|---|
| Ana | 2 | 150.00 |
| Bruno | 0 | 0.00 |
| Carla | 0 | 0.00 |
| Diego | 1 | 0.00 |

A chave do resultado é o id do cliente. O [contrato](contrato.md) define a expectativa usada pelos testes.

## 2. Filtro: quais pedidos estão pagos?

```sql
SELECT id, cliente_id, valor
FROM ws4.pedidos
WHERE status = 'pago'
ORDER BY id;
```

`WHERE` mantém apenas as linhas que atendem à condição. O resultado contém os pedidos 101, 102 e 105. O pedido de Diego entra porque seu status é pago, mesmo com valor zero. Os dois cancelamentos ficam fora. Esse filtro atende à seleção de pedidos, mas sozinho ainda não constrói um relatório que preserve todos os clientes.

## 3. Relação entre cliente e pedido

```sql
SELECT c.id, c.nome, p.id AS pedido_id, p.status, p.valor
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
ORDER BY c.id, p.id;
```

`c` e `p` são aliases, nomes curtos das tabelas. `ON` relaciona o pedido ao cliente. O `LEFT JOIN` preserva os clientes da tabela à esquerda, mesmo sem correspondência na direita.

A saída contém seis linhas: três de Ana, uma de Bruno, uma de Carla e uma de Diego. Carla aparece com as colunas de pedido nulas. `NULL` representa ausência de valor e não é igual a zero.

## 4. Consulta inicial e motivo da falha

```sql
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome;
```

O JOIN primeiro preserva os clientes. Depois, o WHERE retém apenas as linhas com pedido pago. A linha de Bruno tem status cancelado e sai. A linha de Carla tem status nulo: a comparação com pago não é verdadeira, e ela também sai. O relatório retorna apenas Ana e Diego.

O banco executa o SQL sem erro de sintaxe. A falha aparece ao comparar o resultado com a regra de incluir todos os clientes. A versão original está em [consulta-com-erro.sql](../exemplos/consulta-com-erro.sql).

## 5. Consulta corrigida e motivo da alteração

```sql
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome;
```

O filtro de status passa a fazer parte da condição de correspondência. Só pedidos pagos entram na junção, enquanto o LEFT JOIN mantém o cliente quando não há pedido pago correspondente. Assim, Bruno e Carla permanecem. O `GROUP BY` reúne as linhas de cada cliente, e as funções de agregação calculam os valores do relatório.

A mudança altera o resultado calculado, preservando os registros das tabelas. A [solução de referência](../solucao/02_consulta.sql) permite comparar o diff com a versão inicial. O arquivo que segue no PR é `sql/02_consulta.sql`. A definição técnica do relatório é aplicada ao objeto `ws4.resumo_clientes`; isso permite que os testes verifiquem a implementação que está efetivamente no banco.

## 6. COUNT, SUM e COALESCE

```sql
SELECT c.id, c.nome,
       COUNT(*) AS linhas_apos_join,
       COUNT(p.id) AS pedidos_pagos,
       SUM(p.valor) AS soma_sem_tratamento,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
```

- `COUNT(*)` conta linhas. Para Carla, conta a linha preservada pelo LEFT JOIN e retorna 1, embora ela não tenha pedidos.
- `COUNT(p.id)` ignora ids nulos. Retorna zero para Carla e Bruno, 2 para Ana e 1 para Diego.
- `SUM(p.valor)` soma os valores dos pedidos pagos. Sem valores de entrada não nulos, retorna NULL.
- `COALESCE` usa a soma quando existe e retorna zero quando a soma é nula. O cast mantém o total como numeric(12,2).

O zero de Diego veio de um pedido existente. O zero de Bruno e Carla representa a ausência de pagamentos no relatório. Os totais são iguais, mas as contagens preservam a diferença.

## 7. Verificação da implementação aplicada

```sql
SELECT id, nome, pedidos_pagos, total_pago
FROM ws4.resumo_clientes
ORDER BY id;
```

Esse SELECT consulta a implementação aplicada ao banco. Executar um SELECT corrigido isoladamente no Query Tool não altera automaticamente o arquivo no Git, nem substitui a definição aplicada. A rastreabilidade exige relacionar o arquivo, o commit e a execução.

No estado inicial, aparecem Ana e Diego. No estado corrigido, aparecem os quatro clientes. Após uma aplicação automática, execute o SELECT novamente para atualizar a grade de resultados.

## 8. Comparação com o contrato, sem alterar dados

```sql
WITH esperado(id, nome, pedidos_pagos, total_pago) AS (
  VALUES (1, 'Ana', 2::bigint, 150.00::numeric),
         (2, 'Bruno', 0::bigint, 0.00::numeric),
         (3, 'Carla', 0::bigint, 0.00::numeric),
         (4, 'Diego', 1::bigint, 0.00::numeric)
)
(SELECT * FROM esperado EXCEPT ALL SELECT * FROM ws4.resumo_clientes)
UNION ALL
(SELECT * FROM ws4.resumo_clientes EXCEPT ALL SELECT * FROM esperado);
```

A expectativa vem do cálculo manual. `EXCEPT ALL` procura diferenças preservando sua multiplicidade. A comparação nas duas direções detecta linhas ausentes, extras, duplicadas e valores diferentes. `UNION ALL` reúne as diferenças para inspeção.

Nenhuma linha na saída significa que o resultado corresponde a esse contrato. Na versão inicial, aparecem as linhas esperadas de Bruno e Carla, ausentes na implementação. O teste automatizado de [sql/03_testes.sql](../sql/03_testes.sql) transforma uma diferença em falha do comando.

## 9. Plano de execução

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, nome, pedidos_pagos, total_pago
FROM ws4.resumo_clientes;
```

`EXPLAIN` descreve as operações escolhidas pelo PostgreSQL. `ANALYZE` executa a consulta e apresenta linhas e tempos reais. `BUFFERS` acrescenta informações sobre blocos de dados acessados. A medição tem custo de instrumentação.

A base pequena do exercício serve para compreender as operações, sem comprovar ganhos em escala. O plano pode variar entre versões, estatísticas e volumes de dados. Uma sugestão de performance da IA precisa considerar essas informações e manter o resultado funcional.

## 10. Rastreabilidade após o merge

```sql
SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;
```

A automação grava nesse comentário o estado declarado, o commit e a execução que aplicaram a consulta. Relacione essa informação ao log do workflow e ao PR. O comentário anterior permanece se uma aplicação falhar e sofrer rollback.

O [fluxo de aplicação](aplicacao-main.md) distingue validação do PR, merge e execução no banco existente. O [registro da aplicação](validacao/aplicacao-main-20261118.md) preserva a primeira correção. O [registro do retorno](validacao/retorno-inicial-20261118.md) descreve os testes do retorno inicial.

## 11. UPDATE e DELETE no escopo

O briefing não exige exercícios específicos de UPDATE ou DELETE. O UPDATE existente em `sql/03_testes.sql` prepara temporariamente um cenário sem pedidos pagos e é desfeito por ROLLBACK. A aplicação automática usa um savepoint equivalente para restaurar esse cenário sem desfazer uma aplicação correta.

Não há exercício de exclusão de dados. A criação e a carga da base fictícia são preparação do ambiente. O foco dos PRs é a consulta, sua validação e o registro das decisões com IA.

## 12. Contexto para a IA Tutora

A orientação deve receber o objetivo, as tabelas e suas relações, o SQL atual, o resultado observado e a expectativa. O pedido delimita uma explicação ou investigação e deixa a execução com o Fellow. Enviar apenas “melhore esta query” não explica as regras que precisam permanecer.

O [guia de perguntas](prompts-tutora.md) e o [registro de delegação](registro-ia-modelo.md) complementam a análise. Não forneça credenciais. Os dados deste caso são fictícios. A aceitação ou rejeição da resposta deve se apoiar em evidência da tarefa.

## Referências

[Expressões de tabela no PostgreSQL 17](https://www.postgresql.org/docs/17/queries-table-expressions.html), [agregações](https://www.postgresql.org/docs/17/functions-aggregate.html), [EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html) e [contrato do caso](contrato.md).
