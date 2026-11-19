# Fluxo develop, Pull Request e main

## Responsabilidade de cada branch

| Branch | Uso |
|---|---|
| `develop` | Recebe o desenvolvimento, os scripts novos, testes e documentação. Um push dispara a validação em banco temporário. |
| `main` | Contém as versões promovidas por PR validado. Simula o código autorizado para execução no banco de demonstração. |

O repositório é público. A main exige PR e os checks `origem`, `sql`, `interface` e `versoes`, com a branch atualizada. A regra inclui administradores, bloqueia force push e exclusão. PRs para a main devem vir da develop do próprio repositório.

O merge é manual. Não há exigência de aprovação de uma segunda conta nesta demonstração: a mesma conta abre o PR e confirma o merge após os checks. A revisão de outra pessoa pode ser incluída no processo, mas não foi configurada como requisito obrigatório.

## Criar uma versão nova

No terminal, dentro do clone e com alterações próprias preservadas:

```bash
git switch develop
git pull --ff-only
```

No editor, crie o próximo `NN_Descricao.sql` em `consultas/` e o teste com mesmo nome em `consultas/testes/`. Preserve todos os arquivos anteriores. O [catálogo](../consultas/README.md) explica o padrão e traz consultas e modelos de DDL.

O arquivo `03_Select_Client_Report.sql` é um exemplo já existente. Para uma alteração posterior, use o próximo número livre. Os arquivos em `consultas/modelos/` são referências, não versões ativas.

Confira e envie somente os arquivos da mudança:

```bash
git status --short
git diff
# Substitua os dois caminhos abaixo pelos arquivos novos criados.
git add consultas/NN_Descricao.sql consultas/testes/NN_Descricao.json
git commit -m "Adiciona nova versão de consulta SQL"
git push origin develop
```

`NN_Descricao` é um marcador a substituir, não um nome válido para o catálogo. Não execute o git add acima sem informar os nomes reais.

## O que os Actions verificam?

| Check | Verificação |
|---|---|
| `origem` | PR de develop para main, no mesmo repositório |
| `sql` | Contrato ou reprodução explícita do estado inicial do exercício anterior |
| `interface` | pgAdmin e conexão com PostgreSQL no ambiente temporário |
| `versoes` | Nome, número único, preservação dos arquivos anteriores, sintaxe do PostgreSQL 17, execução, testes esperados, dados originais preservados e testes dos modelos/rejeições |

A análise usa o parser PostgreSQL e a execução real no banco isolado. Um nome de coluna inexistente, erro de sintaxe, retorno diferente do esperado ou tentativa de alterar uma versão anterior falha na validação. Os testes negativos também verificam operações fora do escopo e conversão float com perda de fração.

## Abrir e promover a release

No GitHub, escolha **Pull requests > New pull request**:

- **base:** main.
- **compare:** develop.

A descrição explica objetivo, arquivos novos, resultado esperado, testes e impacto. Se houver uso de IA, registre a orientação e a validação reais. Aguarde os quatro checks. Se a main recebeu outra mudança, atualize a develop e valide novamente antes de mesclar.

Após revisão, confirme o merge. A aplicação usa o commit incorporado, confere a validação final do PR e registra somente versões ainda não executadas. O lote novo é transacional: uma falha impede sua confirmação. Alterações apenas em documentação não acionam execução SQL.

A publicação do catálogo não substitui o relatório histórico do caso. Os arquivos em `sql/` preservam o exercício de correção e seu teste; a pasta para novas versões é `consultas/`.

## Conferir a release no banco

```sql
SELECT versao, arquivo, sha256, commit_sha, execucao, aplicado_em, resultado
FROM ws4_controle.versoes
ORDER BY versao;
```

Para uma criação de tabela de teste, execute seu SELECT no pgAdmin e confira também as colunas em information_schema. Um SELECT sozinho publica um arquivo e registra seu resultado; não cria uma tabela persistente.

Depois do merge, sincronize a develop:

```bash
git switch develop
git fetch origin
git merge --ff-only origin/main
git push origin develop
```

Se houver commits novos na develop ainda não promovidos, o fast-forward pode não ser possível. Nesse caso, revise e integre as alterações da main sem descartar o trabalho existente.

## Ambiente de demonstração

A main simula a promoção produtiva, mas o banco é um laboratório com dados fictícios e armazenamento temporário. Testes e aplicação usam ambientes diferentes. O executor Docker do banco precisa estar disponível; o pgAdmin permite acompanhar o resultado. Os detalhes estão na [arquitetura](arquitetura-automacao.md).

## Processo de aprovação e release

Cada pessoa usa sua própria conta. O [processo de deploy BD](processo-release-bd.md) relaciona card, autor, revisão por outra pessoa, aprovação da release, execução e conferência. O laboratório explicita quais controles estão automatizados e quais aprovações são demonstradas como processo de equipe.

## Tags e releases

Após a confirmação no banco, a automação publica tags anotadas `bd-vNNNN` e releases no GitHub, apontando para o commit registrado em cada versão. Veja [como conferir a release e seu commit](tags-e-releases.md).
