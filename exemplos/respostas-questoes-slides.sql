-- WORKSHOP 4 | Consultas para analisar e responder às questões dos slides
-- Compatível com o Query Tool do pgAdmin. Selecione e execute um bloco por vez.
-- Todos os blocos são de leitura. Não alteram tabelas, consulta aplicada ou dados.
-- As consultas calculadas funcionam tanto no estado inicial quanto no corrigido.
-- Os blocos que leem ws4.resumo_clientes mostram o estado efetivamente aplicado.

-- Q01 | Qual é o estado atual da tabela de clientes? Slides 14 e 16.
-- SELECT escolhe as colunas. ORDER BY organiza a exibição, sem mudar os dados.
-- Esperado: 1 Ana, 2 Bruno, 3 Carla, 4 Diego. Todos devem aparecer no relatório.
SELECT id, nome
FROM ws4.clientes
ORDER BY id;

-- Q02 | Quais pedidos existem e a quem pertencem? Slide 16.
-- cliente_id aponta para clientes.id. Carla não tem linha em pedidos.
-- Esperado: Ana possui 101/102 pagos e 103 cancelado; Bruno, 104 cancelado;
-- Diego, 105 pago de valor zero. São cinco pedidos, sem alteração dos registros.
SELECT p.id AS pedido_id, p.cliente_id, c.nome, p.status, p.valor
FROM ws4.pedidos p
JOIN ws4.clientes c ON c.id = p.cliente_id
ORDER BY p.id;

-- Q03 | Qual é o objetivo e o resultado correto do relatório? Slides 15 e 17.
-- Uma linha por cliente, contando e somando somente pedidos pagos.
-- O filtro no ON preserva os clientes sem correspondência em pedidos pagos.
-- Esperado: Ana 2/150.00; Bruno 0/0.00; Carla 0/0.00; Diego 1/0.00.
SELECT c.id, c.nome,
       COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;

-- Q04 | Por que o WHERE elimina clientes? Slides 18 e 19.
-- Esta consulta mostra as linhas ANTES de aplicar o WHERE do SQL incorreto.
-- A coluna passa_no_filtro é apenas um diagnóstico calculado no SELECT.
-- Esperado: seis linhas. Bruno tem false; Carla tem false (status NULL).
-- Os dois pagos de Ana e o pago de Diego passam. O cancelado de Ana não passa.
SELECT c.nome, p.id AS pedido_id, p.status,
       COALESCE(p.status = 'pago', false) AS passa_no_filtro
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
ORDER BY c.id, p.id;

-- Q05 | O que a consulta inicial realmente devolve? Slide 18.
-- O WHERE recebe o resultado da junção e remove as linhas que não são pagas.
-- Esperado: só Ana e Diego. Executar sem erro não significa atender ao contrato.
SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
WHERE p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;

-- Q06 | O que muda ao usar COUNT(*)? Slides 21 e 25.
-- COUNT(*) conta a linha preservada, inclusive quando p.id é NULL.
-- COUNT(p.id) ignora ids nulos. É a contagem correta dos pedidos pagos.
-- SUM retorna NULL quando não há valores não nulos. COALESCE mostra zero.
-- Esperado (COUNT(*) / COUNT(p.id)): Ana 2/2, Bruno 1/0, Carla 1/0, Diego 1/1.
-- Para Bruno/Carla, soma_sem_tratamento é NULL. Para Diego, é zero real.
SELECT c.id, c.nome,
       COUNT(*) AS linhas_apos_join,
       COUNT(p.id) AS pedidos_pagos,
       SUM(p.valor) AS soma_sem_tratamento,
       COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
GROUP BY c.id, c.nome
ORDER BY c.id;

-- Q07 | Excluir total zero preserva o requisito? Slide 25.
-- O campo decisao_do_filtro torna visível o efeito de uma exclusão de zeros.
-- Esperado: Ana ficaria; Bruno, Carla e Diego seriam excluídos indevidamente.
-- Diego prova que total zero não significa ausência de pedido pago.
WITH relatorio AS (
  SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos,
         COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
  FROM ws4.clientes c
  LEFT JOIN ws4.pedidos p
    ON p.cliente_id = c.id AND p.status = 'pago'
  GROUP BY c.id, c.nome
)
SELECT id, nome, pedidos_pagos, total_pago,
       CASE WHEN total_pago <> 0 THEN 'Ficaria no resultado'
            ELSE 'Seria excluído, violando o requisito' END AS decisao_do_filtro
FROM relatorio
ORDER BY id;

-- Q08 | Qual pagamento comprova a situação de Diego? Slides 21 e 25.
-- Filtramos status, sem excluir valor zero.
-- Esperado: pedido 105, cliente Diego, status pago, valor 0.00.
SELECT p.id AS pedido_id, c.nome, p.status, p.valor
FROM ws4.pedidos p
JOIN ws4.clientes c ON c.id = p.cliente_id
WHERE p.status = 'pago' AND p.valor = 0
ORDER BY p.id;

