-- Etapa 1: tabela independente com duas amostras fictícias.
-- A identity gera os ids; a flag assume true quando omitida.
CREATE TABLE ws4_demo.validacao_release (
 id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 descricao text NOT NULL,
 active boolean NOT NULL DEFAULT true
);
INSERT INTO ws4_demo.validacao_release (descricao) VALUES ('Primeira amostra'), ('Segunda amostra');
