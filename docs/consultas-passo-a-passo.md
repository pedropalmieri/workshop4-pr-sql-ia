# Consultas passo a passo

O relatório de pedidos pagos pode ser construído por etapas. Cada consulta acrescenta um conceito e permite conferir o resultado antes de avançar.

Os [exemplos numerados de demonstração](../exemplos/demonstracao/README.md) separam cada etapa em um arquivo SQL, incluindo o problema do filtro e a comparação da view com o contrato.

Na interface gráfica, use os blocos de [consultas-pgadmin.sql](../exemplos/consultas-pgadmin.sql), executando um SELECT por vez no Query Tool do pgAdmin. A instalação e a conexão estão em [pgAdmin](pgadmin.md).

A versão [consultas-passo-a-passo.sql](../exemplos/consultas-passo-a-passo.sql) acrescenta metacomandos exclusivos do psql. Ela funciona com `bash demo.sh passos` ou no terminal SQL. Não cole esses metacomandos no Query Tool.

Antes da exploração, inicie a interface, carregue a base e aplique a consulta inicial conforme o README. A execução das consultas faz parte da atividade.

## 1. Seleção de colunas

```sql
SELECT id, nome FROM ws4.clientes ORDER BY id;
```

FROM identifica a tabela, SELECT escolhe as colunas e ORDER BY organiza a exibição. `ws4` é o schema e `clientes` é a tabela. A seleção de colunas muda a saída, sem alterar a estrutura armazenada.

**Resultado:** quatro clientes, ordenados por id.

## 2. Filtro de pedidos pagos

```sql
SELECT id, cliente_id, valor
FROM ws4.pedidos
WHERE status = 'pago'
ORDER BY id;
```

WHERE restringe as linhas ao status indicado. O pedido de valor zero continua incluído, pois o critério é o status do pagamento.

**Resultado:** pedidos 101, 102 e 105. O cancelado de 900 fica fora, apesar de seu valor ser maior.

## 3. Correspondências com INNER JOIN

```sql
SELECT c.nome, p.id AS pedido_id, p.valor
FROM ws4.clientes c
INNER JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;
```

`c` e `p` são aliases das tabelas. ON relaciona a chave do cliente à referência armazenada no pedido. INNER JOIN mantém as correspondências que atendem à condição.

**Resultado:** três linhas, duas de Ana e uma de Diego. A junção ainda não agrega os pedidos por cliente.

## 4. Preservação de clientes com LEFT JOIN

Trocar INNER JOIN por LEFT JOIN preserva os clientes à esquerda mesmo quando nenhum pedido atende à condição ON.

**Resultado:** cinco linhas. Ana aparece duas vezes. Bruno, Carla e Diego aparecem uma vez cada. As colunas de pedido de Bruno e Carla ficam nulas.

No psql, `\pset null '(NULL)'` destaca essas ausências. No pgAdmin, observe os valores nulos da grade de resultados. NULL indica ausência de valor. O zero de Diego é um valor informado em um pedido existente.

## 5. Agrupamento e agregações

```sql
SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos, SUM(p.valor) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
```

GROUP BY reúne as linhas do mesmo cliente. COUNT(p.id) conta chaves não nulas. SUM(p.valor) soma os valores correspondentes e retorna NULL quando não há valores de entrada não nulos.

| Cliente | Pedidos pagos | Soma |
|---|---|---|
| Ana | 2 | 150 |
| Bruno | 0 | NULL |
| Carla | 0 | NULL |
| Diego | 1 | 0 |

## 6. Tratamento de ausência com COALESCE

```sql
COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
```

O contrato pede total zero para quem não tem pagamento. COALESCE usa a soma quando ela existe e retorna zero quando a soma é nula. O tipo numeric(12,2) define duas casas decimais no resultado.

Essa é uma escolha de representação deste relatório. Não significa que ausência e zero sejam equivalentes em toda análise.

## Análise da consulta inicial

Em [exemplos/consulta-com-erro.sql](../exemplos/consulta-com-erro.sql), o filtro de status está no WHERE após o LEFT JOIN. A versão corrigida está em [sql/02_consulta.sql](../sql/02_consulta.sql). Isso elimina clientes que deveriam permanecer no resultado. Compare com os blocos acima e com o [contrato](contrato.md).

```bash
bash demo.sh inicio
bash demo.sh consultar
bash demo.sh testar
bash demo.sh diagnosticar
```

A análise detalhada dessa diferença está em [SQL comentado](sql-comentado.md). A validação compara o resultado com valores calculados independentemente da implementação.

Fontes: [JOIN](https://www.postgresql.org/docs/current/tutorial-join.html) e [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html), documentação oficial do PostgreSQL.
