# Tags e releases de banco

Uma tag dá nome a um commit. Ela não é um novo commit e não substitui o PR. Neste laboratório, `bd-v0004` identifica a versão 04 aplicada no PostgreSQL; `bd-v0005`, a versão 05, e assim por diante. A numeração é sequencial por script, sem significado de versão semântica.

## Relação entre as evidências

| Registro | O que identifica |
|---|---|
| Script numerado | A mudança proposta e sua ordem de execução |
| Pull Request | O diff, a justificativa e os checks da promoção develop → main |
| Commit do merge | O código incorporado à main |
| ws4_controle.versoes | O script, hash, commit e execução efetivamente confirmados no banco |
| Tag anotada bd-vNNNN | Um nome permanente para esse commit aplicado |
| GitHub Release | O script e os links das evidências daquela versão |

Se vários scripts foram aplicados no mesmo merge, suas tags apontam para o mesmo commit. Uma tag histórica aponta para o commit registrado na aplicação original, não para o estado mais recente da develop.

## Sequência automatizada

1. O push na develop e o PR executam os quatro checks.
2. A main protegida recebe o merge após os checks.
3. O workflow aplica somente os scripts pendentes e valida os contratos no PostgreSQL.
4. Depois da confirmação no banco, `scripts/publicar-releases.py` confere os hashes do histórico com o catálogo e cria as tags e releases ausentes.
5. A seção **Releases** do GitHub e o resumo do workflow permitem abrir a versão e sua evidência de aplicação.

A criação de tags usa o GITHUB_TOKEN do workflow com permissão de escrita no repositório. A credencial não é salva no clone nem incluída nos scripts SQL. Os jobs de testes continuam com leitura. Nenhum token pessoal precisa ser colocado no repositório.

As versões anteriores à adoção desta etapa precisam ter suas tags históricas cadastradas com uma conta autorizada, apontando para os commits originais registrados no banco. Neste laboratório, o proprietário criou as tags 01 a 06; o workflow publica as respectivas releases e a tag da versão nova. A API pode exigir permissão adicional para criar referências históricas com o token temporário do Actions.

A automação nunca move uma tag existente para outro commit; uma divergência interrompe essa etapa para revisão. Reexecutar não duplica tags ou releases.

## Conferir no GitHub e no clone

Abra **Releases** para ver a versão, o commit e o workflow. No terminal:

```bash
git fetch origin --tags
git tag --list 'bd-v*'
git show --no-patch bd-v0004
git rev-parse 'bd-v0004^{commit}'
```

Compare o SHA com:

```sql
SELECT versao, arquivo, commit_sha, execucao, aplicado_em
FROM ws4_controle.versoes
ORDER BY versao;
```

Não crie uma tag de “aplicado” antes de o banco confirmar a execução. Tags manuais de planejamento têm outro significado e não são utilizadas neste exemplo.

## Se a publicação da release falhar

A confirmação SQL acontece antes da chamada à API do GitHub. Se a API falhar, o banco pode já estar atualizado, e o workflow ficará com falha nessa etapa. Isso não desfaz automaticamente o deploy confirmado. Confira `ws4_controle.versoes` e os logs antes de agir. Depois de resolver o acesso ao GitHub, execute o workflow manualmente na main para reconciliar as tags/release ausentes. Os scripts já aplicados serão preservados.

A consulta `07_Select_Test_Table.sql` valida a tabela final das etapas 04 a 06. Como os testes temporários usam ROLLBACK, seu resultado esperado é vazio. Se forem inseridos dados permanentes nessa tabela, esse contrato de laboratório deve ser reavaliado em nova versão.

Referência: [permissões para criar referências Git](https://docs.github.com/en/rest/git/refs#create-a-reference).

## Exemplo de mudança pequena

`08_Alter_Test_Table_Comment.sql` muda somente a descrição documental de `teste_deploy.descricao`. O contrato lê o comentário nos catálogos do PostgreSQL e as consultas vigentes continuam sendo testadas. A etapa também permite acompanhar uma nova tag criada pelo workflow no commit dessa publicação.
