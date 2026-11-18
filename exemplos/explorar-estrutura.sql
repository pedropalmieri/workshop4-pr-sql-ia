-- Identificação da conexão e dos objetos do exercício. Somente leitura.
\echo 'Conexão atual'
SELECT current_database() AS banco, current_user AS usuario;

\echo 'Schema do exercício'
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'ws4';

\echo 'Tabelas e views em ws4'
SELECT table_schema AS schema, table_name AS objeto, table_type AS tipo
FROM information_schema.tables
WHERE table_schema = 'ws4'
ORDER BY table_name;

\echo 'Chaves e campos das tabelas'
SELECT table_name AS tabela, column_name AS coluna, data_type AS tipo, is_nullable AS aceita_nulo
FROM information_schema.columns
WHERE table_schema = 'ws4' AND table_name IN ('clientes', 'pedidos')
ORDER BY table_name, ordinal_position;
