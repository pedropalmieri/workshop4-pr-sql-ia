-- Objetivo: preservar todos os clientes, inclusive sem pedido pago.
-- Esperado: cinco linhas antes de agrupar. Bruno e Carla têm pedido_id nulo.
SELECT c.id AS cliente_id, c.nome, p.id AS pedido_id, p.valor
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;
