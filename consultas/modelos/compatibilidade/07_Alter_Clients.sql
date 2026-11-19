-- Mudança de coluna: o SELECT anterior deixa de ser compatível.
-- Publique junto da próxima versão SELECT, preservando o contrato de saída.
ALTER TABLE ws4_demo.clients RENAME COLUMN description TO name;
COMMENT ON COLUMN ws4_demo.clients.name IS 'Nome de exibição do cliente de demonstração';
