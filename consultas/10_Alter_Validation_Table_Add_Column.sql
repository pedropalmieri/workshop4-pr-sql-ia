-- Etapa 2: adicionar coluna e conferir seu default nas duas amostras.
ALTER TABLE ws4_demo.validacao_release ADD COLUMN observacao text NOT NULL DEFAULT 'Coluna de teste';
