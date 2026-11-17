# Laboratório Git e Pull Request

Roteiro de apoio para o instrutor e ensaio opcional. Não cria entrega adicional da turma. Os exemplos usam Bash e devem ser executados na raiz do repositório.

## Opção A: mostrar o PR de referência

Abra [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1). Compare a descrição, Files changed e Checks. Mostre o filtro movido do WHERE para o ON e o arquivo de evidências.

Essa opção reduz os riscos de tempo. Diga que o PR foi preparado antes, sem apresentar sua abertura como ação feita ao vivo.

## Opção B: criar um novo PR durante a aula

### 1. Partida

```bash
git status --short --branch
git switch main
git pull --ff-only
git switch -c aula/clientes-19nov-ensaio1
```

Use outro nome se essa branch já existir. Se houver alterações próprias não salvas, conclua ou preserve seu trabalho antes de trocar de branch. Não use reset destrutivo para preparar a apresentação.

### 2. Reproduzir e explicar

```bash
bash demo.sh subir
bash demo.sh base
bash demo.sh aplicar
bash demo.sh testar
```

O FAIL inicial é esperado. Discuta o requisito e use a IA como Tutora. Corrija manualmente `sql/02_consulta.sql` e então:

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
bash scripts/registrar-evidencia.sh
cp docs/registro-ia-modelo.md docs/registro-ia.md
```

Preencha o registro com interações reais antes de incluí-lo no commit. Se você usou uma simulação, identifique-a como tal. Não marque uma interação fictícia como evidência do uso de IA de um Fellow.

### 3. Conferir e versionar

```bash
git diff -- sql/02_consulta.sql
git status --short
git add sql/02_consulta.sql docs/registro-ia.md
```

Inclua também o arquivo de evidência pelo **caminho exato impresso pelo script**, usando `git add` seguido desse caminho. Depois:

```bash
git diff --cached
git commit -m "Inclui clientes sem pedidos pagos no relatorio"
git push -u origin HEAD
```

### 4. Abrir e revisar

No GitHub, abra um PR com base `main` e compare a branch da aula. O template solicita o requisito, a alteração, a validação e o uso de IA.

Descrição sugerida, para adaptar às evidências reais:

> O relatório omitia clientes sem pedidos pagos. O filtro de status agora faz parte da condição ON do LEFT JOIN. O teste compara o resultado completo com o contrato e cobre o cenário sem pagamentos. As saídas da execução e as decisões registradas acompanham a mudança.

O check automatizado usa os mesmos arquivos SQL em um PostgreSQL novo no Docker. Compare a execução remota com a local. Check verde informa que os testes definidos passaram, não que toda regra possível de negócio foi comprovada.

Comentário de revisão sugerido: “Qual teste comprova que clientes com somente pedidos cancelados continuam aparecendo?”. A resposta deve apontar Bruno no contrato e a comparação do conjunto em `sql/03_testes.sql`.

### 5. Ajuste após comentário

Se houver um pedido real de esclarecimento, altere a documentação ou o código correspondente. Rode os testes se mudou a consulta. Faça outro commit e push na mesma branch. O PR recebe o novo commit.

O merge depende das regras do repositório e da revisão combinada. Deixe o PR de referência aberto para o encontro. Não é necessário fazer merge na aula.

## Trocar entre exemplo e correção

Com a árvore de trabalho limpa:

```bash
git switch main
bash demo.sh aplicar
# Para consultar a branch corrigida de referência:
git switch fix/clientes-sem-pagamento
bash demo.sh aplicar
```

Trocar a branch não altera o banco automaticamente. Para continuar com os exemplos novos, mantenha a branch de referência atualizada com a main.

## Acesso dos alunos

O repositório é privado. A participação oral não depende de clone. Quem quiser reproduzir ou abrir PR depois precisa de acesso concedido pelo proprietário, ou de uma cópia autorizada em outro repositório. Este material não adiciona colaboradores automaticamente.
