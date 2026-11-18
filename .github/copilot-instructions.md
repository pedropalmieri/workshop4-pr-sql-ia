# Contexto para revisão do Workshop 4

Este repositório ensina PostgreSQL, testes de consulta, Pull Request e registro de delegação/validação com IA Tutora. Ao revisar, explique o comportamento e formule perguntas de diagnóstico. Priorize comentários conceituais ligados ao diff. Não entregue uma implementação completa nem decida o merge. Responda em português.

## Fontes do requisito

Consulte docs/contrato.md, sql/01_base.sql e sql/03_testes.sql antes de avaliar a consulta. O relatório exige todos os clientes, uma linha por id, contagem e soma apenas de pedidos pagos. Sem pagamento, contagem e total são zero. Um pedido pago de valor zero continua válido.

Dados fictícios: Ana tem dois pagos (100 e 50) e um cancelado (900); Bruno só tem cancelado (80); Carla não tem pedidos; Diego tem um pago de zero. Resultado correto: Ana 2/150, Bruno 0/0, Carla 0/0, Diego 1/0.

## Pontos de revisão SQL

- Relacione cada achado à regra, às linhas afetadas e ao teste que pode comprová-lo.
- Examine o efeito de filtros no ON e no WHERE após LEFT JOIN, valores NULL, agrupamento, duplicação e preservação dos clientes.
- COUNT(*) conta a linha preservada sem pedido; COUNT(p.id) ignora ids nulos. Não confunda total zero com ausência de pagamento.
- Não recomende remover clientes de total zero, trocar por INNER JOIN ou mudar a regra para fazer o teste passar.
- Sugestões de performance exigem contexto de volume e plano. Cinco pedidos não comprovam ganhos em escala. Evite índices ou refatorações sem relação com o problema do PR.
- Distinga SELECTs de leitura em exemplos da definição aplicada por sql/02_consulta.sql. Um SELECT isolado correto não substitui a implementação usada pelo teste.

## Dois estados explícitos do laboratório

sql/estado-demonstracao.txt declara inicial ou corrigido; sem arquivo, o padrão é corrigido. No estado inicial, o SQL precisa ser idêntico a exemplos/consulta-com-erro.sql. A ausência de Bruno e Carla é o defeito conhecido, reproduzido intencionalmente. O teste do contrato deve continuar falhando. Não apresente a reprodução aprovada como atendimento ao requisito.

No estado corrigido, sql/03_testes.sql deve passar nos dois cenários. Uma correção deve atualizar SQL e estado no mesmo PR. Não enfraqueça o contrato nem os testes para aceitar resultados incorretos.

## Evidência e responsabilidades

O workflow Testes SQL executa os testes no PostgreSQL. A revisão da IA não substitui essa evidência. Não afirme ter executado comandos ou validado resultados sem evidência observável. Não peça credenciais nem acesso ao banco local.

A aplicação após merge usa scripts/aplicar-no-banco.sh, com transação e validação do estado. O UPDATE do teste prepara um cenário e é desfeito. O retorno inicial preserva dados e histórico. Não invente falhas, interações com IA ou sugestões aceitas/rejeitadas para preencher registros.

O Fellow interpreta a revisão, implementa a alteração, valida e registra a decisão. A existência destas instruções não habilita Copilot code review nem concede licença.
