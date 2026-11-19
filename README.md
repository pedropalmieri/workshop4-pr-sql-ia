# Workshop 4 · PostgreSQL, testes e Pull Request

**19 de novembro de 2026 · AI-Driven Data Engineering**

Como verificar se uma consulta atende ao requisito, além de executar sem erros? Neste workshop, usamos um relatório de clientes e pedidos para investigar o resultado, testar uma correção e revisar a alteração em um Pull Request.

## Caso: relatório de pedidos pagos

O relatório precisa incluir **todos os clientes**, contar apenas pedidos pagos e mostrar zero quando não houver pagamento. O conjunto de dados inclui clientes sem pedidos, pedidos cancelados e um pedido pago de valor zero.

O [contrato da consulta](docs/contrato.md) define o resultado esperado. A versão inicial, preservada em `exemplos/consulta-com-erro.sql`, contém o problema de filtragem. O [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) registra a correção, e o [PR nº 2](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/2) registra o retorno ao estado inicial, preservando o histórico. O arquivo `sql/estado-demonstracao.txt` identifica o estado atual: `inicial` reproduz o defeito conhecido, e `corrigido` exige aprovação no contrato. Quando o arquivo não existe, vale `corrigido`.

## Conteúdo

| Tema | Material |
|---|---|
| Caso completo, com enunciado, perguntas e resolução | [Estudo de caso passo a passo](docs/estudo-de-caso.md) |
| Apresentação | [Slides](materiais/Workshop4-19nov2026.pptx) |
| Interface gráfica e instalação Docker | [pgAdmin](docs/pgadmin.md) |
| Ambiente e acesso ao banco | [Conexão PostgreSQL](docs/conexao-postgresql.md) |
| Respostas às questões dos slides, com SQL para pgAdmin | [Mapa das questões e arquivo comentado](docs/respostas-questoes-slides.md) |
| Consultas com objetivo, explicação e resultado esperado | [Consultas explicadas](docs/consultas-explicadas.md) |
| Como e por que a automação foi criada | [Arquitetura e decisões](docs/arquitetura-automacao.md) |
| SELECT, filtros, JOIN e agregações | [Consultas passo a passo](docs/consultas-passo-a-passo.md) |
| Exemplos numerados para executar no pgAdmin | [Sequência de demonstração](exemplos/demonstracao/README.md) |
| Análise do problema e da solução | [SQL comentado](docs/sql-comentado.md) |
| Aplicação da main no banco após o merge | [Fluxo de aplicação e consulta do resultado](docs/aplicacao-main.md) |
| Onde editar o SQL e como abrir o PR, etapa por etapa | [Da consulta ao Pull Request](docs/laboratorio-pr.md) |
| Discussão em grupo | [Questões sobre a consulta](docs/atividade-da-turma.md) |
| IA como tutora: prompts para qualquer assistente | [Contexto único e prompts curtos](prompts/README.md) e [guia de uso](docs/prompts-tutora.md) |
| Ferramenta e momento de uso da IA | [Orientações de uso da IA](docs/uso-da-ia.md) |
| Revisão SQL pelo Copilot: contexto e disponibilidade | [Configuração preparada e limitações do plano](docs/revisao-copilot.md) |
| Registro de decisões | [Modelo](docs/registro-ia-modelo.md) e [exemplo ilustrativo](docs/registro-ia-exemplo.md) |

## Operações SQL do caso

O trabalho relaciona uma consulta `SELECT`, seus testes e a revisão por Pull Request. A IA atua como Tutora, e o Fellow implementa, executa e registra a validação.

- **Consulta e PR:** a alteração está na lógica de leitura do relatório, no arquivo `sql/02_consulta.sql`. Ela muda o resultado calculado, preservando os registros de clientes e pedidos.
- **Preparação da base:** `sql/01_base.sql` cria e carrega os dados fictícios do exercício. A carga estabelece os quatro clientes e os cinco pedidos usados no contrato.
- **UPDATE no teste:** `sql/03_testes.sql` cancela temporariamente os pedidos para verificar o cenário sem pagamentos. O `ROLLBACK` desfaz a alteração e mantém os dados originais.
- **Exclusão de dados:** a análise do relatório não usa `DELETE`.

