-- Consulta inicial do relatório de pagamentos por cliente.
-- Execute no Query Tool para analisar o resultado antes da correção.
-- Resultado observado: Ana e Diego. Bruno e Carla não aparecem.
-- Esta consulta apenas lê os dados. Compare com o contrato do relatório.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome;
