# Workshop 4 · PostgreSQL, testes e Pull Request

**19 de novembro de 2026 · AI-Driven Data Engineering**

Como verificar se uma consulta atende ao requisito, além de executar sem erros? Neste workshop, usamos um relatório de clientes e pedidos para investigar o resultado, testar uma correção e revisar a alteração em um Pull Request.

## Caso: relatório de pedidos pagos

O relatório precisa incluir **todos os clientes**, contar apenas pedidos pagos e mostrar zero quando não houver pagamento. O conjunto de dados inclui clientes sem pedidos, pedidos cancelados e um pedido pago de valor zero.

O [contrato da consulta](docs/contrato.md) define o resultado esperado. A implementação inicial contém um problema de filtragem que será analisado ao longo da atividade.

## Conteúdo

| Tema | Material |
|---|---|
| Apresentação | [Slides](materiais/Workshop4-19nov2026.pptx) |
| Ambiente e acesso ao banco | [Conexão PostgreSQL](docs/conexao-postgresql.md) |
| SELECT, filtros, JOIN e agregações | [Consultas passo a passo](docs/consultas-passo-a-passo.md) |
| Análise do problema e da solução | [SQL comentado](docs/sql-comentado.md) |
| Validação e revisão | [Laboratório de Pull Request](docs/laboratorio-pr.md) |
| Discussão em grupo | [Questões sobre a consulta](docs/atividade-da-turma.md) |
| IA como tutora | [Perguntas para diagnóstico](docs/prompts-tutora.md) |
| Registro de decisões | [Modelo](docs/registro-ia-modelo.md) e [exemplo ilustrativo](docs/registro-ia-exemplo.md) |

## Ambiente

Requisitos: Docker Desktop em execução, Git, editor de texto e Bash. No Windows, use Git Bash ou WSL com integração do Docker. PostgreSQL e o cliente psql executam no contêiner, sem instalação local adicional.

```bash
git clone https://github.com/pedropalmieri/workshop4-pr-sql-ia.git
cd workshop4-pr-sql-ia
bash demo.sh subir
bash demo.sh conexao
bash demo.sh base
```

A conexão usa TCP e autenticação por senha no ambiente Docker. Os dados são fictícios e descartáveis. Nenhuma porta está publicada no computador. O repositório é privado e o clone exige acesso à conta.

## Exploração das consultas

Para abrir o terminal SQL:

```bash
bash demo.sh terminal
```

Execute os blocos de [consultas-passo-a-passo.sql](exemplos/consultas-passo-a-passo.sql) individualmente. Para executar a sequência completa:

```bash
bash demo.sh passos
```

A sequência apresenta seleção de colunas, filtro, INNER JOIN, LEFT JOIN, agrupamento, contagem, soma e tratamento de valores nulos.

## Consulta inicial e testes

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Na `main`, o teste deve falhar: a consulta inicial omite clientes exigidos pelo contrato. Depois da correção, os dois cenários de teste devem passar. A [solução de referência](solucao/02_consulta.sql) e o [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) permitem comparar a alteração e suas evidências.

| Comando | Finalidade |
|---|---|
| `bash demo.sh conexao` | Mostrar conexão, banco, usuário, porta e versão |
| `bash demo.sh diagnosticar` | Comparar as linhas produzidas pela junção |
| `bash demo.sh contagem` | Comparar COUNT(*), COUNT(p.id), SUM e COALESCE |
| `bash demo.sh definicao` | Consultar a definição da view aplicada no banco |
| `bash demo.sh inicio` | Aplicar a versão inicial armazenada em exemplos/ |
| `bash demo.sh referencia` | Aplicar a solução de referência no banco |

Os comandos `inicio` e `referencia` alteram a view no banco, sem modificar o arquivo SQL versionado. O comando `aplicar` usa o conteúdo atual de `sql/02_consulta.sql`.

## Validação do ambiente

```bash
bash scripts/validar-ambiente.sh
```

A validação usa um banco separado. Confere conexão, rejeição de senha incorreta, consultas e testes. O ambiente separado é removido ao terminar. As [saídas da validação](docs/validacao/conexao-e-consultas-20261117.txt) incluem as falhas negativas esperadas e a aprovação final.

Para registrar uma execução própria:

```bash
bash scripts/registrar-evidencia.sh
```

O arquivo gerado inclui commit, alterações locais, definição efetiva da view e resultados. Uma falha no teste continua sendo uma falha no comando.

## Uso da IA

Neste encontro, a IA atua como **Tutora**: explica conceitos e ajuda a investigar o problema. A implementação, a execução e a validação ficam com a pessoa que está desenvolvendo.

Registre tarefa delegada, motivo, orientação recebida, decisão, evidência e retrabalho. Use o modelo para suas interações reais. O exemplo disponível é fictício e está identificado como ilustração.

## Participação e continuidade

A discussão não exige entrega própria. O conteúdo apoia as evidências de SQL, testes e revisão da Sprint 1. Para os requisitos de entrega, siga o enunciado oficial do Desafio Final.

Para encerrar o banco local:

```bash
bash demo.sh encerrar
```

## Referências

[JOIN no PostgreSQL](https://www.postgresql.org/docs/current/tutorial-join.html), [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html) e [Pull Requests no GitHub](https://docs.github.com/en/pull-requests/reference/pull-requests).
