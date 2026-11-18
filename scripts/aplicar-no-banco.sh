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
export PGCONNECT_TIMEOUT=10
psql_base=(psql -X -v ON_ERROR_STOP=1 -P pager=off)
echo 'Resultado antes da aplicação:'
"${psql_base[@]}" -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;'
# O teste original usa BEGIN/ROLLBACK para seu cenário temporário. Savepoint
# preserva a transação externa da aplicação, inclusive ao restaurar os pedidos.
{
  echo 'SELECT pg_advisory_xact_lock(1942026);'
  cat "$consulta"
  sed -e 's/^BEGIN;$/SAVEPOINT cenario_sem_pagamentos;/' \
      -e 's/^ROLLBACK;$/ROLLBACK TO SAVEPOINT cenario_sem_pagamentos;/' sql/03_testes.sql
  echo "COMMENT ON VIEW ws4.resumo_clientes IS :'origem';"
} | "${psql_base[@]}" --single-transaction -v "origem=Workshop 4: commit $commit; execução ${GITHUB_RUN_ID:-local}"
echo "Aplicação validada: $commit"
echo 'Resultado após a aplicação:'
"${psql_base[@]}" -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;' \
  -c "SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo '## Consulta aplicada no banco de demonstração'
    echo
    echo "Commit: \`$commit\`"
    echo
    echo 'Aplicação e testes concluídos na mesma transação. Dados de clientes e pedidos preservados.'
    echo
    echo 'O banco permanece disponível para consulta no pgAdmin.'
  } >> "$GITHUB_STEP_SUMMARY"
fi
