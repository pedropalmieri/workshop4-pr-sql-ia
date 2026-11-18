-- Objetivo: conhecer as tabelas antes de construir o relatório.
-- Esperado: quatro clientes e cinco pedidos. Execute cada SELECT separadamente.
SELECT id, nome
FROM ws4.clientes
ORDER BY id;

SELECT id, cliente_id, status, valor
FROM ws4.pedidos
ORDER BY id;
