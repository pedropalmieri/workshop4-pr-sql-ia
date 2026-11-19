import importlib.util,unittest
spec=importlib.util.spec_from_file_location('releases','scripts/publicar-releases.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
class Releases(unittest.TestCase):
 def registro(self):return {'versao':4,'commit_sha':'a'*40,'arquivo':'04_Create_Test_Table.sql','sha256':'b'*64,'aplicado_em':'2026-11-19','execucao':'123'}
 def test_tag_aponta_commit_aplicado(self):
  chamadas=[]
  def api(path,data=None):
   chamadas.append((path,data))
   if data and path=='/git/tags':return {'sha':'c'*40}
   if data and path=='/releases':return {'html_url':'https://example.test/release'}
  tag,url=r.publicar(api,self.registro(),'dono/repo')
  self.assertEqual(tag,'bd-v0004')
  payload=next(d for p,d in chamadas if p=='/git/tags');self.assertEqual(payload['object'],'a'*40)
  release=next(d for p,d in chamadas if p=='/releases' and d);self.assertIn('actions/runs/123',release['body'])
 def test_reexecucao_nao_recria_tag(self):
  def api(path,data=None):
   self.assertIsNone(data)
   if path.startswith('/git/ref/'):return {'object':{'type':'tag','sha':'c'*40}}
   if path.startswith('/git/tags/'):return {'object':{'type':'commit','sha':'a'*40}}
   return {'draft':False,'prerelease':False,'html_url':'https://example.test/release'}
  self.assertEqual(r.publicar(api,self.registro(),'dono/repo')[0],'bd-v0004')
 def test_tag_existente_em_outro_commit_bloqueia(self):
  def api(path,data=None):
   self.assertIsNone(data);return {'object':{'type':'commit','sha':'d'*40}}
  with self.assertRaisesRegex(ValueError,'outro commit'):r.publicar(api,self.registro(),'dono/repo')
 def test_commit_invalido_nao_cria_tag(self):
  row=self.registro();row['commit_sha']='main'
  def api(*args):self.fail('Não deve acessar GitHub com commit inválido')
  with self.assertRaises(ValueError):r.publicar(api,row,'dono/repo')
