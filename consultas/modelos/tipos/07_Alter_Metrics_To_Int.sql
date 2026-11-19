-- A validação rejeita valores fracionários antes da conversão.
-- Sem essa verificação, o cast para integer pode arredondar e perder informação.
-- Se houver, por exemplo, 12.7, a release falha e a transação é desfeita.
ALTER TABLE ws4_demo.metricas ADD CONSTRAINT quantidade_sem_fracao CHECK (quantidade = trunc(quantidade));
ALTER TABLE ws4_demo.metricas ALTER COLUMN quantidade TYPE integer USING quantidade::integer;
ALTER TABLE ws4_demo.metricas DROP CONSTRAINT quantidade_sem_fracao;
