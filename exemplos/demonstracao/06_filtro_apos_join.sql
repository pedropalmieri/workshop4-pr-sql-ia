-- Objetivo: observar o problema do filtro no WHERE após o LEFT JOIN.
-- Esperado: somente Ana e Diego. A ausência de Bruno e Carla viola o contrato.
-- Consulta intencionalmente incorreta para a regra do relatório.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
