-- Versão 02 | Pedidos e situações de pagamento.
-- Objetivo: conferir pagamentos, cancelamentos e o pagamento de valor zero.
SELECT id, cliente_id, status, valor FROM ws4.pedidos ORDER BY id;
