# Workshop 4 · Pull Request, testes SQL e decisões com IA

**19/11/2026 · 55 minutos de conteúdo e 5 de margem.** PostgreSQL, Git/GitHub e terminal, com IA no papel de **Tutora**.

Caso didático: um relatório de pedidos pagos precisa mostrar todos os clientes. A consulta executa sem erro de sintaxe, mas omite duas pessoas. Vamos identificar a causa, escrever a correção, validar o resultado e discutir um PR com evidências.

O encontro **não tem entregável próprio**. A atividade prepara as evidências da Sprint 1 do Desafio Final. O enunciado oficial do desafio prevalece sobre este exemplo. O caso, os dados e as atividades deste repositório são propostas didáticas.

## Material para cada momento

| Para usar | Arquivo |
|---|---|
| Apresentação editável com notas de fala | [PowerPoint, 13 slides](materiais/Workshop4-19nov2026-v1.pptx) |
| Cronograma de 55 minutos | [Roteiro do instrutor](materiais/roteiro-do-instrutor.md) |
| Preparação, comandos e recuperação | [Guia de condução](materiais/guia-de-conducao.md) |
| Participação da turma, sem entrega obrigatória | [Atividade de 5 minutos](docs/atividade-da-turma.md) |
| Explicação do erro e da correção | [SQL comentado](docs/sql-comentado.md) |
| Perguntas e respostas esperadas | [Gabarito do instrutor](materiais/perguntas-e-gabarito.md) |
| Branch, commit, revisão e PR | [Laboratório Git e Pull Request](docs/laboratorio-pr.md) |
| Relação com a trilha e o briefing | [Alinhamento do workshop](docs/alinhamento-do-workshop.md) |
| Diagnóstico conceitual com IA | [Prompts para tutora](docs/prompts-tutora.md) |
| Registro das próprias interações | [Modelo de registro](docs/registro-ia-modelo.md) |
| Exemplo fictício, identificado como simulação | [Registro de exemplo](docs/registro-ia-exemplo.md) |

## Estado do repositório

- `main`: consulta com erro intencional. O teste deve falhar após aplicar essa consulta.
- [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1): correção de referência na branch `fix/clientes-sem-pagamento`, mantida aberta para discussão. A execução inicial do check passou em 17/11/2026.
- `solucao/02_consulta.sql`: gabarito previamente preparado pelo instrutor.
- `exemplos/`: consultas de apoio. Não substituem o código em `sql/02_consulta.sql`.

O repositório é privado. Alunos precisam de acesso para clonar, consultar o PR ou abrir alterações. Sem esse acesso, o instrutor pode demonstrar pela própria tela ou compartilhar uma cópia autorizada do kit. Não há necessidade de acesso individual para a discussão em aula.

## Primeiro uso

Requisitos locais: **Docker Desktop em execução, Git, editor e Bash**. Windows: Git Bash ou WSL com integração do Docker. Não é necessário instalar PostgreSQL, psql ou Python no computador.

```bash
git clone https://github.com/pedropalmieri/workshop4-pr-sql-ia.git
cd workshop4-pr-sql-ia
bash demo.sh subir
bash demo.sh base
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Na `main`, aparecem **Ana e Diego**, e o teste retorna `FAIL` com código 3. É o erro que a aula vai investigar. Leia o [contrato calculado manualmente](docs/contrato.md) antes de consultar o gabarito.

O banco usa `postgres:17.12-alpine`, sem porta publicada. Os dados são fictícios e descartáveis. A primeira execução precisa de internet para baixar a imagem. Se o contêiner parar, recarregue a base e reaplique a consulta.

## Comandos da apresentação

Todos os comandos partem da raiz do repositório.

| Comando | O que faz |
|---|---|
| `bash demo.sh subir` | Inicia o PostgreSQL e aguarda disponibilidade |
| `bash demo.sh base` | Recarrega os quatro clientes e cinco pedidos |
| `bash demo.sh aplicar` | Aplica a consulta do arquivo que você está editando |
| `bash demo.sh consultar` | Mostra o relatório ordenado por cliente |
| `bash demo.sh definicao` | Mostra o SQL da view realmente aplicada no banco |
| `bash demo.sh testar` | Valida o contrato e um segundo cenário |
| `bash demo.sh diagnosticar` | Mostra as linhas antes do filtro e com status no ON |
| `bash demo.sh contagem` | Compara COUNT(*) e COUNT(p.id), soma e COALESCE |
| `bash demo.sh inicio` | Aplica o erro congelado de exemplos/, sem editar arquivos |
| `bash demo.sh referencia` | Aplica o gabarito de solucao/, sem editar arquivos |
| `bash demo.sh encerrar` | Remove somente os recursos Docker do projeto da aula |

`inicio` e `referencia` servem para ensaio e recuperação. Na demonstração principal, o humano edita `sql/02_consulta.sql` e usa **aplicar**. Aplicar o gabarito no banco não altera o arquivo a ser enviado no commit.

## Ensaio antes do encontro

```bash
bash scripts/ensaio.sh
```

O ensaio usa outro projeto Docker, `ws4-ensaio`. Verifica o erro conhecido, executa os exemplos, aplica a referência e exige aprovação nos testes. Ao terminar, remove esse ambiente separado. Não altera os arquivos nem o banco `ws4-workshop` da aula.

## Evidência da sua execução

Depois de aplicar a consulta que pretende revisar:

```bash
bash scripts/registrar-evidencia.sh
```

O comando cria um arquivo com data, commit, arquivos SQL modificados, definição efetiva da view no banco e saída da consulta e dos testes. Não sobrescreve evidências existentes. Se o teste falhar, o comando também retorna falha. O commit informa a base Git, e o status mostra alterações locais ainda não incluídas nele. A definição registrada permite conferir o que estava aplicado, inclusive quando você usou o gabarito de recuperação.

Copie `docs/registro-ia-modelo.md` para `docs/registro-ia.md` e registre as interações reais. A IA explica conceitos e faz perguntas. Você implementa, executa e decide, justificando ao menos uma sugestão aceita e uma rejeitada. Nunca apresente o exemplo fictício como conversa real.

## Encerramento e problemas comuns

```bash
bash demo.sh encerrar
```

- Docker não conecta: abra o Docker Desktop e confira `docker info`.
- Banco reiniciou: execute `base` e `aplicar` novamente.
- Não aparecem os quatro clientes: confira o filtro no `ON` e compare com o contrato.
- A view continua corrigida mesmo na `main`: trocar de branch muda arquivos, não o banco. Execute `aplicar`.
- Script não executa no PowerShell: use Git Bash ou WSL. Os comandos deste kit são Bash.
- IA ou internet indisponível: use a análise dos dados e o [plano de recuperação](materiais/guia-de-conducao.md). Identifique exemplos simulados.

## Referências técnicas

[JOIN no PostgreSQL](https://www.postgresql.org/docs/current/tutorial-join.html), [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html) e [Pull Requests no GitHub](https://docs.github.com/en/pull-requests/reference/pull-requests). Os requisitos pedagógicos vêm do briefing do Workshop 4 fornecido pelo instrutor, sem inclusão do documento original neste repositório.
