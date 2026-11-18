# Executor do banco de demonstração

O executor GitHub Actions usa a imagem oficial, com o cliente PostgreSQL adicionado no Dockerfile. Executa em um contêiner ligado à rede `ws4-workshop_default`, sem porta publicada e sem acesso ao socket Docker. O PostgreSQL e o pgAdmin continuam nos contêineres existentes.

A etiqueta `ws4-banco-demo` identifica o executor exclusivo deste repositório. O workflow de aplicação atende apenas à `main`, após o merge de um PR com alteração SQL ou acionamento manual. Pull Requests continuam usando os executores temporários do GitHub para validação.

## Preparação

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
read -s -p 'Token temporário do runner: ' RUNNER_TOKEN; echo
printf '%s\n' "$RUNNER_TOKEN" | docker exec -i ws4-actions-runner bash -c \
  'read -r token; ./config.sh --unattended --url https://github.com/pedropalmieri/workshop4-pr-sql-ia --token "$token" --name workshop4-docker --labels ws4-banco-demo --work _work'
unset RUNNER_TOKEN
```

O cadastro fica no contêiner. Reiniciar o mesmo contêiner mantém o cadastro. Se ele for removido, cadastre o novo executor novamente e remova o registro antigo em Settings. O token temporário só é necessário para cadastrar.

## Conferência

```bash
docker logs --tail 30 ws4-actions-runner
docker start ws4-actions-runner
# Para suspender apenas a aplicação automática:
docker stop ws4-actions-runner
```

Docker Desktop e o computador precisam estar ligados. Quando o executor está offline, a execução no GitHub aguarda um executor disponível. As variáveis de banco são do laboratório local, com dados fictícios.
