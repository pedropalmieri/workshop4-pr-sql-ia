#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
project="${WS4_PROJECT:-ws4-workshop}"
psql_ws() { docker compose -p "$project" exec -T db psql -X -v ON_ERROR_STOP=1 -U workshop -d workshop "$@"; }
case "${1:-ajuda}" in
  subir) docker compose -p "$project" up -d --wait ;;
  base) psql_ws < sql/01_base.sql ;;
  aplicar) psql_ws < sql/02_consulta.sql ;;
  inicio) psql_ws < exemplos/consulta-com-erro.sql ;;
  referencia) psql_ws < solucao/02_consulta.sql ;;
  consultar) psql_ws -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;' ;;
  definicao) psql_ws -c "SELECT pg_get_viewdef('ws4.resumo_clientes'::regclass, true);" ;;
  testar) psql_ws < sql/03_testes.sql ;;
  diagnosticar) psql_ws < exemplos/diagnostico-join.sql ;;
  contagem) psql_ws < exemplos/armadilha-count.sql ;;
  encerrar) docker compose -p "$project" down ;;
  ajuda) echo 'Uso: bash demo.sh {subir|base|aplicar|inicio|referencia|consultar|definicao|testar|diagnosticar|contagem|encerrar}' ;;
  *) echo 'Comando desconhecido. Use: bash demo.sh ajuda' >&2; exit 2 ;;
esac
