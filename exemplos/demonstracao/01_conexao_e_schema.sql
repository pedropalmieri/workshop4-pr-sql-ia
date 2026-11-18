-- Objetivo: identificar a conexão e confirmar o schema do exercício.
-- Esperado: banco workshop, usuário workshop e schema ws4.
SELECT current_database() AS banco,
       current_user AS usuario,
       (SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'ws4') AS schema_exercicio;
