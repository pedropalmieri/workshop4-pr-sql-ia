\set ON_ERROR_STOP on
BEGIN;
CREATE SCHEMA IF NOT EXISTS ws4;
CREATE TABLE IF NOT EXISTS ws4.clientes (
  id integer PRIMARY KEY,
  nome text NOT NULL
);
CREATE TABLE IF NOT EXISTS ws4.pedidos (
  id integer PRIMARY KEY,
  cliente_id integer NOT NULL REFERENCES ws4.clientes(id),
  status text NOT NULL CHECK (status IN ('pago', 'cancelado')),
  valor numeric(12,2) NOT NULL CHECK (valor >= 0)
);
TRUNCATE ws4.pedidos, ws4.clientes;
INSERT INTO ws4.clientes VALUES (1, 'Ana'), (2, 'Bruno'), (3, 'Carla'), (4, 'Diego');
INSERT INTO ws4.pedidos VALUES
  (101, 1, 'pago', 100.00), (102, 1, 'pago', 50.00),
  (103, 1, 'cancelado', 900.00), (104, 2, 'cancelado', 80.00),
  (105, 4, 'pago', 0.00);
COMMIT;
