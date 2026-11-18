# Executor do banco de demonstração

O executor GitHub Actions usa a imagem oficial, com o cliente PostgreSQL adicionado no Dockerfile. Executa em um contêiner ligado à rede `ws4-workshop_default`, sem porta publicada e sem acesso ao socket Docker. O PostgreSQL e o pgAdmin continuam nos contêineres existentes.

A etiqueta `ws4-banco-demo` identifica o executor exclusivo deste repositório. O workflow de aplicação atende apenas à `main`, após o merge de um PR destinado à `main` com alteração em `sql/` ou acionamento manual. Pull Requests continuam usando os executores temporários do GitHub para validação.

## Pré-requisitos

A preparação e o cadastro são feitos pela pessoa que administra o banco de demonstração. A exploração das consultas usa o [ambiente descrito no README principal](../../README.md).

- Docker Desktop em execução.
- PostgreSQL inicializado, com a base e o relatório carregados.
- Rede Docker `ws4-workshop_default` disponível.
- Permissão de administração do repositório para cadastrar o executor.
- A configuração atual usa Linux ARM64 no contêiner, compatível com a arquitetura do computador do laboratório. O workflow seleciona as etiquetas `self-hosted`, `Linux`, `ARM64` e `ws4-banco-demo`.

## Preparação

Execute na raiz do clone, em Bash:

```bash
docker build -t ws4-actions-runner:local infra/runner
docker run -d --name ws4-actions-runner --restart unless-stopped \
  --network ws4-workshop_default \
  -e PGHOST=db -e PGPORT=5432 -e PGDATABASE=workshop \
  -e PGUSER=workshop -e PGPASSWORD=workshop_local \
  ws4-actions-runner:local \
  bash -c 'while ! test -f .runner; do sleep 2; done; exec ./run.sh'
```

Em **Settings > Actions > Runners > New self-hosted runner**, selecione Linux ARM64 e obtenha o token temporário de cadastro. Cadastre dentro do contêiner, sem salvar o token no Git:

```bash
printf 'Token temporário do runner: '
IFS= read -r -s RUNNER_TOKEN
printf '\n'
printf '%s\n' "$RUNNER_TOKEN" | docker exec -i ws4-actions-runner bash -c \
  'read -r token; ./config.sh --unattended --url https://github.com/pedropalmieri/workshop4-pr-sql-ia --token "$token" --name workshop4-docker --labels ws4-banco-demo --work _work'
unset RUNNER_TOKEN
```

O cadastro fica no contêiner. Reiniciar o mesmo contêiner mantém o cadastro. Se ele for removido, cadastre o novo executor novamente e remova o registro antigo em Settings. O token temporário só é necessário para cadastrar.

## Conferência e controle

Para consultar o estado e o log:

```bash
docker ps -a --filter name=ws4-actions-runner
docker logs --tail 30 ws4-actions-runner
```

Para iniciar o executor existente:

```bash
docker start ws4-actions-runner
```

Para suspender a aplicação automática:

```bash
docker stop ws4-actions-runner
```

Docker Desktop e o computador precisam estar ligados. Quando o executor está offline, a execução no GitHub aguarda um executor disponível. As variáveis de banco são do laboratório local, com dados fictícios.

Os dados do PostgreSQL ficam no serviço `db`, não no executor. Reiniciar apenas o executor não recarrega a base. O [fluxo de aplicação](../../docs/aplicacao-main.md) e a [arquitetura da automação](../../docs/arquitetura-automacao.md) explicam os testes, o retorno inicial e o rollback.
