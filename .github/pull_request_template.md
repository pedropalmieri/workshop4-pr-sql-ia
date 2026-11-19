## Card e release

Card relacionado: #...
Release planejada: bd-v...
Autor: conta individual que abriu o PR.
Revisor: outra pessoa, que registra a decisão com sua conta.
Aprovação de liberação: link da decisão no card, antes do merge.

## Objetivo e impacto

Qual requisito ou mudança de estrutura esta release atende? A consulta é de leitura ou existe alteração DDL?

## Versões novas

Liste os scripts `consultas/NN_Operacao_Objeto.sql` e seus testes. Preserve as versões anteriores. Se este PR trata do exercício em `sql/`, identifique o estado declarado.

## Validação

- [ ] Trabalhei na develop e o PR tem destino main.
- [ ] Os checks origem, sql, interface e versoes passaram na versão final.
- [ ] Calculei o resultado/estrutura esperados independentemente do script.
- [ ] Avaliei impacto nos dados e dependências. Não há perda de dados implícita na conversão.
- [ ] Registrei a evidência e a validação reais.

## IA Tutora

Identifique ferramenta, tarefa, orientação, decisão e validação, quando usada. Não invente interações nem trate exemplos como evidência real.

## Conferência após merge

Indique a consulta para conferir a tabela ou o resultado e o registro em ws4_controle.versoes.
