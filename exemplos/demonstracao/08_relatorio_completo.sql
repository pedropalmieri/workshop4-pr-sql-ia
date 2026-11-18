-- Objetivo: representar ausência de pagamentos com zero, conforme o contrato.
-- Esperado: Ana 2/150, Bruno 0/0, Carla 0/0 e Diego 1/0.
-- Este SELECT não substitui a definição da view nem altera o arquivo da implementação.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
