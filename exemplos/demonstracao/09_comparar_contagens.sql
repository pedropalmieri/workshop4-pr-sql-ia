-- Objetivo: distinguir a linha preservada pela junção de um pedido existente.
-- Esperado: Bruno e Carla têm COUNT(*) = 1 e COUNT(p.id) = 0.
-- Diego tem um pedido pago de valor zero: ambas as contagens são 1.
SELECT c.id, c.nome,
       COUNT(*) AS linhas_da_juncao,
       COUNT(p.id) AS pedidos_pagos,
       SUM(p.valor) AS soma_sem_coalesce,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
