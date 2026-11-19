# Da consulta SQL ao Pull Request

Este guia mostra onde executar a consulta, qual arquivo alterar e como enviar a correção de uma branch para a `main`. O acesso ao repositório privado é necessário. Os comandos usam Bash na raiz do clone.

## 1. O que fica em cada lugar?

| Lugar | O que fazer | O que essa ação registra |
|---|---|---|
| pgAdmin, no Query Tool | Executar SELECTs e analisar os resultados | A execução no banco; não salva a alteração no Git |
| Editor de texto, no clone local | Alterar `sql/02_consulta.sql` | O arquivo que contém a implementação em revisão |
| Editor, no clone local | Definir `corrigido` em `sql/estado-demonstracao.txt` | O estado que os testes do PR devem exigir |
| Pasta `docs/` no clone | Salvar a evidência e o registro real de uso da IA | A justificativa e a validação da mudança |
| Terminal, na branch | Fazer commit e push | A versão local e seu envio ao GitHub |
| GitHub, no Pull Request | Comparar a branch de trabalho com a `main` | O diff, os checks, a discussão e o merge |

**O SELECT não é publicado diretamente no PR.** Primeiro você salva a alteração no arquivo da branch, faz commit e push. O PR apresenta essa diferença para revisão.

## 2. Cada consulta de exploração precisa de um PR?

Não. As consultas de [exemplos/demonstracao](../exemplos/demonstracao/README.md) e de [respostas às questões](../exemplos/respostas-questoes-slides.sql) servem para explorar dados e compreender o problema no pgAdmin.

Neste caso, o PR reúne a correção do relatório, a declaração do estado corrigido e suas evidências. Não é necessário abrir um PR para cada SELECT executado durante a investigação.

## 3. De onde começar?

Confira o [contrato](contrato.md) e o [estado declarado](../sql/estado-demonstracao.txt). O retorno inicial foi registrado no [PR nº 2](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/2). Quando o estado estiver `inicial`, a nova correção deve alterar o SQL e declarar `corrigido` no mesmo PR.

Se a `main` já estiver corrigida, a mesma correção não produzirá um novo diff útil. Use o histórico para comparar as versões; um novo PR deve conter uma alteração ainda não incorporada.

## 4. Criar a branch antes de editar os arquivos

No terminal, entre na pasta clonada e confira se não há alterações próprias pendentes:

```bash
git status --short --branch
git switch main
git pull --ff-only
git switch -c exercicio/corrigir-relatorio-pagos
```

Se esse nome de branch já existir, escolha outro. Preserve as alterações próprias antes de trocar de branch. A partir daqui, os arquivos editados pertencem à branch `exercicio/corrigir-relatorio-pagos`, não à `main`.

## 5. Observar o problema no pgAdmin

Com a base carregada, abra o Query Tool do banco `workshop`. Execute o conteúdo de [consulta-inicial.sql](../exemplos/consulta-inicial.sql). O resultado mostra apenas Ana e Diego, enquanto o requisito inclui também Bruno e Carla.

Use as consultas de exploração para identificar a causa. A [biblioteca de prompts](../prompts/README.md) permite pedir uma explicação à IA Tutora, sem delegar a implementação.

Para conferir a versão aplicada e reproduzir a falha pelo terminal:

```bash
bash demo.sh consultar
bash demo.sh testar
```

No estado inicial, o teste deve falhar por resultado diferente do contrato. Uma falha de conexão não corresponde a esse defeito.

## 6. Onde salvar a correção do SELECT?

**No editor, abra `sql/02_consulta.sql` dentro do clone.** Esse é o arquivo que o teste e a automação aplicam. Não basta alterar um SELECT no Query Tool ou salvar apenas uma cópia na pasta `exemplos/`.

A condição de status deve participar do ON. Remova o filtro de status do WHERE. O trecho SELECT do arquivo deve ficar assim:

```sql
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome;
```

Preserve a estrutura restante do arquivo e atualize os comentários para descrever o comportamento corrigido. A [solução de referência](../solucao/02_consulta.sql) permite comparar a implementação completa.

**Abra também `sql/estado-demonstracao.txt` e deixe seu conteúdo como:**

```text
corrigido
```

Salve os dois arquivos. Não altere os valores esperados dos testes para aceitar um resultado errado.

## 7. Aplicar o arquivo local e testar antes do commit

