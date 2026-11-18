# SQL comentado: os clientes que desapareceram

Análise da regra de negócio, da junção e das agregações do relatório. Dados e regras são fictícios.

## Regra de negócio antes do código

Cada cliente deve aparecer uma vez. Somente pedidos `pago` entram no total e na contagem. Clientes sem pagamento aparecem com zeros. Um pedido pago de valor zero continua sendo válido.

| Cliente | Pedidos na base | Resultado esperado |
|---|---|---|
| Ana | Pagos de 100 e 50, cancelado de 900 | 2 pedidos, total 150 |
| Bruno | Cancelado de 80 | 0 pedidos, total 0 |
| Carla | Nenhum | 0 pedidos, total 0 |
| Diego | Pago de 0 | 1 pedido, total 0 |

`clientes.id` identifica o cliente. `pedidos.cliente_id` referencia essa chave. Um cliente pode ter vários pedidos. O relatório agrega as linhas por cliente.

## Por que a versão inicial parece funcionar

```sql
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
```

O LEFT JOIN preserva os clientes sem correspondência. Porém, o WHERE atua sobre o resultado dessa junção. Só permanecem linhas em que a condição é verdadeira.

- Ana tem linhas pagas e permanece.
- Bruno tem correspondência, mas somente cancelada. Sua linha sai.
- Carla ganha uma linha com colunas de pedido nulas. `NULL = 'pago'` não resulta em verdadeiro, então essa linha também sai.
- Diego tem um pedido pago, mesmo com valor zero, e permanece.

Execute `bash demo.sh diagnosticar`. O primeiro JOIN gera seis linhas: três de Ana e uma de cada outro cliente. A coluna `passa_no_where` mostra quais sobreviveriam. Com filtro no ON, existem cinco linhas antes da agregação: duas de Ana e uma para cada outro cliente.

Essa explicação usa a ordem lógica das operações. O otimizador pode escolher outra estratégia física preservando a semântica da consulta.

## Correção de referência

```sql
CREATE OR REPLACE VIEW ws4.resumo_clientes AS
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome;
```

O ON procura apenas pedidos pagos de cada cliente. Sem pedido que atenda à condição, o LEFT JOIN ainda preserva o cliente.

COUNT(p.id) conta as chaves não nulas. SUM(p.valor) soma os pedidos correspondentes. Sem correspondências, a soma é nula. COALESCE converte essa ausência em zero. `numeric(12,2)` mantém duas casas decimais no total.

O GROUP BY entrega uma linha por cliente. O nome sozinho não é uma chave confiável: pessoas diferentes podem ter o mesmo nome. A ordenação fica no SELECT de exibição.

## Alterações que merecem revisão

### COUNT(*) no lugar de COUNT(p.id)

Execute `bash demo.sh contagem`.

| Cliente | COUNT(*) | COUNT(p.id) | SUM sem COALESCE | Total final |
|---|---|---|---|---|
| Ana | 2 | 2 | 150 | 150 |
| Bruno | 1 | 0 | NULL | 0 |
| Carla | 1 | 0 | NULL | 0 |
| Diego | 1 | 1 | 0 | 0 |

COUNT(*) inclui a linha que preserva o cliente sem pedido correspondente. Isso produziria contagem 1 para Bruno e Carla. O valor zero de Diego não interfere na contagem da chave do pedido.

### Apenas adicionar COALESCE

COALESCE substitui uma soma nula, mas não recria uma linha que o WHERE eliminou. Portanto, não recupera Bruno e Carla na consulta inicial.

### Acrescentar OR p.id IS NULL ao WHERE

Na junção inicial, `WHERE p.status = 'pago' OR p.id IS NULL` recuperaria Carla, mas ainda excluiria Bruno. Bruno tem pedido com id preenchido, porém cancelado. Testar apenas o cliente sem pedidos seria insuficiente.

## O que o teste comprova

`sql/03_testes.sql` compara com valores calculados manualmente, usando EXCEPT ALL nas duas direções. Detecta linhas ausentes, extras, duplicadas e diferenças de valores. Não depende de escrever uma segunda consulta equivalente à implementação.

O segundo cenário transforma todos os pedidos em cancelados e exige quatro clientes com zeros. O ROLLBACK preserva os dados originais. Uma falha interrompe o script com ON_ERROR_STOP e código de saída diferente de zero.

Esses testes validam os cenários do contrato didático. Não provam desempenho em produção nem cobrem todos os requisitos possíveis de um sistema real.

Fontes: [JOIN](https://www.postgresql.org/docs/current/tutorial-join.html) e [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html), documentação oficial do PostgreSQL.
