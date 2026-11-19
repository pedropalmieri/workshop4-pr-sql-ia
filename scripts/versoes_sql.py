#!/usr/bin/env python3
"""Valida e executa scripts numerados, preservando conteúdo, testes e histórico."""
import argparse, hashlib, json, os, re, subprocess, sys
from collections import Counter
from decimal import Decimal
from pathlib import Path
import psycopg
from psycopg.rows import dict_row
from psycopg.types.json import Jsonb
from pglast import ast, parse_sql
from pglast.stream import RawStream

ROOT = Path(__file__).resolve().parents[1]
PADRAO = re.compile(r'^(\d{2,})_[A-Za-z][A-Za-z0-9_]*\.sql$')
FUNCOES = {'count','sum','avg','min','max','round','abs','lower','upper','length','trim','btrim','to_char','date_trunc','now','current_database','trunc','pg_get_serial_sequence','split_part'}

def git(*args):
    return subprocess.check_output(['git','-c',f'safe.directory={ROOT}',*args],cwd=ROOT,text=True).strip()

def nodes(value):
    if isinstance(value, ast.Node):
        yield value
        for slot in value:
            yield from nodes(getattr(value,slot))
    elif isinstance(value,(tuple,list)):
        for item in value: yield from nodes(item)

def texto_entrada(path):
    if path.is_symlink(): raise ValueError(f'Links simbólicos não são permitidos: {path}')
    return path.read_text(encoding='utf-8')

def selecionar(sql, contexto):
    tree=parse_sql(sql)
    if len(tree)!=1 or not isinstance(tree[0].stmt,ast.SelectStmt):
        raise ValueError(f'{contexto}: use exatamente um SELECT de leitura')
    for node in nodes(tree):
        if isinstance(node,(ast.InsertStmt,ast.UpdateStmt,ast.DeleteStmt,ast.MergeStmt)):
            raise ValueError(f'{contexto}: escrita de dados não é permitida')
        if isinstance(node,ast.SelectStmt) and (node.intoClause or node.lockingClause):
            raise ValueError(f'{contexto}: SELECT INTO e bloqueios não são permitidos')
        if isinstance(node,ast.FuncCall):
            name=[part.sval for part in node.funcname]
            if len(name)>1 or name[0].lower() not in FUNCOES:
                raise ValueError(f'{contexto}: função fora das funções de leitura do laboratório: {name}')
    return tree[0].stmt

