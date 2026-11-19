# Como a automação foi organizada

## Objetivo

Relacionar uma alteração SQL versionada ao resultado aplicado no PostgreSQL do laboratório. O fluxo permite conferir o código no PR, validar a alteração e observar no pgAdmin o resultado após o merge. O banco não é recriado a cada aplicação.

## Componentes e motivos

| Componente | Implementação | Motivo |
|---|---|---|
| Banco e interface | `compose.yaml`: PostgreSQL e pgAdmin | Ambiente compartilhável por Docker, sem instalação local desses aplicativos |
| Validação do PR | `.github/workflows/testes.yml` | Testar a proposta em banco temporário do GitHub, separado do laboratório |
| Aplicação após merge | `.github/workflows/aplicar-main.yml` | Aplicar o commit mesclado, apenas após PR SQL efetivamente incorporado à main |
| Executor do banco | `infra/runner/Dockerfile` e contêiner `ws4-actions-runner` | Conectar ao banco local pela rede Docker, sem expor o PostgreSQL à internet |
| Aplicação transacional | `scripts/versoes_sql.py`; `scripts/aplicar-no-banco.sh` no exercício anterior | Confirmar o lote de cada mecanismo e sua validação juntos, ou desfazer a tentativa |
| Estado do exercício | `sql/estado-demonstracao.txt` | Distinguir explicitamente a reprodução da falha e a solução correta |
| Diagnóstico do estado inicial | `sql/04_testes_estado_inicial.sql` | Conferir o defeito conhecido sem flexibilizar o contrato de negócio |
| Teste do contrato | `sql/03_testes.sql` | Verificar os quatro clientes e o cenário sem pagamentos |
| Validação isolada | `scripts/validar-aplicacao.sh` | Testar retorno, correção e rollback sem alterar o banco da apresentação |

## Fluxo de execução

1. A develop contém as versões novas e seus testes. O commit preserva a mudança.
2. O PR executa **Testes SQL**. No estado corrigido, exige o contrato. No inicial, confere a versão original e confirma que o contrato continua falhando.
3. Após o merge de um PR da develop para a main com alteração em `sql/` ou `consultas/`, o workflow de aplicação seleciona o commit do merge. Fechamento sem merge ou push direto não aciona a aplicação.
4. O executor em Docker usa o cliente PostgreSQL para acessar `db` pela rede do laboratório. Os jobs de PR não usam esse executor.
5. O catálogo abre uma transação, serializa a aplicação por uma trava, executa apenas as versões pendentes, testa seus contratos e revalida as consultas vigentes. Registra arquivo, hash, commit e execução. O exercício em `sql/` usa outro mecanismo transacional, que também registra antes/depois e testa o estado declarado.
6. Uma falha aborta o lote do mecanismo em execução. No sucesso, suas mudanças e metadados são confirmados. O catálogo e o exercício anterior têm transações separadas.
7. O pgAdmin consulta o mesmo banco. Uma nova execução do SELECT mostra a versão aplicada.

## Decisões de implementação

- O executor usa a imagem oficial do GitHub Actions, fixada por digest, com o cliente PostgreSQL acrescentado. O preparo e o cadastro estão em [infra/runner/README.md](../infra/runner/README.md).
- O executor não publica portas e não monta o socket Docker. O computador e o Docker Desktop precisam permanecer ligados para atender aos jobs.
- A aplicação usa o banco existente, sem rodar a carga da base e sem encerrar serviços. O armazenamento atual do PostgreSQL é temporário: recriar seu contêiner descarta os dados.
- `contents: read` permite baixar o código. O checkout não persiste a credencial do GitHub no clone usado pelo job.
- Execuções de aplicação são serializadas e têm tempo limite. A trava transacional também impede duas aplicações simultâneas pelo mesmo procedimento.
- O teste de ausência de pagamentos usa savepoint na transação de aplicação. O cenário temporário é restaurado antes da confirmação.
- O modo inicial exige que o SQL seja igual à versão original em exemplos. O log informa expressamente que esse resultado não atende ao contrato.
- O histórico de PRs e de execuções não é apagado ao retornar ao início. A correção anterior e o retorno têm commits e evidências distintos.

## Consultas e comprovação

As [consultas explicadas](consultas-explicadas.md) mostram o cenário, a lógica de cada SQL e o resultado esperado. O [guia de aplicação](aplicacao-main.md) apresenta os comandos para conferir o resultado e o commit no banco. As evidências ficam em [validacao](validacao/).

Uma aprovação do PR não executa SQL. O evento de merge dispara a aplicação configurada para este repositório. Essa automação é uma adaptação do laboratório solicitada para demonstrar a ligação entre a revisão e o banco; não cria uma entrega adicional no workshop.

## Catálogo e proteção da main

As novas releases usam `consultas/` e testes JSON correspondentes. `scripts/versoes_sql.py` usa pglast 7.23 para analisar SQL do PostgreSQL 17 e psycopg 3.2.13 para executar e validar no banco. As dependências ficam em imagens Docker, não no computador. Versão, arquivo, hash, commit, execução e resultado ficam em `ws4_controle.versoes`. O catálogo é transacional e preserva as versões anteriores.

O push na develop e o PR para main executam origem, sql, interface e versoes. A main pública tem proteção nativa, inclusive para administradores, exige PR e checks aprovados e bloqueia force push e exclusão. O merge é confirmado manualmente. A configuração da demonstração não exige aprovação de uma segunda conta.

Os modelos DDL são complementares, solicitados para demonstrar deploy de estrutura. Só são publicados ao serem copiados, numerados e testados no catálogo ativo. O fluxo completo e os comandos estão em [develop e main](fluxo-develop-main.md).
