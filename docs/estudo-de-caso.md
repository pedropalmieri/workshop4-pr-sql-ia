# Estudo de caso: o relatório que deixou clientes de fora

Uma questão guiada sobre PostgreSQL, testes de consulta, revisão por Pull Request e uso da IA como Tutora. Todos os dados são fictícios. O caso apoia o Workshop 4; os requisitos oficiais do Desafio Final são definidos em seu enunciado.

## Enunciado

Você recebeu a tarefa de revisar um relatório de pagamentos por cliente. O banco possui um cadastro de clientes e uma tabela de pedidos. Alguns clientes têm pedidos pagos, outros têm apenas cancelamentos e um cliente ainda não fez pedidos.

O relatório deve permitir responder: **quem são os clientes cadastrados, quantos pedidos pagos cada um possui e quanto cada um pagou?** Ele precisa manter visíveis também os clientes sem pagamentos.

Uma consulta já foi escrita. Ela executa sem erro, mas retorna somente dois dos quatro clientes cadastrados. Sua tarefa é investigar o resultado, explicar a divergência, corrigir a lógica e demonstrar a correção com testes e um PR revisável.

**Questão central:** como contar e somar apenas os pedidos pagos sem excluir clientes que não possuem pagamentos?

## 1. Qual é o objetivo do relatório?

Produzir um resumo de pagamentos com **uma linha por cliente**. Em vez de mostrar cada pedido individual, o relatório reúne a quantidade de pedidos pagos e a soma de seus valores.

As regras são:

1. Todos os clientes cadastrados aparecem.
2. Somente pedidos com status `pago` entram na contagem e na soma.
3. Pedidos cancelados ficam fora dos cálculos.
4. Sem pedido pago, a quantidade e o total são zero.
5. Um pedido pago de valor zero continua contando como um pedido válido.

Essas regras formam o **contrato da consulta**: a expectativa usada para decidir se o resultado está correto. Um relatório que omite clientes não atende ao objetivo, mesmo que os totais das linhas restantes estejam certos.

## 2. O que precisamos fazer?

- Ler as tabelas e calcular manualmente o resultado esperado.
- Executar a consulta inicial e comparar sua saída com o contrato.
- Identificar em qual condição os clientes desaparecem.
- Ajustar a consulta preservando os dados e as regras do relatório.
- Conferir os resultados e os testes.
- Registrar a alteração, a evidência e as decisões com IA no fluxo de PR.

A análise é da consulta de leitura. Não é necessário excluir clientes, mudar pedidos nem criar novas tabelas para resolver o problema.

## 3. Quais tabelas existem e o que cada coluna representa?

Os dados estão no banco `workshop`, organizados no schema `ws4`. O schema identifica o conjunto de objetos usado neste exercício: por exemplo, `ws4.clientes`.

### Tabela `ws4.clientes`

Representa o cadastro. Cada linha é um cliente.

| Coluna | Tipo | Significado e regra |
|---|---|---|
| `id` | integer | Identificador único do cliente, chave primária. Não se repete e não aceita NULL. |
| `nome` | text | Nome exibido no relatório. É obrigatório. |

### Tabela `ws4.pedidos`

Representa os pedidos. Cada linha é um pedido de um cliente.

| Coluna | Tipo | Significado e regra |
|---|---|---|
| `id` | integer | Identificador único do pedido, chave primária. |
| `cliente_id` | integer | Cliente ao qual o pedido pertence. É obrigatório e referencia `clientes.id`. |
| `status` | text | Situação do pedido: `pago` ou `cancelado`. É obrigatória. |
| `valor` | numeric(12,2) | Valor do pedido, com duas casas decimais. É obrigatório e não pode ser negativo. |

`cliente_id` é uma **chave estrangeira**: impede que um pedido referencie um cliente inexistente. Essa regra não obriga um cliente a ter pedidos.

## 4. Quais são todos os dados disponíveis?

### Clientes

| id | nome |
|---|---|
| 1 | Ana |
| 2 | Bruno |
| 3 | Carla |
| 4 | Diego |

