# Laboratório: validação e revisão de uma consulta

O fluxo registra uma mudança de SQL, suas evidências e a justificativa das decisões. Os comandos usam Bash e partem da raiz do repositório.

## 1. Branch de trabalho

Com a árvore de trabalho limpa:

```bash
git status --short --branch
git switch main
git pull --ff-only
git switch -c exercicio/clientes-sem-pagamento
```

Use um nome diferente se a branch já existir. Preserve alterações próprias antes de trocar de branch.

## 2. Reprodução do problema

O resultado da consulta também pode ser acompanhado no pgAdmin. O terminal abaixo aplica a versão do arquivo e executa a validação.

```bash
bash demo.sh subir
bash demo.sh conexao
bash demo.sh base
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Na implementação inicial, o teste falha porque há clientes ausentes. Compare o resultado com o [contrato](contrato.md), investigue a condição de junção e faça a alteração em `sql/02_consulta.sql`.

## 3. Validação e evidência

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
bash scripts/registrar-evidencia.sh
cp docs/registro-ia-modelo.md docs/registro-ia.md
```

O arquivo gerado contém a definição efetivamente aplicada no banco e as saídas dos testes. Preencha o registro com as interações reais com IA: tarefa, justificativa, orientação, decisão, evidência e retrabalho. O [exemplo ilustrativo](registro-ia-exemplo.md) mostra o formato e não representa uma conversa real.

## 4. Commit e envio

```bash
git diff -- sql/02_consulta.sql
git status --short
git add sql/02_consulta.sql docs/registro-ia.md
```

Inclua também a evidência usando `git add` seguido do caminho exato impresso pelo script. Confira o conteúdo antes de confirmar:

```bash
git diff --cached
git commit -m "Inclui clientes sem pedidos pagos no relatorio"
git push -u origin HEAD
```

## 5. Pull Request

No GitHub, abra um PR com base `main` e compare a branch de trabalho. O template reúne requisito, alteração, testes e uso da IA.

Uma descrição deve explicar o problema concreto e o resultado da mudança. Exemplo:

> O relatório omitia clientes sem pedidos pagos. O filtro de status agora faz parte da condição ON do LEFT JOIN. Os testes comparam o resultado com o contrato e cobrem um cenário sem pagamentos. As evidências da execução acompanham a alteração.

O check automatizado executa os testes em um PostgreSQL novo no Docker. A aprovação comprova os cenários definidos, sem substituir a revisão do requisito.

## 6. Revisão e ajustes

Questões para revisão:

- Qual teste garante a presença de clientes com apenas pedidos cancelados?
- COUNT(p.id) e COUNT(*) produziriam os mesmos resultados?
- O total zero de Diego preserva a contagem de seu pedido?
- A evidência corresponde à definição de consulta aplicada?
- As decisões com IA estão justificadas por resultados observáveis?

Após um pedido de ajuste, altere o arquivo correspondente, valide novamente quando necessário e envie outro commit na mesma branch. O PR recebe a atualização. O merge depende da revisão e das regras do repositório.

O [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) apresenta uma solução de referência com evidência e check automatizado.

## Branch e estado do banco

Trocar de branch altera os arquivos, mas não reaplica a consulta no PostgreSQL:

```bash
git switch main
bash demo.sh aplicar
```

O acesso ao repositório privado é necessário para clone e envio de alterações. A discussão durante o workshop não exige entrega própria.
