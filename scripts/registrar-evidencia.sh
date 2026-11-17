#!/usr/bin/env bash
# Registra a execução atual. Falha do teste continua sendo falha do comando.
set -euo pipefail
cd "$(dirname "$0")/.."
destino="${1:-docs/evidencias-$(date +%Y%m%d-%H%M%S).txt}"
if [ -e "$destino" ]; then
  echo "O arquivo já existe: $destino. Escolha outro nome para preservar a evidência." >&2
  exit 2
fi
codigo_consulta=0
codigo_teste=0
codigo_definicao=0
{
  date '+Data local da execução: %Y-%m-%d %H:%M:%S %z'
  echo "Commit: $(git rev-parse HEAD 2>/dev/null || echo 'fora de repositorio git')"
  echo 'Arquivos SQL modificados em relação ao commit:'
  git status --short -- sql/ solucao/ exemplos/ 2>/dev/null || true
  echo 'Definição efetivamente aplicada no banco: bash demo.sh definicao'
  if bash demo.sh definicao; then codigo_definicao=0; else codigo_definicao=$?; fi
  echo "Código de saída da definição: $codigo_definicao"
  echo 'Comando: bash demo.sh consultar'
  if bash demo.sh consultar; then codigo_consulta=0; else codigo_consulta=$?; fi
  echo "Código de saída da consulta: $codigo_consulta"
  echo 'Comando: bash demo.sh testar'
  if bash demo.sh testar; then codigo_teste=0; else codigo_teste=$?; fi
  echo "Código de saída dos testes: $codigo_teste"
} > "$destino" 2>&1
cat "$destino"
echo "Evidência salva em: $destino"
if [ "$codigo_definicao" -ne 0 ]; then exit "$codigo_definicao"; fi
if [ "$codigo_consulta" -ne 0 ]; then exit "$codigo_consulta"; fi
exit "$codigo_teste"
