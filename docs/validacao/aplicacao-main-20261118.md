# Validação da aplicação no banco de demonstração

Data: 18/11/2026. Banco PostgreSQL do laboratório, com dados fictícios.

## Aplicação após merge

- PR: [correção do relatório, nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1).
- Commit aplicado: `3c538bde764a839e5cf150a866e6e1894c0ee3f7`.
- Execução: [Aplicar main no banco de demonstracao, 44360727607](https://github.com/pedropalmieri/workshop4-pr-sql-ia/actions/runs/44360727607), concluída com sucesso.
- Executor: `workshop4-docker`, em Docker na rede do banco existente.

Resultado confirmado diretamente no PostgreSQL após a execução:

| id | nome | pedidos_pagos | total_pago |
|---|---|---|---|
| 1 | Ana | 2 | 150.00 |
| 2 | Bruno | 0 | 0.00 |
| 3 | Carla | 0 | 0.00 |
| 4 | Diego | 1 | 0.00 |

O comentário do objeto identifica o commit e a execução. Clientes e pedidos foram preservados.

## Rejeição e rollback

A validação local do mesmo script confirmou a aplicação da consulta correta e a rejeição da versão com erro. Foram comparados a definição da consulta, o comentário do objeto e o conteúdo das tabelas. Após a falha, a definição e o comentário anteriores permaneceram e os dados das tabelas não mudaram. O estado original do banco foi restaurado ao terminar esse teste.

A [execução inicial 44360240529](https://github.com/pedropalmieri/workshop4-pr-sql-ia/actions/runs/44360240529), anterior ao merge da correção, acessou o banco e falhou por resultado diferente do contrato. O gatilho foi ajustado para executar após merge de PR com alteração SQL, evitando aplicação durante mudanças na configuração. O merge posterior aplicou a correção com sucesso.
