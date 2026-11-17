-- Consultas somente de leitura. Não substituem a view do exercício.
\echo '1. Base: quatro clientes e cinco pedidos'
SELECT * FROM ws4.clientes ORDER BY id;
SELECT * FROM ws4.pedidos ORDER BY id;

\echo '2. LEFT JOIN antes do WHERE: seis linhas, incluindo Carla sem pedido'
SELECT c.id AS cliente_id, c.nome, p.id AS pedido_id, p.status, p.valor,
       (p.status = 'pago') IS TRUE AS passa_no_where
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
ORDER BY c.id, p.id;

\echo '3. Status no ON: cinco linhas, preservando Bruno e Carla'
SELECT c.id AS cliente_id, c.nome, p.id AS pedido_id, p.status, p.valor
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id AND p.status = 'pago'
ORDER BY c.id, p.id;
