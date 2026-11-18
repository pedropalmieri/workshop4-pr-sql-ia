-- Objetivo: relacionar clientes aos pedidos pagos correspondentes.
-- Esperado: três linhas. Ana aparece duas vezes e Diego uma vez.
SELECT c.id AS cliente_id, c.nome, p.id AS pedido_id, p.valor
FROM ws4.clientes c
INNER JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;
