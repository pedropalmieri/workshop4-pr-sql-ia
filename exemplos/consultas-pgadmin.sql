-- Consultas para o Query Tool do pgAdmin. SQL PostgreSQL, sem metacomandos psql.
-- Execute cada bloco SELECT individualmente para comparar os resultados.


-- 1. SELECT, FROM e ORDER BY: os quatro clientes
SELECT id, nome FROM ws4.clientes ORDER BY id;

-- 2. WHERE: três pedidos pagos, inclusive o de valor zero
SELECT id, cliente_id, valor
FROM ws4.pedidos
WHERE status = 'pago'
ORDER BY id;

-- 3. INNER JOIN: três linhas, sem Bruno e Carla
SELECT c.nome, p.id AS pedido_id, p.valor
FROM ws4.clientes c
INNER JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;

-- 4. LEFT JOIN: cinco linhas, preservando Bruno e Carla
SELECT c.id, c.nome, p.id AS pedido_id, p.valor
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;

-- 5. GROUP BY, COUNT e SUM: quatro linhas, soma nula sem pagamento
SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos, SUM(p.valor) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;

-- 6. COALESCE: o relatório completo com zeros explícitos
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
