import importlib.util,json,os,shutil,tempfile,unittest,subprocess
from pathlib import Path
import psycopg
from psycopg.rows import dict_row
spec=importlib.util.spec_from_file_location('versoes','scripts/versoes_sql.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
class VersoesSQL(unittest.TestCase):
 def setUp(self):
  if os.getenv('WS4_TESTDB')!='1':raise RuntimeError('Use somente o banco isolado de validação')
  self.conn=psycopg.connect('',row_factory=dict_row)
  self.conn.execute('DROP SCHEMA IF EXISTS ws4_controle CASCADE');self.conn.execute('DROP SCHEMA IF EXISTS ws4_demo CASCADE')
  self.tmp=tempfile.TemporaryDirectory();self.pasta=Path(self.tmp.name)/'consultas';self.pasta.mkdir();(self.pasta/'testes').mkdir()
  for n in ['01_Select_Clients','02_Select_Orders','03_Select_Client_Report']:
   shutil.copyfile('consultas/'+n+'.sql',self.pasta/(n+'.sql'));shutil.copyfile('consultas/testes/'+n+'.json',self.pasta/'testes'/(n+'.json'))
 def tearDown(self):self.conn.rollback();self.conn.close();self.tmp.cleanup()
 def aplicar(self):return v.processar(self.conn,v.carregar(self.pasta),'a'*40,'teste-isolado')
 def modelo(self,nome,grupo):
  shutil.copyfile('consultas/modelos/'+grupo+'/'+nome+'.sql',self.pasta/(nome+'.sql'))
  shutil.copyfile('consultas/modelos/testes/'+nome+'.json',self.pasta/'testes'/(nome+'.json'))
 def test_catalogo_e_reexecucao(self):
  self.assertEqual(len(self.aplicar()),3);self.assertEqual(self.aplicar(),[])
 def test_modificacao_historica_rejeitada(self):
  self.aplicar();p=self.pasta/'01_Select_Clients.sql';p.write_text(p.read_text()+'\n-- mudança indevida\n')
  with self.assertRaisesRegex(ValueError,'já aplicada'):self.aplicar()
 def test_sintaxe_invalida_e_escrita(self):
  for sql in ['SELEC id FROM ws4.clientes','DELETE FROM ws4.pedidos','WITH x AS (DELETE FROM ws4.pedidos RETURNING *) SELECT * FROM x','SELECT 1; SELECT 2','ALTER TABLE ws4.pedidos DROP COLUMN valor','DROP TABLE ws4.pedidos']:
   with self.assertRaises(Exception):v.analisar(sql,'negativo')
 def test_resultado_incorreto_rejeitado(self):
  p=self.pasta/'03_Select_Client_Report.sql';p.write_text(Path('exemplos/consulta-inicial.sql').read_text())
  with self.assertRaisesRegex(ValueError,'resultado diferente'):self.aplicar()
 def test_modelos_metadados_e_identity(self):
  self.modelo('04_Alter_Orders_Metadata','pedidos');self.modelo('05_Alter_Clients_Orders_Identity','pedidos')
  self.assertEqual(len(self.aplicar()),5)
  r=self.conn.execute("SELECT is_identity FROM information_schema.columns WHERE table_schema='ws4' AND table_name='pedidos' AND column_name='id'").fetchone();self.assertEqual(r['is_identity'],'YES')
 def test_float_para_int_e_rejeicao_de_fracao(self):
  self.modelo('06_Create_Float_Metrics','tipos');self.aplicar()
  self.conn.execute('SAVEPOINT fracao');self.conn.execute('INSERT INTO ws4_demo.metricas VALUES (3,12.7)')
  self.modelo('07_Alter_Metrics_To_Int','tipos')
  with self.assertRaises(psycopg.Error):self.aplicar()
  self.conn.execute('ROLLBACK TO SAVEPOINT fracao');self.aplicar()
 def test_ddl_criacao_coluna_tipo_exclusao(self):
  for n in ['04_Create_Test_Table','05_Alter_Test_Table_Add_Column','06_Alter_Test_Table_Column_Type','07_Alter_Test_Table_Drop_Column','08_Drop_Test_Table']:self.modelo(n,'ddl')
  self.assertEqual(len(self.aplicar()),8)
 def test_mudanca_de_coluna_exige_consulta_compativel(self):
  for n in ['05_Create_Clients','06_Select_Clients']:self.modelo(n,'compatibilidade')
  self.aplicar();self.conn.execute('SAVEPOINT antes_rename')
  self.modelo('07_Alter_Clients','compatibilidade')
  with self.assertRaises(psycopg.errors.UndefinedColumn):self.aplicar()
  self.conn.execute('ROLLBACK TO SAVEPOINT antes_rename')
  self.assertIsNotNone(self.conn.execute('SELECT description FROM ws4_demo.clients LIMIT 1').fetchone())
  self.modelo('08_Select_Clients','compatibilidade');self.aplicar()
  self.modelo('09_Alter_Clients_Comment','compatibilidade');self.aplicar()
  self.assertEqual(self.conn.execute('SELECT name FROM ws4_demo.clients WHERE id=1').fetchone()['name'],'Ana')
 def test_numeros_duplicados(self):
  shutil.copyfile(self.pasta/'01_Select_Clients.sql',self.pasta/'01_Duplicada.sql');shutil.copyfile(self.pasta/'testes/01_Select_Clients.json',self.pasta/'testes/01_Duplicada.json')
  with self.assertRaisesRegex(ValueError,'duplicada'):v.carregar(self.pasta)
 def test_historico_git_nao_pode_ser_editado(self):
  repo=Path(self.tmp.name)/'repo';repo.mkdir();shutil.copytree(self.pasta,repo/'consultas')
  def git(*args):return subprocess.check_output(['git','-C',str(repo),*args],text=True).strip()
  git('init','-q');git('config','user.name','Teste');git('config','user.email','teste@example.com');git('add','.');git('commit','-qm','base');base=git('rev-parse','HEAD')
  original=v.ROOT;v.ROOT=repo
  try:
   v.preservar_historico(base,repo/'consultas')
   p=repo/'consultas/01_Select_Clients.sql';p.write_text(p.read_text()+'\n-- modificado')
   with self.assertRaisesRegex(ValueError,'anterior alterada'):v.preservar_historico(base,repo/'consultas')
  finally:v.ROOT=original
if __name__=='__main__':unittest.main()