def analisar(sql, contexto):
    tree=parse_sql(sql)
    if not tree:raise ValueError(f'{contexto}: script vazio')
    stmts=[item.stmt for item in tree]
    identities=set()
    for stmt in stmts:
        if isinstance(stmt,ast.AlterTableStmt) and any(cmd.subtype.name=='AT_AddIdentity' for cmd in stmt.cmds):
            identities.add(f'{stmt.relation.schemaname}.{stmt.relation.relname}')
    for stmt in stmts:
        if isinstance(stmt,ast.SelectStmt):
            funcs=[n for n in nodes(stmt) if isinstance(n,ast.FuncCall)]
            setvals=[f for f in funcs if [x.sval for x in f.funcname]==['setval']]
            if setvals:
                rendered=RawStream()(stmt)
                if len(setvals)!=1 or not any("'"+name+"'" in rendered for name in identities):
                    raise ValueError(f'{contexto}: setval somente para identity criada no mesmo script')
                if any([x.sval for x in f.funcname] not in [['setval'],['pg_get_serial_sequence'],['max']] for f in funcs):
                    raise ValueError(f'{contexto}: função não prevista no ajuste da identity')
                for n in nodes(stmt):
                    if isinstance(n,ast.RangeVar) and f'{n.schemaname}.{n.relname}' not in identities:
                        raise ValueError(f'{contexto}: sincronização de sequência fora do alvo')
            else:selecionar(RawStream()(stmt),contexto)
        elif isinstance(stmt,ast.CreateStmt):
            if stmt.relation.schemaname!='ws4_demo' or stmt.inhRelations or stmt.ofTypename:
                raise ValueError(f'{contexto}: criação de tabela limitada a ws4_demo')
            if any(isinstance(n,ast.FuncCall) for n in nodes(stmt)):
                raise ValueError(f'{contexto}: função em default não contemplada')
            if any(isinstance(n,ast.Constraint) and n.pktable is not None for n in nodes(stmt)):
                raise ValueError(f'{contexto}: referência externa não contemplada')
        elif isinstance(stmt,ast.AlterTableStmt):
            table=stmt.relation
            demo=table.schemaname=='ws4_demo'
            cadastro=table.schemaname=='ws4' and table.relname in {'clientes','pedidos'}
            if not (demo or cadastro):raise ValueError(f'{contexto}: tabela fora do laboratório')
            for cmd in stmt.cmds:
                tipo=cmd.subtype.name
                if demo:
                    permitidos={'AT_AddColumn','AT_DropColumn','AT_AlterColumnType','AT_AddConstraint','AT_DropConstraint'}
                    if tipo not in permitidos or cmd.behavior.name!='DROP_RESTRICT':
                        raise ValueError(f'{contexto}: alteração não contemplada')
                else:
                    valido=(tipo=='AT_AddIdentity' and cmd.name=='id') or (table.relname=='pedidos' and tipo=='AT_AddColumn' and cmd.def_.colname in {'created_at','deleted_at','active'})
                    if not valido:raise ValueError(f'{contexto}: preserve as colunas originais do caso')
        elif isinstance(stmt,ast.RenameStmt):
            if not stmt.relation or stmt.relation.schemaname!='ws4_demo' or stmt.renameType.name!='OBJECT_COLUMN':
                raise ValueError(f'{contexto}: renomear coluna somente em ws4_demo')
        elif isinstance(stmt,ast.CommentStmt):
            if stmt.objtype.name!='OBJECT_COLUMN' or len(stmt.object)!=3 or stmt.object[0].sval!='ws4_demo':
                raise ValueError(f'{contexto}: comentário somente em coluna de ws4_demo')
        elif isinstance(stmt,ast.DropStmt):
            if stmt.removeType.name!='OBJECT_TABLE' or stmt.behavior.name!='DROP_RESTRICT' or len(stmt.objects)!=1 or len(stmt.objects[0])!=2 or stmt.objects[0][0].sval!='ws4_demo':
                raise ValueError(f'{contexto}: DROP limitado a tabelas de ws4_demo, sem CASCADE')
        elif isinstance(stmt,ast.InsertStmt):
            if stmt.relation.schemaname!='ws4_demo' or any(isinstance(n,(ast.FuncCall,ast.RangeVar)) and n is not stmt.relation for n in nodes(stmt)):
                raise ValueError(f'{contexto}: carga de exemplo limitada a valores em ws4_demo')
        else:raise ValueError(f'{contexto}: comando fora do escopo deste laboratório')
    if len(stmts)>1 and not any(not isinstance(n,ast.SelectStmt) for n in stmts):
        raise ValueError(f'{contexto}: consultas de leitura usam um SELECT por arquivo')
    return stmts

def apenas_select(stmts):
    return len(stmts)==1 and isinstance(stmts[0],ast.SelectStmt) and not any(isinstance(n,ast.FuncCall) and [x.sval for x in n.funcname]==['setval'] for n in nodes(stmts))

