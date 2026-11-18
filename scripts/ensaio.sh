#!/usr/bin/env bash
# Ensaio automático de referência. Não altera os arquivos SQL nem o banco da aula.
set -euo pipefail
cd "$(dirname "$0")/.."
export WS4_PROJECT=ws4-ensaio
trap 'bash demo.sh encerrar >/dev/null 2>&1 || true' EXIT
bash demo.sh subir
bash demo.sh conexao
echo 'Autenticação: uma senha incorreta deve ser recusada.'
if docker compose -p "$WS4_PROJECT" exec -T db sh -c \
  'PGPASSWORD=senha_incorreta_de_teste psql -X -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1"'; then
  echo 'ERRO: o servidor aceitou a senha incorreta.' >&2
  exit 1
else
  codigo=$?
  if [ "$codigo" -ne 2 ]; then
    echo "ERRO: falha inesperada na conexão de teste, código $codigo." >&2
    exit "$codigo"
  fi
fi
bash demo.sh base
bash demo.sh passos
bash demo.sh inicio
echo 'Consulta inicial: devem aparecer Ana e Diego.'
bash demo.sh consultar
if bash demo.sh testar; then
  echo 'ERRO: o teste deveria ter rejeitado a consulta inicial.' >&2
  exit 1
else
  codigo=$?
  if [ "$codigo" -ne 3 ]; then
    echo "ERRO: houve falha de infraestrutura ou execução, código $codigo." >&2
    exit "$codigo"
  fi
fi
bash demo.sh diagnosticar
bash demo.sh referencia
bash demo.sh consultar
bash demo.sh testar
bash demo.sh contagem
echo 'ENSAIO OK: falha esperada na consulta inicial e testes aprovados na referência.'