No terminal, na mesma branch:

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
bash scripts/testar-estado.sh
```

`aplicar` usa o arquivo que você acabou de salvar. `consultar` mostra a implementação aplicada. Os testes precisam aprovar os quatro clientes e o cenário sem pagamentos.

| Cliente | Pedidos pagos | Total pago |
|---|---|---|
| Ana | 2 | 150.00 |
| Bruno | 0 | 0.00 |
| Carla | 0 | 0.00 |
| Diego | 1 | 0.00 |

No pgAdmin, execute novamente a consulta abaixo para atualizar o resultado exibido:

```sql
SELECT id, nome, pedidos_pagos, total_pago
FROM ws4.resumo_clientes
ORDER BY id;
```

A execução local ajuda a validar antes do PR. Depois do merge, o workflow executará novamente a aplicação do commit incorporado à `main`.

## 8. Salvar a evidência e as decisões

Gere uma evidência real:

```bash
bash scripts/registrar-evidencia.sh docs/evidencias-correcao-relatorio.txt
```

Se esse arquivo já existir, escolha outro nome para preservar o registro anterior e use o novo caminho também no `git add`. O script não sobrescreve evidências existentes. Sua saída deve indicar sucesso dos testes.

Crie `docs/registro-ia.md` a partir do [modelo de registro](registro-ia-modelo.md), preenchendo a interação, a decisão e a validação reais. Se o arquivo já existir, preserve os registros e acrescente a nova interação. Não invente respostas ou sugestões para completar campos.

A evidência registra o estado local testado, incluindo alterações ainda não commitadas. O PR reunirá esse arquivo com a versão final do SQL.

## 9. Fazer commit dos arquivos certos

Confira o diff e os arquivos modificados:

```bash
git diff -- sql/02_consulta.sql sql/estado-demonstracao.txt
git status --short
```

Inclua os arquivos da alteração e suas evidências:

```bash
git add sql/02_consulta.sql sql/estado-demonstracao.txt docs/registro-ia.md docs/evidencias-correcao-relatorio.txt
git diff --cached
git commit -m "Corrige relatorio para incluir clientes sem pedidos pagos"
```

Se você usou outro nome para a evidência, substitua o caminho no comando. O `git diff --cached` permite verificar exatamente o que entrará no commit.

## 10. Publicar a branch no GitHub

```bash
git push -u origin exercicio/corrigir-relatorio-pagos
```

Se escolheu outro nome de branch, use esse nome. O push envia a branch e seus commits. Ele ainda não incorpora a alteração à `main`.

## 11. Abrir o Pull Request da branch para a main

No repositório do GitHub, abra **Pull requests > New pull request** e selecione:

| Campo | Valor | Significado |
|---|---|---|
| base | `main` | Destino que receberá a mudança |
| compare | `exercicio/corrigir-relatorio-pagos` | Origem dos commits enviados |

Confira o diff, preencha a descrição e crie o PR. A descrição precisa explicar o problema, a alteração, os testes executados e o registro de IA.

Exemplo de descrição da mudança:

> O relatório omitia clientes sem pedidos pagos. O filtro de status passou do WHERE para o ON do LEFT JOIN. A mudança preserva todos os clientes. O PR inclui a declaração do estado corrigido, a evidência dos testes e o registro real das decisões com IA.

A frase sobre evidências deve corresponder aos arquivos realmente incluídos no PR. Os checks **Testes SQL** precisam passar antes do merge. Eles validam a proposta em banco temporário, sem aplicar a branch ao banco da demonstração.

## 12. Como enviar um ajuste pedido na revisão?

Continue na mesma branch. Edite o arquivo, aplique e teste novamente se mudou o SQL. Registre a nova evidência e envie outro commit:

```bash
git status --short
git diff -- sql/02_consulta.sql sql/estado-demonstracao.txt
```

Depois de adicionar os arquivos ajustados e fazer o novo commit:

```bash
git push
```

O PR existente recebe os novos commits. Não é necessário abrir outro PR para cada ajuste da mesma correção.

## 13. O que acontece depois do merge?

Após revisão e merge de um PR para a `main` com mudança em `sql/`, o workflow **Aplicar main no banco de demonstracao** aplica o commit mesclado no banco existente. A aprovação do PR, sozinha, não executa o SQL.

Confira a execução em **Actions**. No sucesso, execute novamente o SELECT do relatório no pgAdmin e consulte o identificador da aplicação:

```sql
SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;
```

Se a validação da aplicação falhar, a transação é desfeita e o banco mantém a versão anterior. O [guia de aplicação](aplicacao-main.md) detalha a disponibilidade do executor e os estados do exercício.

Atualize seu clone depois do merge:

```bash
git switch main
git pull --ff-only
```

Trocar de branch ou executar `git pull` atualiza arquivos, não reaplica automaticamente o SQL local. A execução no banco vem de `bash demo.sh aplicar` ou do workflow configurado após o merge.

## Resumo do caminho da alteração

**pgAdmin:** explorar e observar. **Editor:** salvar a correção em `sql/02_consulta.sql` e declarar `corrigido`. **Terminal:** aplicar, testar, registrar, fazer commit e push. **GitHub:** abrir o PR da branch para a `main`, revisar e fazer merge. **Workflow:** aplicar o commit no banco e registrar o resultado.

O [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) preserva a correção anterior. O workshop não exige uma entrega adicional; este guia documenta como realizar a alteração do caso.

Referência: [criar um Pull Request no GitHub](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
