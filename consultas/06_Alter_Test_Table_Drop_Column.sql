-- Release de remoção: somente a coluna opcional criada na versão anterior.
-- DROP COLUMN descarta os valores da coluna; avalie consumidores antes do PR.
-- Nesta amostra, a tabela permanece vazia e os dados originais são preservados.
ALTER TABLE ws4_demo.teste_deploy DROP COLUMN observacao;
