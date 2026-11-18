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

A sequência atual reserva 18 dos 25 minutos de demonstração para conexão, leitura do SQL, diagnóstico e correção. Use a tabela no [guia de condução](guia-de-conducao.md) e as falas em [explicação das consultas](explicacao-das-consultas.md). Os 2 minutos seguintes cobrem evidências e os 5 finais cobrem o PR.

Antes de compartilhar a tela, valide `bash demo.sh conexao`. Para executar uma consulta por vez, use `bash demo.sh terminal`. Os seis blocos de `exemplos/consultas-passo-a-passo.sql` explicam SELECT, FROM, WHERE, chaves e JOINs, GROUP BY, COUNT, SUM e COALESCE. Não é necessário ensinar os detalhes do bloco DO dos testes durante a hora.

Os comandos de branch, commit, push e revisão estão no [laboratório Git](../docs/laboratorio-pr.md). O exemplo de registro da IA continua identificado como simulação, sem substituir as interações reais.

## Gabarito da discussão

`COUNT(*)` conta as linhas do resultado da junção, inclusive a linha que preserva Carla sem pedido. Ela teria contagem 1. `COUNT(p.id)` ignora o id nulo dessa linha e retorna 0. O pedido de Diego possui id, portanto conta 1 mesmo com valor zero. A soma sem correspondências fica nula, tratada por `COALESCE`. Apenas adicionar `COALESCE` não recupera clientes já removidos pelo `WHERE`.

## Texto para informar a abordagem à coordenação

Workshop 4, 19/11: integração de PostgreSQL ao fluxo de Pull Request com IA no degrau Tutora. Em 55 minutos, usaremos um relatório de pedidos pagos por cliente para identificar um erro de JOIN, executar teste de consulta com dados de borda, corrigir o SQL manualmente e preparar um PR com evidências e registro crítico de sugestões da IA. A prática será demonstrada com PostgreSQL em Docker, sem entregável próprio. O caso reforça as evidências da Sprint 1 exigidas no Desafio Final.

O texto acima está pronto para revisão e envio por você. Nenhuma mensagem foi enviada.

## Base e limites

Fonte de requisitos: briefing fornecido, páginas 1–4. Fontes técnicas: documentação oficial de [JOIN](https://www.postgresql.org/docs/current/tutorial-join.html), [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html) e [Pull Requests](https://docs.github.com/en/pull-requests/reference/pull-requests). O roteiro e o caso são propostas do instrutor. Não assumimos o conteúdo exato já ministrado no Workshop 3, nem um enunciado do Desafio Final que não foi fornecido.
