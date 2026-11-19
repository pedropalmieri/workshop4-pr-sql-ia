-- Release de demonstração: metadados de criação, exclusão lógica e atividade.
-- timestamp sem fuso, conforme o exemplo. active usa true/false; deleted_at nulo
-- não exclui registros. A aplicação não preenche created_at retroativamente,
-- pois não conhecemos a data histórica real dos pedidos já existentes.
ALTER TABLE ws4.pedidos
  ADD COLUMN created_at timestamp,
  ADD COLUMN deleted_at timestamp,
  ADD COLUMN active boolean NOT NULL DEFAULT true;
