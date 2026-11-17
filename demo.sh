#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
psql_ws() { docker compose -p ws4-workshop exec -T db psql -X -v ON_ERROR_STOP=1 -U workshop -d workshop "$@"; }
case "${1:-ajuda}" in
  subir) docker compose -p ws4-workshop up -d --wait ;;
  base) psql_ws < sql/01_base.sql ;;
  aplicar) psql_ws < sql/02_consulta.sql ;;
  consultar) psql_ws -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;' ;;
  testar) psql_ws < sql/03_testes.sql ;;
  encerrar) docker compose -p ws4-workshop down ;;
  *) echo 'Uso: bash demo.sh {subir|base|aplicar|consultar|testar|encerrar}' ;;
esac
