-- Versão 03 | Relatório de pedidos pagos por cliente.
-- Objetivo: incluir todos os clientes, contando e somando somente pedidos pagos.
-- Esta consulta é uma nova versão; os scripts 01 e 02 permanecem preservados.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
