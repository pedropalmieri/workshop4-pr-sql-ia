# Contrato da consulta

Caso didático proposto para o Workshop 4. Não é o enunciado oficial do Desafio Final.

Um relatório deve incluir **todos os clientes**, mesmo sem pedidos ou com apenas pedidos cancelados. Contar somente pedidos pagos e somar seus valores. Ausência de pedidos pagos resulta em contagem e total iguais a zero. Um pedido pago de valor zero continua sendo um pedido válido. A chave do resultado é o id do cliente. Ordenação só na exibição.

| id | nome | pedidos_pagos | total_pago |
|---|---|---|---|
| 1 | Ana | 2 | 150.00 |
| 2 | Bruno | 0 | 0.00 |
| 3 | Carla | 0 | 0.00 |
| 4 | Diego | 1 | 0.00 |

Ana testa agregação e exclusão do cancelado. Bruno testa apenas cancelados. Carla testa ausência de pedidos. Diego distingue zero de ausência. Um segundo cenário cancela todos os pedidos, verifica quatro linhas com zero e desfaz a alteração.

O teste compara conjuntos nas duas direções com EXCEPT ALL. Isso detecta linhas ausentes, extras, duplicadas e valores incorretos. O oráculo vem deste cálculo manual, não da consulta em teste.