## Instalação com Docker: PostgreSQL e pgAdmin

Requisitos: Docker Desktop em execução, navegador, Git, editor de texto e Bash. No Windows, use Git Bash ou WSL com integração do Docker. PostgreSQL, pgAdmin e psql executam em contêineres, sem instalação desses aplicativos no computador.

Para clonar o repositório e iniciar os dois serviços:

```bash
git clone https://github.com/pedropalmieri/workshop4-pr-sql-ia.git
cd workshop4-pr-sql-ia
docker compose -p ws4-workshop --profile interface pull db pgadmin
docker compose -p ws4-workshop --profile interface up -d --wait
bash demo.sh base
bash demo.sh aplicar
```

Imagens: **postgres:17.12-alpine** e **dpage/pgadmin4:9.19**. O atalho `bash demo.sh interface` executa a inicialização via Compose. A opção `--wait` aguarda os serviços ficarem disponíveis. Um PostgreSQL já iniciado no projeto ws4-workshop é reutilizado.

O comando `base` reinicializa os dados do exercício. Execute os comandos de carga na preparação do ambiente.

Para conferir instalação e conexão:

```bash
docker compose -p ws4-workshop --profile interface ps
bash demo.sh conexao
bash scripts/validar-interface.sh
```

## Consultas pela interface gráfica

Abra **http://localhost:5050**.

| Login do pgAdmin | Valor didático |
|---|---|
| E-mail | workshop@example.com |
| Senha | pgadmin_local |

O servidor **Workshop 4 - PostgreSQL** já vem cadastrado com a conexão ao banco. Expanda **Workshop 4 > Workshop 4 - PostgreSQL > Bancos de dados > workshop** e abra **Ferramentas > Ferramenta de consulta** (Query Tool).

Use os blocos de [consultas-pgadmin.sql](exemplos/consultas-pgadmin.sql), um SELECT por vez. O resultado aparece em Data Output. O guia [pgAdmin](docs/pgadmin.md) detalha a navegação, credenciais e solução de problemas.

Para acompanhar cada conceito em um arquivo separado, use a [sequência numerada](exemplos/demonstracao/README.md): conexão, dados, filtros, JOINs, agregações e validação. Cada arquivo informa seu objetivo e o resultado esperado.

O PostgreSQL é acessado pelo pgAdmin em **db:5432**, banco **workshop**, schema **ws4**. Somente a interface é publicada no computador em 127.0.0.1:5050. Os dados são fictícios e descartáveis. O repositório é privado e o clone exige acesso.

## Terminal e testes

A interface gráfica é o caminho principal para explorar SQL. O psql continua disponível para testes e automação:

```bash
bash demo.sh terminal
# Ou, para executar a sequência psql completa:
bash demo.sh passos
```

O arquivo `exemplos/consultas-passo-a-passo.sql` contém metacomandos psql, como comandos de barra invertida. Para o pgAdmin, utilize a versão SQL pura `exemplos/consultas-pgadmin.sql`.

## Consulta inicial, correção e testes

Para reproduzir a falha sem modificar o arquivo versionado:

```bash
bash demo.sh inicio
bash demo.sh consultar
bash demo.sh testar
```

O comando `inicio` aplica a versão com erro. O teste deve indicar `FAIL: resultado diferente do contrato`, com código de saída 3. Falhas de conexão ou de execução não representam a reprodução desse defeito.

Execute `bash demo.sh aplicar` para usar o SQL versionado. No estado `inicial`, `bash demo.sh testar` continua falhando por não atender ao contrato. `bash scripts/testar-estado.sh` verifica a reprodução desse estado e confirma a falha conhecida. No estado `corrigido`, exige os dois cenários do contrato. A [solução de referência](solucao/02_consulta.sql) e o [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) permitem comparar a alteração e suas evidências.

