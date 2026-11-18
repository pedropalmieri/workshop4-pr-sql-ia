#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/estado-demonstracao.sh
estado="$(estado_demonstracao)"
if [[ "$estado" == corrigido ]]; then
  bash demo.sh testar
else
  bash demo.sh testar-inicio
  # O teste funcional continua acusando a falha conhecida da versão inicial.
  if bash demo.sh testar; then
    echo 'ERRO: o contrato deveria rejeitar a consulta inicial.' >&2
    exit 1
  else
    codigo=$?
    if [[ "$codigo" -ne 3 ]]; then
      echo "ERRO de execução ou infraestrutura, código $codigo." >&2
      exit "$codigo"
    fi
  fi
  echo 'Reprodução do estado inicial validada; falha do contrato confirmada.'
fi
