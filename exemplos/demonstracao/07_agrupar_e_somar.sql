-- Objetivo: obter uma linha por cliente com a condição correta no ON.
-- Esperado: Ana 2/150, Bruno 0/NULL, Carla 0/NULL e Diego 1/0.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       SUM(p.valor) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
