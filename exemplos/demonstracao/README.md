# Consultas de demonstração

Sequência de exemplos do Workshop 4 para explorar o banco, construir o relatório e conferir o resultado. Todos os arquivos contêm SQL PostgreSQL de **somente leitura**, compatível com o Query Tool do pgAdmin.

## Preparação

Na raiz do repositório:

```bash
bash demo.sh interface
bash demo.sh base
bash demo.sh inicio
```

Abra o [pgAdmin](http://localhost:5050), conecte ao servidor **Workshop 4 - PostgreSQL**, selecione o banco **workshop** e abra **Ferramentas > Ferramenta de consulta**. Os dados de acesso estão no [guia do pgAdmin](../../docs/pgadmin.md).

Copie o SQL de um arquivo para o Query Tool e execute. No arquivo 02, execute cada SELECT separadamente. Antes de avançar, compare a saída com o resultado esperado.

## Sequência

| Etapa | Arquivo | Conceito e resultado esperado |
|---|---|---|
| 01 | [Conexão e schema](01_conexao_e_schema.sql) | Banco workshop, usuário workshop e schema ws4 |
| 02 | [Explorar dados](02_explorar_dados.sql) | Quatro clientes e cinco pedidos |
| 03 | [Filtrar pagamentos](03_filtrar_pedidos_pagos.sql) | Três pedidos pagos, incluindo valor zero |
| 04 | [INNER JOIN](04_inner_join.sql) | Três correspondências, somente Ana e Diego |
| 05 | [LEFT JOIN](05_left_join.sql) | Cinco linhas, preservando Bruno e Carla |
| 06 | [Filtro após o JOIN](06_filtro_apos_join.sql) | Resultado incorreto: dois clientes ausentes |
| 07 | [Agrupar e somar](07_agrupar_e_somar.sql) | Quatro clientes, com soma nula sem pagamento |
| 08 | [Relatório completo](08_relatorio_completo.sql) | Quatro clientes com contagens e totais do contrato |
| 09 | [Comparar contagens](09_comparar_contagens.sql) | Diferença entre COUNT(*) e COUNT(p.id) |
| 10 | [Conferir a view](10_conferir_view.sql) | FAIL antes da correção aplicada e PASS depois |

As etapas 01 a 08 constroem a explicação principal. As etapas 09 e 10 aprofundam a discussão e a validação. Os exemplos podem ser consultados independentemente, com a base carregada.

## Do resultado ao arquivo versionado

A etapa 08 executa um SELECT correto, mas não altera a view. A etapa 10 verifica a view que está realmente aplicada no banco. Portanto, executar a etapa 08 não transforma o FAIL da etapa 10 em PASS.

A correção já está na `main` em `sql/02_consulta.sql`: o filtro de status está no ON. Compare esse arquivo com `exemplos/consulta-com-erro.sql`. Para aplicar a versão corrigida ao banco e conferir os resultados:

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
bash scripts/registrar-evidencia.sh
```

Depois, execute novamente a etapa 10 no pgAdmin. Com a correção aplicada, o resultado deve ser PASS e zero diferenças. O [PR nº 1](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1) preserva o diff e as evidências da correção já incorporada. Para novas alterações, use o fluxo do [laboratório](../../docs/laboratorio-pr.md).

## IA na análise

O ChatGPT atua como tutora após observar o problema da etapa 06 e o teste com falha. A explicação recebida deve ser confrontada com os dados, o contrato e os testes. A alteração e a execução ficam com quem está desenvolvendo. Os [prompts](../../docs/prompts-tutora.md) e o [registro de decisões](../../docs/registro-ia-modelo.md) complementam a atividade.

## Referências do projeto

- [Contrato do relatório](../../docs/contrato.md)
- [Explicação das consultas](../../docs/consultas-passo-a-passo.md)
- [Análise do JOIN e das agregações](../../docs/sql-comentado.md)
- [Arquivo com a sequência compacta para o pgAdmin](../consultas-pgadmin.sql)
