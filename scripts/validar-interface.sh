#!/usr/bin/env bash
# Verifica a interface HTTP e a conexão de rede do pgAdmin com o banco do exercício.
set -euo pipefail
cd "$(dirname "$0")/.."
project="${WS4_PROJECT:-ws4-workshop}"
docker compose -p "$project" --profile interface exec -T pgadmin /venv/bin/python3 - <<'PY'
import json
import os
from pathlib import Path
import urllib.request
import psycopg

with urllib.request.urlopen('http://127.0.0.1/misc/ping', timeout=10) as response:
    assert response.status == 200
print('PASS: pgAdmin responde por HTTP')

server = json.loads(Path('/pgadmin4/servers.json').read_text())['Servers']['1']
user_dir = os.environ['PGADMIN_DEFAULT_EMAIL'].replace('@', '_')
passfile = Path('/var/lib/pgadmin/storage') / user_dir / '.pgpass'
assert passfile.exists()
assert passfile.stat().st_mode & 0o077 == 0

with psycopg.connect(host=server['Host'], port=server['Port'],
                      dbname=server['MaintenanceDB'], user=server['Username'],
                      passfile=str(passfile), connect_timeout=10) as conn:
    with conn.cursor() as cur:
        cur.execute('SELECT current_database(), current_user')
        assert cur.fetchone() == ('workshop', 'workshop')
        print('PASS: pgAdmin conecta a db:5432, banco workshop e usuário workshop')
        cur.execute('SELECT (SELECT COUNT(*) FROM ws4.clientes), (SELECT COUNT(*) FROM ws4.pedidos)')
        assert cur.fetchone() == (4, 5)
        print('PASS: schema ws4, quatro clientes e cinco pedidos disponíveis')
        cur.execute('''SELECT c.id, c.nome, COUNT(p.id), COALESCE(SUM(p.valor), 0)
                       FROM ws4.clientes c LEFT JOIN ws4.pedidos p
                         ON p.cliente_id = c.id AND p.status = 'pago'
                       GROUP BY c.id, c.nome ORDER BY c.id''')
        assert cur.fetchall() == [(1, 'Ana', 2, 150), (2, 'Bruno', 0, 0),
                                  (3, 'Carla', 0, 0), (4, 'Diego', 1, 0)]
        print('PASS: consulta de referência retorna os quatro resultados do contrato')
print('INTERFACE VALIDADA: o teste não modifica a consulta inicial nem os dados')
PY