### Pedidos

| id | cliente_id | status | valor |
|---|---|---|---|
| 101 | 1 | pago | 100.00 |
| 102 | 1 | pago | 50.00 |
| 103 | 1 | cancelado | 900.00 |
| 104 | 2 | cancelado | 80.00 |
| 105 | 4 | pago | 0.00 |

Para conferir no Query Tool do pgAdmin, execute cada SELECT separadamente:

```sql
SELECT id, nome
FROM ws4.clientes
ORDER BY id;
```

```sql
SELECT id, cliente_id, status, valor
FROM ws4.pedidos
ORDER BY id;
```

`SELECT` escolhe as colunas, `FROM` indica a tabela e `ORDER BY` organiza a exibição. Esses comandos não alteram os dados.

## 5. Como as tabelas se relacionam?

Um cliente pode ter **zero, um ou vários pedidos**. Cada pedido pertence a **um cliente**. É uma relação de um para muitos, identificada por `pedidos.cliente_id = clientes.id`.

| Cliente | Relação com os pedidos | O que precisamos preservar |
|---|---|---|
| Ana | Pedidos 101, 102 e 103 | Contar e somar os dois pagos, excluindo o cancelado. |
| Bruno | Pedido 104 | Mantê-lo no relatório, mesmo tendo somente cancelamento. |
| Carla | Nenhum pedido | Mantê-la no relatório, mesmo sem correspondência em pedidos. |
| Diego | Pedido 105 | Contar o pagamento válido de valor zero. |

**Pergunta:** Carla tem algum registro errado por não possuir pedidos?  
**Resposta:** não. Ela existe no cadastro, e a relação permite clientes sem pedidos. A consulta precisa respeitar essa situação.

## 6. Qual resultado devemos esperar, antes de olhar o SQL?

| id | nome | pedidos_pagos | total_pago | Justificativa |
|---|---|---|---|---|
| 1 | Ana | 2 | 150.00 | Dois pagos: 100 + 50. O cancelado de 900 não participa. |
| 2 | Bruno | 0 | 0.00 | Seu único pedido está cancelado. |
| 3 | Carla | 0 | 0.00 | Não possui pedidos. |
| 4 | Diego | 1 | 0.00 | Possui um pedido pago, cujo valor é zero. |

Esse cálculo vem dos dados e do requisito, não da implementação. Assim, o teste pode detectar um erro na própria consulta.

## 7. Qual consulta recebemos para analisar?

```sql
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
```

`c` e `p` são aliases: nomes curtos das tabelas usados para identificar a origem das colunas. `AS` nomeia as colunas calculadas do relatório.

### Pergunta: qual resultado essa consulta produz?

| id | nome | pedidos_pagos | total_pago |
|---|---|---|---|
| 1 | Ana | 2 | 150.00 |
| 4 | Diego | 1 | 0.00 |

### Pergunta: ela está correta por ter executado sem erro?

**Resposta:** não. A sintaxe é válida, mas Bruno e Carla estão ausentes. O contrato exige os quatro clientes. A falha está no comportamento do relatório.

## 8. Onde Bruno e Carla desaparecem?

Primeiro, observe a junção sem aplicar o filtro de status:

```sql
SELECT c.id AS cliente_id, c.nome,
       p.id AS pedido_id, p.status, p.valor
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
ORDER BY c.id, p.id;
```

| cliente_id | nome | pedido_id | status | valor |
|---|---|---|---|---|
| 1 | Ana | 101 | pago | 100.00 |
| 1 | Ana | 102 | pago | 50.00 |
| 1 | Ana | 103 | cancelado | 900.00 |
| 2 | Bruno | 104 | cancelado | 80.00 |
| 3 | Carla | NULL | NULL | NULL |
| 4 | Diego | 105 | pago | 0.00 |

O `LEFT JOIN` preserva o cliente da tabela à esquerda quando não encontra pedido. Por isso, Carla aparece com as colunas de pedido nulas. Ela não ganhou um pedido: essa linha representa a ausência de correspondência.

