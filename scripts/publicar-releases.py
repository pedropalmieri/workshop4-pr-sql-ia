#!/usr/bin/env python3
"""Publica tags e releases somente a partir de versões confirmadas no PostgreSQL."""
import importlib.util,json,os,re,urllib.error,urllib.request
from pathlib import Path
import psycopg
from psycopg.rows import dict_row

ROOT=Path(__file__).resolve().parents[1]

def cliente_api(repo,token):
    def api(path,data=None):
        req=urllib.request.Request('https://api.github.com/repos/'+repo+path,
            data=json.dumps(data).encode() if data is not None else None,
            headers={'Authorization':'Bearer '+token,'Accept':'application/vnd.github+json','User-Agent':'Workshop4-Releases'})
        try:
            with urllib.request.urlopen(req,timeout=30) as r:return json.load(r)
        except urllib.error.HTTPError as exc:
            if exc.code==404 and data is None:return None
            raise RuntimeError(f'GitHub retornou HTTP {exc.code} em {path}') from exc
    return api

def publicar(api,registro,repo):
    numero=registro['versao'];commit=registro['commit_sha'];tag=f'bd-v{numero:04d}'
    if numero<1 or not re.fullmatch('[0-9a-f]{40}',commit):raise ValueError('Versão/commit inválidos no histórico')
    ref=api('/git/ref/tags/'+tag)
    if ref:
        obj=ref['object']
        if obj['type']=='tag':obj=api('/git/tags/'+obj['sha'])['object']
        if obj['type']!='commit' or obj['sha']!=commit:raise ValueError(f'{tag} aponta para outro commit; não será movida')
    else:
        objeto=api('/git/tags',{'tag':tag,'message':f"Deploy BD {numero}: {registro['arquivo']}\nCommit aplicado: {commit}\nExecução: {registro['execucao']}",'object':commit,'type':'commit'})
        api('/git/refs',{'ref':'refs/tags/'+tag,'sha':objeto['sha']})
    release=api('/releases/tags/'+tag)
    if release:
        if release['draft'] or release['prerelease']:raise ValueError(f'{tag}: release existente exige revisão manual')
        return tag,release['html_url']
    run=registro['execucao'];url=f'https://github.com/{repo}/actions/runs/{run}' if str(run).isdigit() else 'Execução local: '+str(run)
    body=f"## Versão aplicada no PostgreSQL\n\n- Script: `consultas/{registro['arquivo']}`\n- Commit aplicado: `{commit}`\n- Hash do SQL e do teste: `{registro['sha256']}`\n- Aplicação confirmada em: {registro['aplicado_em']}\n- Evidência de execução: {url}\n\nA tag aponta para o commit registrado no banco, não para a develop atual. O nome bd-vNNNN corresponde ao número do script; não representa versionamento semântico. Versões anteriores permanecem imutáveis."
    release=api('/releases',{'tag_name':tag,'name':f"{tag} — {registro['arquivo']}",'body':body,'draft':False,'prerelease':False,'make_latest':'false'})
    return tag,release['html_url']

def main():
    repo=os.environ['GITHUB_REPOSITORY'];api=cliente_api(repo,os.environ['GH_TOKEN'])
    module=importlib.util.spec_from_file_location('versoes',ROOT/'scripts/versoes_sql.py');v=importlib.util.module_from_spec(module);module.loader.exec_module(v)
    catalogo={n:(nome,digest) for n,nome,digest,stmt,spec in v.carregar(ROOT/'consultas')}
    with psycopg.connect('',row_factory=dict_row,connect_timeout=10) as conn:
        conn.execute('SET TRANSACTION READ ONLY');conn.execute("SET LOCAL statement_timeout='10s'")
        registros=conn.execute('SELECT * FROM ws4_controle.versoes ORDER BY versao').fetchall()
        for r in registros:
            if catalogo.get(r['versao'])!=(r['arquivo'],r['sha256']):raise ValueError('Histórico do banco diverge do catálogo; publicação interrompida')
    # Valida todo o histórico antes de criar a primeira tag. Não há escrita no banco.
    for r in registros:
        if not re.fullmatch('[0-9a-f]{40}',r['commit_sha']):raise ValueError('Commit inválido no histórico')
    linhas=[]
    for r in registros:
        tag,url=publicar(api,r,repo);print(f'RELEASE CONFIRMADA {tag}: {url}',flush=True);linhas.append(f'- [{tag}]({url}) — `{r["arquivo"]}`')
    if os.getenv('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'],'a') as f:f.write('\n## Releases de banco confirmadas\n\n'+'\n'.join(linhas)+'\n')

if __name__=='__main__':main()
