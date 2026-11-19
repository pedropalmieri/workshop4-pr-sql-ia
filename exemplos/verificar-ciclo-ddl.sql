-- Consultas de conferência: podem ser executadas no pgAdmin em qualquer etapa.
-- Os catálogos retornam o estado atual; após a versão 12 a tabela não existe.
SELECT EXISTS (SELECT 1 FROM information_schema.tables
 WHERE table_schema='ws4_demo' AND table_name='validacao_release') AS tabela_existe;

SELECT column_name,data_type,is_nullable,is_identity,column_default
FROM information_schema.columns
WHERE table_schema='ws4_demo' AND table_name='validacao_release'
ORDER BY ordinal_position;

SELECT versao,arquivo,commit_sha,execucao,aplicado_em
FROM ws4_controle.versoes WHERE versao BETWEEN 9 AND 12 ORDER BY versao;

-- Esperado em todas as etapas: quatro clientes e cinco pedidos.
SELECT (SELECT count(*) FROM ws4.clientes) AS clientes,
       (SELECT count(*) FROM ws4.pedidos) AS pedidos;

-- Execute a consulta abaixo somente nas etapas 09 a 11, antes do DROP TABLE.
-- Nessas etapas, devem existir ids 1 e 2 com active=true.
-- SELECT id,descricao,active FROM ws4_demo.validacao_release ORDER BY id;

-- Somente na etapa 10, a coluna deve conter Coluna de teste nas duas amostras.
-- SELECT id,observacao FROM ws4_demo.validacao_release ORDER BY id;
