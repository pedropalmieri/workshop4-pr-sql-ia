-- Cadastro artificial: preserva os clientes do caso principal.
CREATE TABLE ws4_demo.clients (id integer PRIMARY KEY, description text NOT NULL);
INSERT INTO ws4_demo.clients VALUES (1, 'Ana'), (2, 'Bruno');
