# Do Pull Request ao banco de demonstração

O PR valida a mudança em um banco temporário do GitHub Actions. Após o merge, um segundo workflow aplica o SQL da `main` no PostgreSQL já usado pelo pgAdmin. O banco continua ligado e os dados de clientes e pedidos permanecem.

## Fluxo

1. Crie uma branch e altere `sql/02_consulta.sql`.
2. Faça commit, push e abra o PR. O workflow **Testes SQL** valida a consulta em ambiente temporário.
3. Confira os testes e revise o diff e as decisões registradas. Aprovar o PR não altera o banco.
4. Faça o merge na `main`. O evento de PR mesclado dispara **Aplicar main no banco de demonstracao** quando o SQL mudou.
5. O executor `workshop4-docker`, em Docker no computador do laboratório, aplica e testa o SQL no banco existente.
6. Confira no log do workflow os resultados antes e depois, o commit e os testes. No pgAdmin, execute novamente o SELECT abaixo para atualizar o resultado exibido.

```sql
SELECT * FROM ws4.resumo_clientes ORDER BY id;

SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;
```

O segundo SELECT identifica o commit e a execução que aplicaram a consulta. Os arquivos de apresentação, documentação e exemplos, isoladamente, não disparam a aplicação. Alterações nos testes SQL também acionam o workflow para verificar o contrato.

## Aplicação com validação na mesma transação

O script `scripts/aplicar-no-banco.sh` executa a consulta de `sql/02_consulta.sql` e os testes de `sql/03_testes.sql` na mesma transação. O cenário que cancela os pedidos usa um savepoint e restaura os dados antes de concluir. Se qualquer teste falhar, o PostgreSQL desfaz a aplicação, incluindo a alteração da consulta. A execução do workflow fica com falha e a versão anterior permanece no banco.

A aplicação não carrega `sql/01_base.sql`, não recria o banco e não encerra os serviços. Ela exige o laboratório previamente inicializado. As execuções são serializadas pelo workflow e por uma trava transacional no PostgreSQL.

Aprovação, merge e aplicação são eventos distintos. Fechar um PR sem merge não aplica a consulta. Um push direto na main também não dispara a aplicação. O workflow também aceita acionamento manual em **Actions > Aplicar main no banco de demonstracao > Run workflow**, somente na `main`. O acionamento manual reaplica o SQL atual da `main`.

## Estado inicial do exercício

A consulta inicial da `main` contém o erro intencional do exercício. Enquanto ela não for corrigida, a aplicação automática será rejeitada pelos testes e manterá o banco anterior. O comportamento esperado após o PR da correção é passar nos testes e apresentar os quatro clientes.

Para colocar apenas o banco no estado inicial antes de uma demonstração:

```bash
bash demo.sh inicio
bash demo.sh consultar
```

Esse comando não muda o arquivo versionado nem faz push. O próximo merge com alteração SQL aplica o conteúdo da `main`.

## Disponibilidade

Docker Desktop, PostgreSQL e o executor precisam estar ligados. O executor não expõe porta, não monta o socket Docker e só recebe a configuração do banco didático. Os testes de PR continuam nos executores hospedados pelo GitHub, sem executar código de branches no executor de aplicação.

O banco atual usa armazenamento temporário: a automação o preserva, mas encerrar ou recriar o contêiner do PostgreSQL descarta os dados. O pgAdmin mantém sua configuração. Consulte [instalação e credenciais](../README.md) e [configuração do executor](../infra/runner/README.md).

Referências: [eventos de workflow](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows) e [executores próprios](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/use-in-a-workflow).
