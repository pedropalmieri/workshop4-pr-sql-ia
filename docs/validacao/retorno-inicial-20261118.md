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
