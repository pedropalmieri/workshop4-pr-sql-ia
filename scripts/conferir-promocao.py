#!/usr/bin/env python3
import json,os,urllib.request
base='https://api.github.com/repos/'+os.environ['GITHUB_REPOSITORY']
url=base+'/actions/workflows/testes.yml/runs?head_sha='+os.environ['PR_HEAD_SHA']+'&event=pull_request'
req=urllib.request.Request(url,headers={'Authorization':'Bearer '+os.environ['GH_TOKEN'],'Accept':'application/vnd.github+json','User-Agent':'Workshop4'})
with urllib.request.urlopen(req,timeout=30) as r:runs=json.load(r)['workflow_runs']
if not runs or runs[0]['status']!='completed' or runs[0]['conclusion']!='success':
    raise SystemExit('A validação mais recente do PR não está aprovada.')
print('Promoção develop para main com a validação final do PR aprovada.')
