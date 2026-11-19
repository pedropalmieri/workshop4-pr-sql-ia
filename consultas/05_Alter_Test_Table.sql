-- Release de evolução: adiciona coluna opcional e limita a descrição.
-- A tabela é exclusiva da demonstração, não afeta clientes ou pedidos.
ALTER TABLE ws4_demo.teste_deploy ADD COLUMN observacao text;
ALTER TABLE ws4_demo.teste_deploy ALTER COLUMN descricao TYPE varchar(120);
COMMENT ON COLUMN ws4_demo.teste_deploy.observacao IS 'Observação opcional da demonstração';
