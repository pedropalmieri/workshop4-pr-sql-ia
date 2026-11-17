-- Ponto de partida congelado para repetir a demonstração em qualquer branch.
-- Este arquivo contém um erro de negócio intencional.
CREATE OR REPLACE VIEW ws4.resumo_clientes AS
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome;
