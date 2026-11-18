-- Objetivo: comparar a view aplicada no banco com o contrato independente.
-- Esperado na versão inicial: FAIL e 2 diferenças (Bruno e Carla ausentes).
-- Esperado após corrigir e reaplicar a implementação: PASS e 0 diferenças.
-- A palavra FAIL é um resultado de negócio, não um erro de execução deste SELECT.
-- Os testes automatizados com código de saída estão em sql/03_testes.sql.
WITH esperado(id, nome, pedidos_pagos, total_pago) AS (
    VALUES (1, 'Ana', 2::bigint, 150.00::numeric),
           (2, 'Bruno', 0::bigint, 0.00::numeric),
           (3, 'Carla', 0::bigint, 0.00::numeric),
           (4, 'Diego', 1::bigint, 0.00::numeric)
), diferencas AS (
    (SELECT * FROM esperado EXCEPT ALL SELECT * FROM ws4.resumo_clientes)
    UNION ALL
    (SELECT * FROM ws4.resumo_clientes EXCEPT ALL SELECT * FROM esperado)
)
SELECT CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS resultado,
       COUNT(*) AS diferencas_do_contrato
FROM diferencas;
