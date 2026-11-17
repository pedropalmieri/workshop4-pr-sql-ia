\set ON_ERROR_STOP on
-- Contrato independente da implementação. Diferença em qualquer direção falha.
DO $$
BEGIN
  IF EXISTS (
    WITH esperado(id, nome, pedidos_pagos, total_pago) AS (
      VALUES (1, 'Ana', 2::bigint, 150.00::numeric),
             (2, 'Bruno', 0::bigint, 0.00::numeric),
             (3, 'Carla', 0::bigint, 0.00::numeric),
             (4, 'Diego', 1::bigint, 0.00::numeric)
    ), diferencas AS (
      (SELECT * FROM esperado EXCEPT ALL SELECT * FROM ws4.resumo_clientes)
      UNION ALL
      (SELECT * FROM ws4.resumo_clientes EXCEPT ALL SELECT * FROM esperado)
    ) SELECT 1 FROM diferencas
  ) THEN
    RAISE EXCEPTION 'FAIL: resultado diferente do contrato. Compare com docs/contrato.md';
  END IF;
  RAISE NOTICE 'PASS: os quatro clientes, contagens e totais correspondem ao contrato';
END $$;

-- Outro cenário: nenhum pedido pago. A transação mantém a base original.
BEGIN;
UPDATE ws4.pedidos SET status = 'cancelado';
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM ws4.resumo_clientes) <> 4
     OR EXISTS (SELECT 1 FROM ws4.resumo_clientes
                WHERE pedidos_pagos IS DISTINCT FROM 0
                   OR total_pago IS DISTINCT FROM 0) THEN
    RAISE EXCEPTION 'FAIL: todos devem aparecer com zero quando não há pedidos pagos';
  END IF;
  RAISE NOTICE 'PASS: cenário sem pedidos pagos';
END $$;
ROLLBACK;
