# Discussão: contagem, ausência e valor zero

O relatório inclui todos os clientes e conta somente pedidos pagos. Ana tem dois pagos e um cancelado. Bruno tem apenas um cancelado. Carla não tem pedidos. Diego tem um pedido pago de valor zero.

Considere esta condição de junção:

```sql
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
```

## Questões

1. Qual seria a contagem de Carla se COUNT(p.id) fosse substituído por COUNT(*)?
2. Por que Diego tem total zero, mas um pedido pago?
3. COALESCE sozinho recuperaria um cliente eliminado pelo WHERE?
4. Acrescentar OR p.id IS NULL ao WHERE manteria tanto Carla quanto Bruno?
5. Qual caso de teste permite distinguir ausência de pedido e pedido pago de valor zero?

## Exploração

```bash
bash demo.sh diagnosticar
bash demo.sh contagem
```

Compare as linhas da junção com o resultado agregado. Relacione cada diferença ao [contrato da consulta](contrato.md). A discussão pode ser feita em dupla ou squad, sem envio obrigatório.

As explicações estão em [consultas passo a passo](consultas-passo-a-passo.md) e [SQL comentado](sql-comentado.md).