Depois da junção, a condição `WHERE p.status = 'pago'` mantém somente as linhas em que a comparação é verdadeira:

- Os dois pagos de Ana permanecem; seu cancelamento sai.
- Bruno sai porque seu pedido é cancelado.
- Carla sai porque comparar NULL com `pago` não resulta em verdadeiro.
- Diego permanece porque seu pedido está pago, mesmo com valor zero.

**Pergunta:** por que o LEFT JOIN não foi suficiente?  
**Resposta:** ele preservou os clientes na junção, mas o filtro posterior removeu linhas que o relatório precisava manter.

## 9. Como corrigir a lógica sem alterar os dados?

A condição de status deve selecionar os pedidos que correspondem ao cliente durante a junção. O cliente precisa permanecer mesmo quando nenhum pedido pago atende à condição.

```sql
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;
```

Agora, o `ON` exige que o pedido pertença ao cliente e esteja pago. O `LEFT JOIN` mantém o cliente sem pedido pago correspondente. O resultado passa a ser o da seção 6, com os quatro clientes.

**O que mudou:** a posição da condição de status na lógica da consulta.  
**O que permanece:** o cadastro, os cinco pedidos e todas as regras do relatório.

Executar esse SELECT no pgAdmin calcula o resultado, mas não modifica automaticamente o arquivo no Git nem a implementação usada pela automação.

## 10. Para que servem GROUP BY, COUNT, SUM e COALESCE?

| Expressão | Função neste relatório |
|---|---|
| `GROUP BY c.id, c.nome` | Reúne as linhas de cada cliente para calcular seu resumo. O id mantém a identidade do cliente. |
| `COUNT(p.id)` | Conta os identificadores de pedidos encontrados. Ignora valores nulos. |
| `SUM(p.valor)` | Soma os valores dos pedidos pagos. Sem valores não nulos, retorna NULL. |
| `COALESCE(SUM(p.valor), 0)` | Usa a soma quando ela existe e apresenta zero quando a soma é nula. |
| `::numeric(12,2)` | Define o tipo do total, com duas casas decimais. |

### Pergunta: poderíamos usar COUNT(*) no lugar de COUNT(p.id)?

Para contar pedidos neste caso, isso produziria valores incorretos. No JOIN corrigido, Bruno e Carla têm uma linha preservada, mas nenhum `p.id` preenchido. `COUNT(*)` contaria essa linha como 1; `COUNT(p.id)` retorna zero.

### Pergunta: Diego também deveria ter contagem zero?

Não. Seu pedido 105 existe e está pago. O id está preenchido, então a contagem é 1. O valor zero afeta a soma, não a existência do pedido.

### Pergunta: excluir os clientes com total zero simplificaria o relatório corretamente?

Não. A exclusão removeria Bruno, Carla e Diego, violando a regra de incluir todos. Diego ainda demonstra que um total zero pode corresponder a um pagamento válido.

## 11. Como comprovar que a solução está correta?

Confira a implementação efetivamente aplicada ao banco:

```sql
SELECT id, nome, pedidos_pagos, total_pago
FROM ws4.resumo_clientes
ORDER BY id;
```

No estado inicial, esse comando mostra Ana e Diego. No estado corrigido, mostra os quatro clientes. Sua saída depende da versão aplicada, não do último SELECT isolado executado no Query Tool.

O arquivo [sql/03_testes.sql](../sql/03_testes.sql) verifica dois cenários:

1. **Base original:** compara os quatro resultados esperados com a implementação. A comparação com `EXCEPT ALL`, nas duas direções, detecta linhas ausentes, extras, duplicadas e valores diferentes.
2. **Sem pagamentos:** prepara temporariamente todos os pedidos como cancelados e exige quatro clientes com quantidade e total zero. O `ROLLBACK` desfaz essa preparação.

**Pergunta:** basta contar quatro linhas?  
**Resposta:** não. A consulta poderia ter quatro linhas e valores errados. O teste precisa verificar também a identidade dos clientes, as contagens e os totais.

