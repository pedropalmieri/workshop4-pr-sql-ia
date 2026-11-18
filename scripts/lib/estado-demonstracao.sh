#!/usr/bin/env bash
# Configuração explícita dos dois estados conhecidos do exercício.
estado_demonstracao() {
  local estado=corrigido
  if [[ -f sql/estado-demonstracao.txt ]]; then
    estado="$(cat sql/estado-demonstracao.txt)"
  fi
  case "$estado" in
    corrigido) ;;
    inicial)
      # Nunca considerar um SQL arbitrário como um retorno didático conhecido.
      if ! cmp -s sql/02_consulta.sql exemplos/consulta-com-erro.sql; then
        echo 'Estado inicial exige a versão original de exemplos/consulta-com-erro.sql.' >&2
        return 2
      fi
      ;;
    *) echo "Estado de demonstração inválido: $estado" >&2; return 2 ;;
  esac
  printf '%s\n' "$estado"
}
