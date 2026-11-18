# Explicação das consultas para a turma

Este é o apoio para a demonstração de SQL. A sequência usa sempre o mesmo caso, evitando gastar tempo mudando de domínio. Os seis blocos estão em `exemplos/consultas-passo-a-passo.sql` e são somente leitura.

Antes da aula, teste todos com `bash demo.sh passos`. Ao vivo, prefira executar um bloco por vez com `bash demo.sh terminal`, aguardando o resultado antes de explicar o próximo. Não é necessário percorrer cada detalhe técnico abaixo durante o encontro.

## 1. SELECT, FROM e ORDER BY

```sql
SELECT id, nome FROM ws4.clientes ORDER BY id;
```

Fala: “FROM informa a tabela. SELECT escolhe as colunas que veremos. ORDER BY organiza a exibição. Aqui, ws4 é o schema e clientes é a tabela.”

Resultado: Ana, Bruno, Carla e Diego, em quatro linhas. Pergunta: “Se eu selecionar só o nome, o cliente deixa de ter id no banco?”. Resposta: não. A projeção muda a saída, não a estrutura da tabela.

## 2. WHERE e valores zero

```sql
SELECT id, cliente_id, valor
FROM ws4.pedidos
WHERE status = 'pago'
ORDER BY id;
```

Fala: “WHERE restringe as linhas. O critério é status pago. Não colocamos valor maior que zero, porque o contrato aceita um pedido pago de valor zero.”

Resultado: pedidos 101, 102 e 105. Total: 150. Pergunta: “Por que o cancelado de 900 ficou de fora?”. Resposta: o status não atende ao filtro, mesmo que seu valor seja maior.

## 3. INNER JOIN e chaves

Mostre o terceiro bloco do arquivo.

Fala: “c e p são apelidos das tabelas. A condição ON relaciona a chave do cliente à referência guardada no pedido. O INNER JOIN conserva correspondências que atendem à condição.”

Resultado: três linhas, duas de Ana e uma de Diego. Bruno e Carla não aparecem. Pergunta: “O JOIN deveria produzir uma linha por cliente?”. Resposta: ainda não. A junção produz uma linha por correspondência. Ana tem dois pedidos pagos.

## 4. LEFT JOIN e NULL

Mostre o quarto bloco. A única mudança relevante é INNER para LEFT.

Fala: “O lado esquerdo contém os clientes. Mesmo sem pedido pago correspondente, o LEFT JOIN preserva o cliente. As colunas do pedido ficam nulas.”

Resultado: cinco linhas antes da agregação. Ana aparece duas vezes, e cada outro cliente aparece uma vez. Use `\pset null '(NULL)'` para destacar ausências na tela.

Pergunta: “O NULL de Carla é o mesmo que o zero de Diego?”. Resposta: não. Carla não tem pedido correspondente. Diego tem um pedido com valor informado igual a zero.

## 5. GROUP BY, COUNT e SUM

Mostre o quinto bloco.

Fala: “GROUP BY reúne as linhas do mesmo cliente. COUNT(p.id) conta chaves de pedido não nulas. SUM(p.valor) soma os valores correspondentes.”

Resultado: quatro linhas. Ana tem contagem 2 e soma 150. Bruno e Carla têm contagem 0 e soma NULL. Diego tem contagem 1 e soma zero.

Pergunta: “Por que a contagem sem correspondência é zero, mas a soma fica nula?”. Resposta: esse é o comportamento das agregações usadas. COUNT de uma expressão conta valores não nulos. SUM sem valores de entrada não nulos retorna NULL.

## 6. COALESCE e relatório final

Mostre o sexto bloco.

Fala: “O contrato pede total zero para quem não tem pagamento. COALESCE escolhe a soma quando ela existe e usa zero quando ela é nula. Isso deixa a saída de acordo com a regra.”

Resultado: Ana 2/150, Bruno 0/0, Carla 0/0 e Diego 1/0. Diga que isso é uma escolha de representação do relatório, não uma prova de que zero e ausência sejam sempre equivalentes em qualquer análise.

## Ligação com o bug do exercício

Volte a `sql/02_consulta.sql`, que tem LEFT JOIN e filtro posterior no WHERE. Peça que a turma preveja quem some. Depois rode a consulta e o teste.

Fala: “Na ordem lógica, a junção ocorre antes do WHERE. A condição posterior elimina as linhas preservadas. Vamos mover a condição de pagamento para o ON e verificar o resultado.”

Se precisar explicar por que isso não é apenas uma preferência de estilo, mostre `bash demo.sh diagnosticar`. O filtro altera o resultado, e o teste demonstra a diferença.

## Quanto aprofundar

Essencial na hora: significado de SELECT/FROM/WHERE, chaves, diferença entre os JOINs, contagem, soma e ausência. Reserve EXCEPT ALL, sintaxe do bloco DO e detalhes do otimizador para perguntas ou leitura posterior. O objetivo é aplicar e validar uma consulta, sem transformar o encontro em um curso completo de SQL.

Fontes: documentação oficial de [JOIN](https://www.postgresql.org/docs/current/tutorial-join.html) e [agregações](https://www.postgresql.org/docs/current/functions-aggregate.html).