def carregar(pasta):
    arquivos=sorted(pasta.glob('*.sql'))
    if not arquivos:raise ValueError('Nenhuma versão SQL encontrada')
    versoes=[]; vistos=set(); testados=set()
    for path in arquivos:
        m=PADRAO.fullmatch(path.name)
        if not m:raise ValueError(f'Nome inválido: {path.name}')
        numero=int(m[1])
        if numero<1 or numero in vistos:raise ValueError(f'Numeração duplicada/inválida: {path.name}')
        vistos.add(numero)
        teste=pasta/'testes'/f'{path.stem}.json'
        sql=texto_entrada(path); raw=texto_entrada(teste)
        spec=json.loads(raw,parse_float=Decimal)
        if not spec.get('descricao'):raise ValueError(f'{teste}: informe a descrição do teste')
        stmt=analisar(sql,path.name)
        if apenas_select(stmt):
            if not isinstance(spec.get('resultado'),list):raise ValueError(f'{teste}: resultado esperado obrigatório')
        elif not spec.get('verificacoes'):raise ValueError(f'{teste}: verificação de estrutura obrigatória')
        for item in spec.get('verificacoes',[]):
            selecionar(item['sql'],str(teste))
            if not isinstance(item.get('esperado'),list):raise ValueError(f'{teste}: expectativa deve ser uma lista')
        if 'contrato' in spec and (not apenas_select(stmt) or not isinstance(spec['contrato'],str) or not spec['contrato'].strip()):raise ValueError(f'{teste}: contrato deve nomear uma consulta de leitura')
        digest=hashlib.sha256(sql.encode()+b'\0'+raw.encode()).hexdigest()
        versoes.append((numero,path.name,digest,stmt,spec));testados.add(teste.name)
    orfaos={p.name for p in (pasta/'testes').glob('*.json')}-testados
    if orfaos:raise ValueError(f'Testes sem script SQL: {sorted(orfaos)}')
    return sorted(versoes)

def preservar_historico(base,pasta):
    if not base or re.fullmatch('0{40}',base):return
    if not re.fullmatch(r'[0-9a-f]{40}',base):raise ValueError('Referência-base inválida')
    prefixo=pasta.relative_to(ROOT).as_posix()
    antigos=git('ls-tree','-r','--name-only',base,'--',prefixo).splitlines()
    numeros=[]
    for name in antigos:
        rel=Path(name).relative_to(prefixo)
        if not ((len(rel.parts)==1 and rel.suffix=='.sql') or (len(rel.parts)==2 and rel.parts[0]=='testes' and rel.suffix=='.json')):continue
        atual=ROOT/name
        if not atual.is_file() or atual.is_symlink():raise ValueError(f'Versão anterior removida: {name}')
        anterior=subprocess.check_output(['git','-c',f'safe.directory={ROOT}','show',f'{base}:{name}'],cwd=ROOT)
        if atual.read_bytes()!=anterior:raise ValueError(f'Versão anterior alterada: {name}. Crie uma nova versão.')
        if len(rel.parts)==1:numeros.append(int(PADRAO.fullmatch(rel.name)[1]))
    for path in pasta.glob('*.sql'):
        if path.relative_to(ROOT).as_posix() not in antigos and numeros and int(PADRAO.fullmatch(path.name)[1])<=max(numeros):
            raise ValueError('Nova versão precisa ter número superior ao histórico')

def freeze(v):
    if isinstance(v,dict):return tuple(sorted((k,freeze(x)) for k,x in v.items()))
    if isinstance(v,list):return tuple(freeze(x) for x in v)
    return v

def comparar(obtido,esperado,ordenado,contexto):
    ok=obtido==esperado if ordenado else Counter(map(freeze,obtido))==Counter(map(freeze,esperado))
    if not ok:raise ValueError(f'{contexto}: resultado diferente do contrato. Esperado={esperado!r}; obtido={obtido!r}')

def executar(conn,stmt):
    with conn.cursor() as cur:
        cur.execute(RawStream()(stmt))
        if cur.description and len({c.name for c in cur.description})!=len(cur.description):raise ValueError('Colunas repetidas na saída: use aliases distintos')
        return cur.fetchall() if cur.description else []

def assinatura(conn):
    return conn.execute("SELECT (SELECT jsonb_agg(to_jsonb(c) ORDER BY id) FROM (SELECT id,nome FROM ws4.clientes) c) AS clientes, (SELECT jsonb_agg(to_jsonb(p) ORDER BY id) FROM (SELECT id,cliente_id,status,valor FROM ws4.pedidos) p) AS pedidos").fetchone()

