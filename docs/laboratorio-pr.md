# Publicar a consulta do caso por Pull Request

O [caso completo](estudo-de-caso.md) apresenta os dados, o requisito e as perguntas. A pasta principal de novas publicações é `consultas/`. Cada versão recebe outro arquivo SQL e um teste de mesmo nome; versões já publicadas permanecem imutáveis.

## 1. Explorar o caso no pgAdmin

Abra o Query Tool do banco do laboratório. Execute as consultas de [exploração](../exemplos/demonstracao/README.md) e a [consulta inicial](../exemplos/consulta-inicial.sql). Compare o resultado com o contrato: todos os quatro clientes devem aparecer, incluindo quem não tem pagamento.

Executar SQL no pgAdmin não salva o código no Git. O arquivo precisa ser criado no clone para aparecer no PR.

## 2. Atualizar a develop

Na raiz do clone:

```bash
git status --short --branch
git switch develop
git pull --ff-only
```

Preserve alterações próprias pendentes antes de trocar de branch. Confira o maior número já publicado em `consultas/`. Depois das versões 01 a 08, o próximo número é 09. Se outra versão já tiver sido publicada, use o número seguinte.

## 3. Criar o arquivo e seu teste

No editor, crie `consultas/09_Select_Client_Report.sql`. Para reproduzir a falha antes da correção, copie o conteúdo de `exemplos/consulta-inicial.sql`. Crie também `consultas/testes/09_Select_Client_Report.json`, usando como referência o contrato em `consultas/testes/03_Select_Client_Report.json`.

O teste deve exigir os quatro clientes e os totais calculados manualmente. Não altere a expectativa para aceitar o retorno incorreto. O arquivo 03 continua preservado. Os ajustes no arquivo 09 são permitidos enquanto ele ainda não tiver sido publicado na main.

## 4. Investigar, corrigir e justificar

O filtro de status deve participar do ON da junção. O novo arquivo, depois da análise, contém:

```sql
-- Relatório: preservar todos os clientes e contabilizar somente pedidos pagos.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
```

| Cliente | Pedidos pagos | Total pago |
|---|---|---|
| Ana | 2 | 150.00 |
| Bruno | 0 | 0.00 |
| Carla | 0 | 0.00 |
| Diego | 1 | 0.00 |

A [biblioteca de prompts](../prompts/README.md) ajuda a investigar com a IA Tutora. Registre a interação real, as sugestões aceitas/rejeitadas e a evidência da validação em um documento novo, usando o [modelo de registro](registro-ia-modelo.md).

Uma nova publicação deve ter um motivo. Se a consulta já atende ao requisito, o histórico e os testes permitem demonstrar a solução existente; não é obrigatório duplicá-la apenas para abrir outro PR.

## 5. Validar em banco separado

Siga os [comandos Docker do catálogo](../consultas/README.md#validar-localmente-com-docker). A validação local usa outro projeto e desfaz a transação. Não recarregue a base do banco compartilhado para testar o PR.

Confira o resultado, a sintaxe e o teste JSON. Uma falha esperada da consulta inicial serve como diagnóstico; a versão final proposta precisa passar.

## 6. Enviar a develop

```bash
git diff -- consultas/
git status --short
git add consultas/09_Select_Client_Report.sql consultas/testes/09_Select_Client_Report.json
git commit -m "Publica consulta de pagamentos com contrato validado"
git push origin develop
```

Inclua no commit também o arquivo de evidências e registro de IA que você realmente criou. Ajuste os nomes se o próximo número livre for outro. Aguarde o workflow do push na develop.

## 7. Abrir o PR

No GitHub, selecione **Pull requests > New pull request**, com **base main** e **compare develop**. Descreva problema, arquivos novos, regra preservada, resultado esperado e testes. O PR apresenta o diff dos arquivos; o SELECT não é colado diretamente no PR como substituto do arquivo.

Os checks obrigatórios são `origem`, `sql`, `interface` e `versoes`. A validação roda em banco temporário, sem aplicar a develop no banco compartilhado. Um ajuste pedido na revisão entra como novo commit na mesma develop e no mesmo PR. Os testes devem passar novamente na versão final.

## 8. Promover e conferir

Após revisão e merge, o workflow aplica apenas as versões pendentes no banco existente. Um SELECT não modifica os registros nem substitui automaticamente outro relatório: publica seu código, executa o contrato e registra o resultado. Execute o arquivo novo no pgAdmin para consultar novamente sua saída.

```sql
SELECT versao, arquivo, commit_sha, execucao, aplicado_em, resultado
FROM ws4_controle.versoes
ORDER BY versao;
```

O mecanismo anterior em `sql/` e os PRs [#1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) e [#2](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/2) preservam o histórico da primeira correção e do retorno ao estado inicial. Para novas versões, use o catálogo numerado.

Depois do merge, sincronize a branch de trabalho:

```bash
git switch develop
git fetch origin
git merge --ff-only origin/main
git push origin develop
```

O [processo corporativo](processo-release-bd.md) explica contas individuais, card, revisão por outra pessoa e aprovação de release. Essas funções são apresentadas como exemplo; o laboratório não exige criar usuários adicionais.
