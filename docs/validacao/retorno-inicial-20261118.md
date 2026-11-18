# Validação do retorno ao estado inicial

Data: 18/11/2026. Execução em banco separado: `ws4-aplicacao-validacao`. O banco da demonstração não foi alterado por essa validação.

Comando: `bash scripts/validar-aplicacao.sh`.

| Verificação | Resultado |
|---|---|
| Aplicar a versão inicial original no modo `inicial` | Dois clientes, Ana e Diego |
| Executar o contrato sobre a versão inicial | Falha esperada, código 3 |
| Aplicar a solução no modo `corrigido` | Quatro clientes e os dois testes do contrato aprovados |
| Aplicar SQL incorreto no modo `corrigido` | Rejeitado, com rollback da definição e do metadado |
| Declarar `inicial` com arquivo diferente do original | Bloqueado antes da aplicação, código 2 |
| Comparar os dados de clientes e pedidos antes e depois | Conteúdo preservado |

Conclusão: `VALIDAÇÃO OK: retorno inicial, correção, rollback, bloqueio de SQL não autorizado e preservação dos dados.`

A aprovação da reprodução do estado inicial não equivale à aprovação do contrato de negócio. O teste funcional `sql/03_testes.sql` mantém sua expectativa original de quatro clientes. Os registros da correção e da aplicação anterior permanecem em [aplicacao-main-20261118.md](aplicacao-main-20261118.md).

## Ciclo completo no GitHub e no banco

O [PR nº 2](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/2) foi mesclado após os dois jobs, SQL e interface, passarem na [execução final de testes 44363632341](https://github.com/pedropalmieri/workshop4-pr-sql-ia/actions/runs/44363632341).

O merge `30a29111c8bba54b2a24b729de63b52b045d7cea` disparou a [aplicação 44364036045](https://github.com/pedropalmieri/workshop4-pr-sql-ia/actions/runs/44364036045), concluída com sucesso no executor do banco.

Consulta confirmada diretamente no PostgreSQL após a aplicação:

| id | nome | pedidos_pagos | total_pago |
|---|---|---|---|
| 1 | Ana | 2 | 150.00 |
| 4 | Diego | 1 | 0.00 |

A base continuou com quatro clientes e cinco pedidos. O comentário do objeto registrou: `Workshop 4: estado inicial; commit 30a29111c8bba54b2a24b729de63b52b045d7cea; execução 44364036045`.

Assim, o retorno inicial foi aplicado pelo mesmo fluxo de PR e merge. A correção anterior permanece no histórico do PR nº 1 e na evidência de aplicação, sem exclusão de registros.