-- Q09 | O que mudou antes e depois? Slide 22.
-- Calcula as duas versões na mesma leitura, sem aplicar nenhuma definição.
-- Esperado: duas linhas na Inicial e quatro na Corrigida (seis na grade).
WITH inicial AS (
  SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos,
         COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
  FROM ws4.clientes c
  LEFT JOIN ws4.pedidos p ON p.cliente_id = c.id
  WHERE p.status = 'pago'
  GROUP BY c.id, c.nome
), corrigida AS (
  SELECT c.id, c.nome, COUNT(p.id) AS pedidos_pagos,
         COALESCE(SUM(p.valor), 0)::numeric(12,2) AS total_pago
  FROM ws4.clientes c
  LEFT JOIN ws4.pedidos p
    ON p.cliente_id = c.id AND p.status = 'pago'
  GROUP BY c.id, c.nome
), comparacao AS (
  SELECT 1 AS ordem, 'Inicial' AS versao, * FROM inicial
  UNION ALL
  SELECT 2, 'Corrigida', * FROM corrigida
)
SELECT versao, id, nome, pedidos_pagos, total_pago
FROM comparacao
ORDER BY ordem, id;

-- Q10 | O teste consegue provar que Carla aparece? Slides 23 e 25.
-- O cadastro está à esquerda; a consulta aplicada está à direita.
-- No estado inicial, Carla está no cadastro mas falta no relatório: FAIL.
-- No corrigido, Carla aparece com zero pedidos e total zero: PASS.
-- IS NOT DISTINCT FROM trata a comparação com NULL de forma explícita.
SELECT c.id, c.nome,
       (r.id IS NOT NULL) AS aparece_no_relatorio,
       r.pedidos_pagos, r.total_pago,
       CASE WHEN r.id IS NOT NULL
                  AND r.pedidos_pagos IS NOT DISTINCT FROM 0
                  AND r.total_pago IS NOT DISTINCT FROM 0
            THEN 'PASS: Carla aparece com zero'
            ELSE 'FAIL: Carla ausente ou com valores incorretos' END AS verificacao
FROM ws4.clientes c
LEFT JOIN ws4.resumo_clientes r ON r.id = c.id
WHERE c.id = 3;

-- Q11 | Como verificar o resultado completo, sem copiar a lógica da consulta?
-- Slide 23. A expectativa é calculada a partir da regra e dos dados do caso.
-- EXCEPT ALL nas duas direções detecta ausências, extras, duplicação e valores.
-- Inicial: duas diferenças (Bruno e Carla). Corrigido: nenhuma linha na saída.
WITH esperado(id, nome, pedidos_pagos, total_pago) AS (
  VALUES (1, 'Ana', 2::bigint, 150.00::numeric),
         (2, 'Bruno', 0::bigint, 0.00::numeric),
         (3, 'Carla', 0::bigint, 0.00::numeric),
         (4, 'Diego', 1::bigint, 0.00::numeric)
), diferencas AS (
  (SELECT * FROM esperado EXCEPT ALL SELECT * FROM ws4.resumo_clientes)
  UNION ALL
  (SELECT * FROM ws4.resumo_clientes EXCEPT ALL SELECT * FROM esperado)
)
SELECT * FROM diferencas ORDER BY id;

-- Q12 | Qual versão está efetivamente aplicada no banco? Slides 4, 13 e 22.
-- A consulta aplicada pode diferir de um SELECT isolado ou de um arquivo local.
-- Inicial: Ana e Diego. Corrigida: quatro clientes.
SELECT id, nome, pedidos_pagos, total_pago
FROM ws4.resumo_clientes
ORDER BY id;

-- Q13 | Como relacionar banco, commit e execução do workflow? Slides 4 e 13.
-- O comentário é gravado pela aplicação automática. Pode ser NULL antes dela.
-- A resposta sobre revisão e justificativa também depende do PR e de seus registros;
-- um SELECT, sozinho, não comprova a qualidade da revisão ou da interação com a IA.
SELECT obj_description('ws4.resumo_clientes'::regclass) AS ultima_aplicacao;

-- Q14 | O que EXPLAIN mostra? Slide 8.
-- Apresenta o plano estimado, sem executar a consulta.
-- cost é custo estimado do planejador, não tempo em milissegundos.
EXPLAIN
SELECT id, nome, pedidos_pagos, total_pago FROM ws4.resumo_clientes;

-- Q15 | O que EXPLAIN ANALYZE acrescenta? Slide 8.
-- Executa este SELECT e mostra medições reais (actual time, rows, loops).
-- A base pequena serve para entender o plano; não comprova ganhos em escala.
-- Aqui a operação analisada é apenas SELECT, sem alteração dos dados.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, nome, pedidos_pagos, total_pago FROM ws4.resumo_clientes;

-- Q16 | Que contexto pode ser enviado à IA? Slides 11 e 24.
-- Estes SELECTs reúnem dados fictícios e o resultado observado. Anexe também
-- o SQL em análise, o objetivo e o resultado esperado (Q03/contrato.md).
-- Não envie credenciais. Peça diagnóstico e explicação, mantendo a execução
-- com o Fellow. Decisões aceitas/rejeitadas devem ter evidência, não só opinião.
SELECT id, nome FROM ws4.clientes ORDER BY id;
SELECT id, cliente_id, status, valor FROM ws4.pedidos ORDER BY id;
SELECT id, nome, pedidos_pagos, total_pago FROM ws4.resumo_clientes ORDER BY id;
