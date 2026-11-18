#!/usr/bin/env bash
# Testa os dois estados e o rollback em banco separado, sem tocar no laboratório.
set -euo pipefail
cd "$(dirname "$0")/.."
export WS4_PROJECT=ws4-aplicacao-validacao
trap 'bash demo.sh encerrar >/dev/null 2>&1 || true' EXIT
bash demo.sh subir
bash demo.sh base
bash demo.sh referencia
docker run --rm -i --network "${WS4_PROJECT}_default" \
  -e PGHOST=db -e PGPORT=5432 -e PGDATABASE=workshop \
  -e PGUSER=workshop -e PGPASSWORD=workshop_local \
  -e GITHUB_SHA=0000000000000000000000000000000000000000 \
  -v "$PWD:/workspace:ro" ws4-actions-runner:local bash -s <<'RUNNER'
set -euo pipefail
mkdir /tmp/validacao
cp -r /workspace/scripts /workspace/sql /workspace/exemplos /workspace/solucao /tmp/validacao/
cd /tmp/validacao
query() { psql -X -At -v ON_ERROR_STOP=1 -c "$1"; }
assinatura_sql="SELECT md5(string_agg(t::text,',' ORDER BY t::text)) FROM (SELECT row_to_json(c)::text AS t FROM ws4.clientes c UNION ALL SELECT row_to_json(p)::text FROM ws4.pedidos p) x;"
dados_antes="$(query "$assinatura_sql")"
echo inicial > sql/estado-demonstracao.txt
cp exemplos/consulta-com-erro.sql sql/02_consulta.sql
bash scripts/aplicar-no-banco.sh
[[ "$(query 'SELECT count(*) FROM ws4.resumo_clientes;')" == 2 ]]
if psql -X -v ON_ERROR_STOP=1 -f sql/03_testes.sql; then
  echo 'ERRO: contrato aprovou estado inicial.' >&2; exit 1
else
  [[ "$?" == 3 ]]
fi
echo corrigido > sql/estado-demonstracao.txt
cp solucao/02_consulta.sql sql/02_consulta.sql
bash scripts/aplicar-no-banco.sh
[[ "$(query 'SELECT count(*) FROM ws4.resumo_clientes;')" == 4 ]]
definicao="$(query "SELECT pg_get_viewdef('ws4.resumo_clientes'::regclass,true);")"
origem="$(query "SELECT obj_description('ws4.resumo_clientes'::regclass);")"
cp exemplos/consulta-com-erro.sql sql/02_consulta.sql
if bash scripts/aplicar-no-banco.sh; then
  echo 'ERRO: modo corrigido aceitou consulta incorreta.' >&2; exit 1
else
  [[ "$?" == 3 ]]
fi
[[ "$(query "SELECT pg_get_viewdef('ws4.resumo_clientes'::regclass,true);")" == "$definicao" ]]
[[ "$(query "SELECT obj_description('ws4.resumo_clientes'::regclass);")" == "$origem" ]]
echo inicial > sql/estado-demonstracao.txt
printf '\n-- diferente da versão inicial autorizada\n' >> sql/02_consulta.sql
if bash scripts/aplicar-no-banco.sh; then
  echo 'ERRO: modo inicial aceitou SQL diferente do original.' >&2; exit 1
else
  [[ "$?" == 2 ]]
fi
[[ "$(query "$assinatura_sql")" == "$dados_antes" ]]
echo 'VALIDAÇÃO OK: retorno inicial, correção, rollback, bloqueio de SQL não autorizado e preservação dos dados.'
RUNNER
