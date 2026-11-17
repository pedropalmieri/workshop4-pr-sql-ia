# Workshop 4 · roteiro do instrutor

**Data: 19/11/2026. Duração: 55 minutos e 5 minutos de margem.**

## Ambiente já preparado

O projeto está em [pedropalmieri/workshop4-pr-sql-ia](https://github.com/pedropalmieri/workshop4-pr-sql-ia), com clone local em `~/projetos/workshop4-pr-sql-ia`. O [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) contém a correção de referência e passou no check inicial de 17/11/2026. Para o encontro, use o [guia de condução](guia-de-conducao.md) e o [laboratório Git](../docs/laboratorio-pr.md). A seção de criação de um novo repositório abaixo só se aplica caso você queira montar outro ambiente do zero.

Objetivo: conectar PostgreSQL ao fluxo de PR com teste de consulta e registro de decisões com IA tutora. Caso proposto: relatório de pedidos pagos por cliente. Não há entrega própria do encontro. O exemplo não substitui o enunciado oficial do Desafio Final.

## O que vem do briefing e o que propomos

O briefing estabelece o tema PostgreSQL, a stack Bash/Git/GitHub/PostgreSQL e a IA como Tutora. O Fellow executa, testa e registra ao menos uma sugestão aceita e uma rejeitada com justificativa. O recorte do Desafio Final pede repositório SQL via PR com teste de consulta e registro de delegação/validação. Este roteiro propõe o caso comercial, os dados, o teste e a distribuição de tempo.

A trilha inclui SQL para análise de dados, modelagem com PostgreSQL, Data Literacy com IA e um trecho de ChatGPT para Data Analytics. O encontro usa essas bases para discutir regra de negócio, chaves e relação entre tabelas, diagnóstico do JOIN e validação crítica. Os títulos exatos das seções selecionadas não constam no briefing, então não presumimos domínio de todo o conteúdo dos cursos. O Workshop 3 tratou PostgreSQL, mas o conteúdo efetivamente ministrado não foi fornecido.

Como a data mudou de 12 para 19/11, a abertura considera o Desafio Final já apresentado no dia 17, conforme o cronograma original. Confirmar com a coordenação eventuais mudanças do desafio e o que foi coberto no Workshop 3. A entrega em 24/11 citada no briefing precisa ser confirmada, não é uma nova exigência deste encontro.

## Antes do encontro

1. Abra o PowerPoint e confira modo de apresentação e notas. Use o slide 8 como tela de transição para o computador.
2. Prepare quatro janelas: editor na pasta de treino, terminal, chat de IA e repositório GitHub. Aumente a fonte do terminal e do editor.
3. Na raiz do repositório clonado, execute `bash demo.sh subir`, `base`, `aplicar` e `testar`. A consulta inicial deve falhar no teste. Não deixe o terminal parado no arquivo da solução.
4. Faça o download da imagem Docker antes. Não gaste o tempo da turma com instalação.
5. Prepare o repositório de treino conforme a seção seguinte. Faça um ensaio completo. Se quiser revisão independente, combine participação de um colega antes do encontro.

## Preparação do repositório de treino

Esta seção só é necessária para criar outro repositório do zero. Use uma **nova pasta**, fora de qualquer outro repositório. Copie os arquivos do projeto, incluindo `.github`, mas sem copiar a pasta `.git`. Crie no GitHub um repositório vazio, sem README automático. Use a URL HTTPS ou SSH exibida pelo GitHub. Para usar o repositório existente, siga o laboratório Git e pule esta seção.

Na raiz da cópia de treino, antes de corrigir a consulta:

```bash
git init -b main
git add .
git commit -m "Base didatica: consulta inicial e contrato"
```

Adicione o remoto com `git remote add origin URL_DO_SEU_REPOSITORIO` substituindo o último argumento pela URL real. Depois:

```bash
git push -u origin main
```

Faça login no GitHub antes da aula. O repositório existente e o PR de referência estão na seção Ambiente já preparado.

## Slides e condução

| Slide | Minutos decorridos | Condução |
|---|---|---|
| 1 | 00–02 | Pergunta: “Executou sem erro, então está correto?” Apresente o objetivo. |
| 2 | 02–03 | Agenda e ausência de entrega própria. |
| 3 | 03–06 | Branch, teste, commit, push, PR, revisão e merge. |
| 4 | 06–09 | Todos calculam o resultado antes de ver a consulta. |
| 5 | 09–11 | Quem desaparece no filtro? Ana e Diego ficam, Bruno e Carla saem. |
| 6 | 11–13 | Teste compara com contrato independente, incluindo bordas. |
| 7 | 13–16 | IA explica. Humano implementa e valida. |
| 8 | 16–41 | Demonstração de 25 minutos detalhada abaixo. |
| 9 | 41–43 | Retomada das evidências no repositório. |
| 10 | 43–46 | Sugestão aceita e rejeitada com justificativa e prova. |
| 11 | 46–48 | O que a pessoa revisora precisa conferir? |
| 12 | 48–53 | Discussão COUNT(*) versus COUNT(p.id). |
| 13 | 53–55 | Aplicação no desafio e perguntas. |

Até 60 minutos: use a margem para perguntas ou um atraso pequeno. Se a demonstração atrasar, reduza a discussão do slide 12 para dois minutos e use o exemplo simulado de registro, identificado como tal. Não amplie para ETL, funções avançadas ou instalação de ferramentas.

## Demonstração, minuto a minuto

### 16–19: contexto e branch

Mostre `docs/contrato.md`, as tabelas de `sql/01_base.sql` e o filtro de `sql/02_consulta.sql`. Explique as chaves e a relação de um cliente com muitos pedidos. Crie a branch:

```bash
git switch -c fix/clientes-sem-pagamento
bash demo.sh base
bash demo.sh aplicar
bash demo.sh consultar
```

Saída esperada: Ana com 2 e 150.00. Diego com 1 e 0.00. Bruno e Carla não aparecem.

### 19–22: teste que revela a falha

```bash
bash demo.sh testar
echo $?
```

Mostre o `FAIL` e o código diferente de zero. Abra o teste e explique apenas o necessário: comparação contra valores esperados, nas duas direções. Não transforme a aula em uma explicação de PL/pgSQL.

### 22–26: IA tutora

Use o primeiro prompt de `docs/prompts-tutora.md`. Leia a explicação e peça que a turma diga onde a regra está quebrando. Se a IA tentar entregar SQL pronto, peça que retorne às perguntas e à explicação conceitual. Você pode consultar o chat, mas não acionar edição automática dos arquivos.

Fala de apoio: “A condição ON decide quais pedidos combinam com o cliente. O WHERE filtra o resultado da junção. Carla fica com colunas de pedido nulas. Bruno só tem cancelado. O filtro posterior elimina ambos.”

### 26–30: correção humana

No editor, mova o filtro de status para o `ON`, unido por `AND`, e remova o `WHERE`. Mantenha as outras expressões. Execute:

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Agora existem quatro linhas e dois avisos `PASS`. Mostre que Diego tem um pedido pago de valor zero. Se necessário, compare com `solucao/02_consulta.sql`, identificando-a como referência previamente preparada pelo instrutor.

### 30–34: evidência e registro

Use o bloco de captura do README para criar `docs/evidencias.txt`. Copie o modelo:

```bash
cp docs/registro-ia-modelo.md docs/registro-ia.md
```

Preencha no editor a tarefa delegada, motivo, orientação aceita, resultado dos testes e retrabalho humano. Discuta alternativas com o terceiro prompt. Registre uma rejeição somente se ela de fato ocorrer. Se o tempo ou a resposta não permitirem, mostre `registro-ia-exemplo.md` como **simulação didática** e explique como o aluno documentará as interações reais no desafio.

### 34–41: commit e PR

```bash
git diff -- sql/02_consulta.sql
git status --short
git add sql/02_consulta.sql docs/evidencias.txt docs/registro-ia.md
git commit -m "Corrige inclusao de clientes sem pedidos pagos"
git push -u origin fix/clientes-sem-pagamento
```

No GitHub, abra o PR da branch para `main`. Título sugerido: “Inclui clientes sem pedidos pagos no relatório”. O template deve aparecer porque `.github` está na raiz do repositório. Preencha problema, alteração, comandos/saídas e registro de IA. Mostre Files changed e o resultado dos testes locais. Se o check remoto já tiver terminado, mostre-o. Se ainda estiver rodando, explique a diferença entre validação local concluída e check remoto pendente.

Pergunta de revisão: “Onde o teste garante que Carla aparece?” A resposta aponta para a linha esperada no contrato e a comparação completa do conjunto. Um colega pode comentar e pedir um esclarecimento real. Em apresentação solo, descreva a revisão com a turma sem fingir aprovação independente.

Se houver ajuste documental solicitado, edite, faça um novo commit e push na mesma branch, demonstrando a atualização do PR. Explique que o merge depende da revisão e das regras do repositório. Não é necessário realizar o merge na aula.

## Gabarito da discussão

`COUNT(*)` conta as linhas do resultado da junção, inclusive a linha que preserva Carla sem pedido. Ela teria contagem 1. `COUNT(p.id)` ignora o id nulo dessa linha e retorna 0. O pedido de Diego possui id, portanto conta 1 mesmo com valor zero. A soma sem correspondências fica nula, tratada por `COALESCE`. Apenas adicionar `COALESCE` não recupera clientes já removidos pelo `WHERE`.

## Texto para informar a abordagem à coordenação

Workshop 4, 19/11: integração de PostgreSQL ao fluxo de Pull Request com IA no degrau Tutora. Em 55 minutos, usaremos um relatório de pedidos pagos por cliente para identificar um erro de JOIN, executar teste de consulta com dados de borda, corrigir o SQL manualmente e preparar um PR com evidências e registro crítico de sugestões da IA. A prática será demonstrada com PostgreSQL em Docker, sem entregável próprio. O caso reforça as evidências da Sprint 1 exigidas no Desafio Final.

O texto acima está pronto para revisão e envio por você. Nenhuma mensagem foi enviada.

## Base e limites

Fonte de requisitos: briefing fornecido, páginas 1–4. Fontes técnicas: documentação oficial de [JOIN](https://www.postgresql.org/docs/current/tutorial-join.html), [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html) e [Pull Requests](https://docs.github.com/en/pull-requests/reference/pull-requests). O roteiro e o caso são propostas do instrutor. Não assumimos o conteúdo exato já ministrado no Workshop 3, nem um enunciado do Desafio Final que não foi fornecido.