| Comando | Finalidade |
|---|---|
| `bash demo.sh interface` | Iniciar PostgreSQL e pgAdmin para uso no navegador |
| `bash demo.sh aplicar` | Aplicar o SQL versionado ao banco |
| `bash demo.sh consultar` | Exibir o relatório aplicado |
| `bash demo.sh testar` | Verificar o contrato de negócio |
| `bash scripts/testar-estado.sh` | Validar o estado declarado do exercício |
| `bash demo.sh conexao` | Mostrar conexão, banco, usuário, porta e versão |
| `bash demo.sh estrutura` | Listar o schema, objetos e campos do exercício |
| `bash demo.sh diagnosticar` | Comparar as linhas produzidas pela junção |
| `bash demo.sh contagem` | Comparar COUNT(*), COUNT(p.id), SUM e COALESCE |
| `bash demo.sh definicao` | Consultar o SQL aplicado ao relatório |
| `bash demo.sh inicio` | Aplicar a versão inicial armazenada em exemplos/ |
| `bash demo.sh referencia` | Aplicar a solução de referência no banco |

Os comandos `inicio` e `referencia` aplicam versões do relatório no banco, sem modificar o arquivo SQL versionado. O comando `aplicar` usa o conteúdo atual de `sql/02_consulta.sql`. Executar uma alteração no Query Tool não salva automaticamente esse arquivo no Git. Mantenha a correção também no arquivo para incluí-la no PR.

## Validação do ambiente

```bash
bash scripts/validar-ambiente.sh
```

A validação de SQL usa um banco separado, sem iniciar outro pgAdmin. Confere conexão, rejeição de senha incorreta, consultas e testes. O ambiente separado é removido ao terminar. As [saídas da validação](docs/validacao/conexao-e-consultas-20261118.txt) incluem as falhas negativas esperadas e a aprovação final.

Para registrar uma execução própria:

```bash
bash scripts/registrar-evidencia.sh
```

O arquivo gerado inclui commit, alterações locais, SQL efetivamente aplicado e resultados. Uma falha no teste continua sendo uma falha no comando.

## Aplicação após o merge

O workflow **Testes SQL** valida o PR em um banco temporário. Após o merge de um PR destinado à `main` com alteração em `sql/`, **Aplicar main no banco de demonstracao** aplica e testa a consulta no PostgreSQL do laboratório, mantendo o banco disponível no pgAdmin. A aplicação só confirma a mudança se os testes do estado declarado passarem. O retorno ao estado `inicial` é explícito e não significa aprovação da regra de negócio. Aprovar o PR, por si só, não aplica o SQL: é necessário fazer o merge. O acionamento manual está disponível na `main`. Um push direto ou uma mudança apenas em documentação não dispara essa aplicação. Veja [o fluxo completo e a consulta do commit aplicado](docs/aplicacao-main.md).

## Uso da IA

Use o **ChatGPT ou outro assistente de linguagem como Tutora**, em conversa de texto, após observar o resultado da consulta e do teste. A IA explica conceitos e ajuda a investigar o filtro a partir do contexto enviado, sem acesso ao banco. A implementação, a execução e a validação ficam com a pessoa que está desenvolvendo. Veja [qual IA usar e em que momento](docs/uso-da-ia.md).

Registre tarefa delegada, motivo, orientação recebida, decisão, evidência e retrabalho. Use o modelo para suas interações reais. O exemplo disponível é fictício e está identificado como ilustração.

## Participação e continuidade

A discussão não exige entrega própria. O conteúdo apoia as evidências de SQL, testes e revisão da Sprint 1. Para os requisitos de entrega, siga o enunciado oficial do Desafio Final.

Para encerrar o banco local:

```bash
docker compose -p ws4-workshop --profile interface down
# Equivalente: bash demo.sh encerrar
```

O volume de configuração do pgAdmin permanece. Os dados do PostgreSQL ficam em armazenamento temporário. Após encerrar ou recriar seu contêiner, execute `bash demo.sh base` e `bash demo.sh aplicar` para preparar novamente o exercício.

## Referências

[JOIN no PostgreSQL](https://www.postgresql.org/docs/current/tutorial-join.html), [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html) e [Pull Requests no GitHub](https://docs.github.com/en/pull-requests/reference/pull-requests).