**Pergunta:** qual evidência garante que Carla aparece?  
**Resposta:** sua linha esperada, com id 3, quantidade zero e total zero, participa da comparação completa. Se faltar, o teste encontra uma diferença. As [consultas de respostas](../exemplos/respostas-questoes-slides.sql), Q10 e Q11, permitem examinar essa verificação no pgAdmin.

No terminal, com o banco preparado:

```bash
bash demo.sh consultar
bash demo.sh testar
```

A versão inicial deve falhar no contrato. A corrigida deve passar nos dois cenários. O modo `inicial` da automação apenas confirma a reprodução do defeito conhecido; ele não significa aprovação do contrato de negócio.

## 12. Como usar a IA sem delegar a solução inteira?

Envie o [contexto do caso](../prompts/00-contexto-do-caso.txt) uma vez e, depois, o [prompt de diagnóstico](../prompts/01-diagnosticar-consulta.txt) com a consulta inicial. Peça uma explicação da perda de clientes e perguntas que orientem sua investigação.

A IA atua como Tutora. O Fellow interpreta a resposta, implementa a mudança e confere o resultado no PostgreSQL. Uma resposta convincente não comprova que o teste passou.

Registre a tarefa delegada, o motivo da ajuda, a orientação realmente recebida, sua decisão e a validação. Uma sugestão aceita precisa de evidência, assim como uma rejeitada. Não invente interações para preencher o [registro](registro-ia-modelo.md).

## 13. Como levar a correção ao Pull Request e ao banco?

1. Altere a lógica de leitura em `sql/02_consulta.sql`, preservando a estrutura do arquivo.
2. Declare `corrigido` em `sql/estado-demonstracao.txt` no mesmo PR.
3. Aplique o arquivo e confira os resultados e os testes:

   ```bash
   bash demo.sh aplicar
   bash demo.sh consultar
   bash demo.sh testar
   ```

4. Registre a evidência e as decisões reais com IA. Examine o diff e envie os commits da branch.
5. Abra o PR para a `main`. Explique o requisito, a causa da falha, a alteração e a validação. Os checks verificam a proposta em um banco temporário.
6. Após revisão e merge de um PR com alteração em `sql/`, o workflow do laboratório aplica o commit no banco de demonstração. A aplicação só confirma a mudança se os testes do estado declarado passarem; uma falha desfaz a tentativa.
7. Execute novamente o SELECT da seção 11 no pgAdmin e confira o log do workflow. Aprovar o PR, sem fazer o merge, não executa o SQL no banco.

Os [PRs nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) e [nº 2](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/2) preservam a correção e o retorno inicial. O [guia de aplicação](aplicacao-main.md) explica os estados, a execução e a rastreabilidade.

## Questão de revisão: como você explicaria a solução?

**Pergunta:** “O relatório retornava apenas Ana e Diego. Qual era o defeito, qual foi a correção e como provar que os dados não precisavam ser alterados?”

**Resposta esperada:** o filtro de status no WHERE eliminava Bruno, que tinha apenas um cancelamento, e Carla, que não tinha pedidos. Ao colocar a condição de status no ON do LEFT JOIN, a consulta seleciona os pedidos pagos sem perder clientes sem correspondência. COUNT(p.id), SUM e COALESCE produzem as contagens e os totais exigidos. As tabelas de entrada permanecem iguais, e a comparação do resultado completo com o contrato comprova a correção.

## Materiais relacionados

- [Contrato do relatório](contrato.md)
- [Consultas prontas e respostas comentadas para o pgAdmin](../exemplos/respostas-questoes-slides.sql)
- [Consultas explicadas](consultas-explicadas.md)
- [Fluxo de branch, testes e PR](laboratorio-pr.md)
- [Contexto e prompts curtos para a IA Tutora](../prompts/README.md)

Para executar as consultas, o ambiente deve estar carregado conforme o [README principal](../README.md). Os blocos SQL desta página são de leitura e podem ser executados separadamente no Query Tool.
