#!/usr/bin/env bash
# Aplica e valida a consulta em uma transação no banco de demonstração existente.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${PGHOST:?Informe PGHOST}"
: "${PGUSER:?Informe PGUSER}"
: "${PGDATABASE:?Informe PGDATABASE}"
: "${PGPASSWORD:?Informe PGPASSWORD}"
commit="${GITHUB_SHA:-$(git rev-parse HEAD)}"
[[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo 'Commit inválido.' >&2; exit 2; }
consulta="${1:-sql/02_consulta.sql}"
[[ -f "$consulta" ]] || { echo 'Consulta não encontrada.' >&2; exit 2; }
source scripts/lib/estado-demonstracao.sh
estado="$(estado_demonstracao)"
export PGCONNECT_TIMEOUT=10
psql_base=(psql -X -v ON_ERROR_STOP=1 -P pager=off)
echo 'Resultado antes da aplicação:'
"${psql_base[@]}" -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;'
# O teste original usa BEGIN/ROLLBACK para seu cenário temporário. Savepoint
# preserva a transação externa da aplicação, inclusive ao restaurar os pedidos.
{
  echo 'SELECT pg_advisory_xact_lock(1942026);'
  cat "$consulta"
  if [[ "$estado" == corrigido ]]; then
    sed -e 's/^BEGIN;$/SAVEPOINT cenario_sem_pagamentos;/' \
        -e 's/^ROLLBACK;$/ROLLBACK TO SAVEPOINT cenario_sem_pagamentos;/' sql/03_testes.sql
  else
    cat sql/04_testes_estado_inicial.sql
  fi
  echo "COMMENT ON VIEW ws4.resumo_clientes IS :'origem';"
} | "${psql_base[@]}" --single-transaction -v "origem=Workshop 4: estado $estado; commit $commit; execução ${GITHUB_RUN_ID:-local}"
echo "Aplicação validada: estado $estado, commit $commit"
echo 'Resultado após a aplicação:'
"${psql_base[@]}" -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;' \
  -c "SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo '## Consulta aplicada no banco de demonstração'
    echo
    echo "Commit: \`$commit\`"
    echo
    echo "Estado declarado: **$estado**."
    echo
    if [[ "$estado" == inicial ]]; then
      echo 'Retorno didático à consulta original. O contrato de negócio continua com falha conhecida.'
    else
      echo 'Consulta aprovada nos testes do contrato.'
    fi
    echo
    echo 'Aplicação e testes do estado concluídos na mesma transação. Dados preservados.'
    echo
    echo 'O banco permanece disponível para consulta no pgAdmin.'
  } >> "$GITHUB_STEP_SUMMARY"
fi
