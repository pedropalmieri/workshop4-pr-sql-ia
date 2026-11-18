#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
project="${WS4_PROJECT:-ws4-workshop}"
psql_ws() {
  docker compose -p "$project" exec -T db sh -c \
    'export PGPASSWORD="$POSTGRES_PASSWORD"; exec psql -X -v ON_ERROR_STOP=1 -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" "$@"' sh "$@"
}
case "${1:-ajuda}" in
  subir) docker compose -p "$project" up -d --wait ;;
  interface) docker compose -p "$project" --profile interface up -d --wait ;;
  parar-interface) docker compose -p "$project" --profile interface stop pgadmin ;;
  base) psql_ws < sql/01_base.sql ;;
  estrutura) psql_ws < exemplos/explorar-estrutura.sql ;;
  conexao) psql_ws -c '\conninfo' -c 'SELECT current_database() AS banco, current_user AS usuario, inet_server_addr() AS endereco, inet_server_port() AS porta;' -c 'SHOW server_version;' ;;
  terminal) docker compose -p "$project" exec db sh -c 'export PGPASSWORD="$POSTGRES_PASSWORD"; exec psql -X -P pager=off -P "null=(NULL)" -v ON_ERROR_STOP=1 -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"' ;;
  aplicar) psql_ws < sql/02_consulta.sql ;;
  inicio) psql_ws < exemplos/consulta-com-erro.sql ;;
  referencia) psql_ws < solucao/02_consulta.sql ;;
  consultar) psql_ws -c 'SELECT * FROM ws4.resumo_clientes ORDER BY id;' ;;
  definicao) psql_ws -c "SELECT pg_get_viewdef('ws4.resumo_clientes'::regclass, true);" ;;
  testar) psql_ws < sql/03_testes.sql ;;
  testar-inicio) psql_ws < sql/04_testes_estado_inicial.sql ;;
  diagnosticar) psql_ws < exemplos/diagnostico-join.sql ;;
  contagem) psql_ws < exemplos/armadilha-count.sql ;;
  passos) psql_ws < exemplos/consultas-passo-a-passo.sql ;;
  encerrar) docker compose -p "$project" --profile interface down ;;
  ajuda) echo 'Uso: bash demo.sh {subir|interface|parar-interface|conexao|estrutura|terminal|base|aplicar|inicio|referencia|consultar|definicao|testar|testar-inicio|diagnosticar|contagem|passos|encerrar}' ;;
  *) echo 'Comando desconhecido. Use: bash demo.sh ajuda' >&2; exit 2 ;;
esac
