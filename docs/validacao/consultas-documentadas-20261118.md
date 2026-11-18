# Validação das consultas documentadas

Data: 18/11/2026. PostgreSQL 17.12 do laboratório.

Os dez blocos SQL de [consultas-explicadas.md](../consultas-explicadas.md) foram executados pelo psql com `ON_ERROR_STOP=1`. Todos concluíram sem erro. Os blocos são de leitura, incluindo a análise do plano de um SELECT, e não alteraram os registros das tabelas.

A verificação incluiu leitura de clientes e pedidos, filtro de pagos, LEFT JOIN, consulta inicial, consulta corrigida, agregações, leitura da implementação aplicada, comparação com o contrato, plano de execução e consulta do commit registrado.

A correção funcional e o retorno inicial são verificados separadamente pelos testes descritos em [aplicacao-main-20261118.md](aplicacao-main-20261118.md) e [retorno-inicial-20261118.md](retorno-inicial-20261118.md). Executar sem erro, isoladamente, não comprova o atendimento ao contrato.
