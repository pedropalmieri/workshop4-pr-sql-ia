\set ON_ERROR_STOP on
-- Confirma somente a reprodução do defeito conhecido, sem aprovar o contrato.
DO $$
BEGIN
  IF EXISTS (
    WITH esperado(id,nome,pedidos_pagos,total_pago) AS (
      VALUES (1,'Ana',2::bigint,150.00::numeric),
             (4,'Diego',1::bigint,0.00::numeric)
    ), diferencas AS (
      (SELECT * FROM esperado EXCEPT ALL SELECT * FROM ws4.resumo_clientes)
      UNION ALL
      (SELECT * FROM ws4.resumo_clientes EXCEPT ALL SELECT * FROM esperado)
    ) SELECT 1 FROM diferencas
  ) THEN
    RAISE EXCEPTION 'FAIL: resultado não corresponde ao estado inicial conhecido';
  END IF;
  IF (SELECT COUNT(*) FROM ws4.clientes) <> 4 OR
     (SELECT COUNT(*) FROM ws4.pedidos) <> 5 THEN
    RAISE EXCEPTION 'FAIL: a base do exercício não foi preservada';
  END IF;
  RAISE NOTICE 'ESTADO INICIAL REPRODUZIDO: Ana e Diego presentes; Bruno e Carla ausentes';
  RAISE NOTICE 'ATENÇÃO: este estado NÃO atende ao contrato de negócio. sql/03_testes.sql deve falhar';
END $$;
