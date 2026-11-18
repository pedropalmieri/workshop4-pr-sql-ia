-- Objetivo: selecionar somente pedidos pagos.
-- Esperado: pedidos 101, 102 e 105. O pedido 105 tem valor zero e permanece.
SELECT id, cliente_id, status, valor
FROM ws4.pedidos
WHERE status = 'pago'
ORDER BY id;