def processar(conn,versoes,commit,execucao):
    conn.execute('SELECT pg_advisory_xact_lock(1942027)')
    conn.execute('CREATE SCHEMA IF NOT EXISTS ws4_controle')
    conn.execute('CREATE SCHEMA IF NOT EXISTS ws4_demo')
    conn.execute('''CREATE TABLE IF NOT EXISTS ws4_controle.versoes (
       versao integer PRIMARY KEY, arquivo text UNIQUE NOT NULL, sha256 text NOT NULL,
       commit_sha text NOT NULL, execucao text NOT NULL, aplicado_em timestamptz NOT NULL DEFAULT now(), resultado jsonb NOT NULL)''')
    historico={r['versao']:r for r in conn.execute('SELECT * FROM ws4_controle.versoes')}
    catalogo={v[0] for v in versoes}
    if set(historico)-catalogo:raise ValueError('O catálogo removeu versões já aplicadas no banco')
    antes=assinatura(conn); novas=[]
    for numero,nome,digest,stmt,spec in versoes:
        if numero in historico:
            old=historico[numero]
            if old['arquivo']!=nome or old['sha256']!=digest:raise ValueError(f'Versão {numero} já aplicada foi alterada')
            print(f'PRESERVADA {nome}',flush=True);continue
        if historico and numero<=max(historico):raise ValueError(f'Versão fora de ordem: {nome}')
        rows=[]
        for comando in stmt:rows=executar(conn,comando)
        if apenas_select(stmt):comparar(rows,spec['resultado'],spec.get('ordenado',False),nome)
        for probe in spec.get('verificacoes',[]):
            comparar(executar(conn,selecionar(probe['sql'],nome)),probe['esperado'],probe.get('ordenado',False),nome)
        # jsonb é armazenamento de evidência; a comparação usa tipos nativos, inclusive Decimal.
        payload=json.loads(json.dumps(rows,default=str))
        conn.execute('INSERT INTO ws4_controle.versoes (versao,arquivo,sha256,commit_sha,execucao,resultado) VALUES (%s,%s,%s,%s,%s,%s)',(numero,nome,digest,commit,execucao,Jsonb(payload)))
        novas.append(nome);print(f'VALIDADA {nome}: {len(rows)} linha(s)',flush=True)
    # Um contrato pode receber nova implementação sem apagar o SELECT histórico.
    vigentes={}
    for versao in versoes:
        if apenas_select(versao[3]):vigentes[versao[4].get('contrato',versao[1])]=versao
    for numero,nome,digest,stmt,spec in vigentes.values():
        comparar(executar(conn,stmt[0]),spec['resultado'],spec.get('ordenado',False),f'Regressão {nome}')
        print(f'REGRESSÃO OK {nome}',flush=True)
    if assinatura(conn)!=antes:raise ValueError('Os dados de clientes/pedidos foram alterados')
    return novas

def main():
    ap=argparse.ArgumentParser();ap.add_argument('modo',choices=['validar','aplicar']);ap.add_argument('--base');ap.add_argument('--pasta',type=Path,default=ROOT/'consultas');args=ap.parse_args()
    pasta=args.pasta.resolve();versoes=carregar(pasta)
    if args.base:preservar_historico(args.base,pasta)
    commit=os.getenv('GITHUB_SHA') or git('rev-parse','HEAD')
    with psycopg.connect('',row_factory=dict_row,connect_timeout=10) as conn:
        conn.execute("SET LOCAL statement_timeout='10s'");conn.execute("SET LOCAL lock_timeout='5s'")
        novas=processar(conn,versoes,commit,os.getenv('GITHUB_RUN_ID','local'))
        if args.modo=='validar':conn.rollback();print('VALIDAÇÃO OK; transação desfeita no banco de testes.')
        else:conn.commit();print('PUBLICAÇÃO OK; histórico e resultados registrados no banco.')
    print('Versões novas:',', '.join(novas) or 'nenhuma')
    if os.getenv('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'],'a') as f:f.write(f'\n## Scripts SQL versionados\n\nModo: {args.modo}. Commit: `{commit}`.\n\n'+''.join(f'- `{n}`\n' for n in novas)+'\nDados de clientes e pedidos preservados.\n')

if __name__=='__main__':
    try:main()
    except Exception as exc:print(f'ERRO: {exc}',file=sys.stderr);sys.exit(1)
