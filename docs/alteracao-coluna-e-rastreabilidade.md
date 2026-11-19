# Quando uma mudança de coluna afeta um relatório

## Situação e pergunta

Um cadastro de demonstração tem dois registros: id 1, Ana; id 2, Bruno. A tabela `ws4_demo.clients` começa com as colunas `id` e `description`. O relatório retorna essas duas colunas. Outra mudança propõe chamar a coluna de `name`. O relatório antigo continuará funcionando? Se a mudança for mantida, como adaptar a consulta preservando o histórico e a saída esperada?

Esse exemplo usa uma tabela separada. As tabelas `ws4.clientes` e `ws4.pedidos` do caso de pagamentos permanecem preservadas.

## Padrão dos arquivos

Use `NN_Operacao_Objeto.sql`, como `01_Select_Clients.sql` ou `02_Alter_Clients.sql`. O número identifica a ordem global de publicação no catálogo, não uma contagem separada por tabela. Os nomes dos arquivos usam operações em inglês (`Select`, `Create`, `Alter`, `Drop`); os nomes reais das tabelas são os declarados dentro do SQL. Cada arquivo tem seu teste JSON com o mesmo nome.

Os exemplos em [consultas/modelos/compatibilidade](../consultas/modelos/compatibilidade/) começam em 05. Antes de promover um modelo, ajuste o número ao próximo livre do catálogo e renomeie também seu teste. Nunca renomeie uma versão já publicada.

## 1. Criar o cadastro e publicar o primeiro relatório

Copie `05_Create_Clients.sql` e `06_Select_Clients.sql`, com os testes correspondentes, para `consultas/` e `consultas/testes/`. Faça commit e push na develop, confira os checks, abra o PR para main e confirme o merge. A aplicação cria a tabela e registra as versões.

A consulta inicial é:

```sql
SELECT id, description FROM ws4_demo.clients ORDER BY id;
```

Resultado esperado: `(1, Ana)` e `(2, Bruno)`. O teste da consulta identifica seu contrato como `cadastro-demo`.

## 2. Identificar uma mudança incompatível antes da publicação

Na develop, copie `07_Alter_Clients.sql` e seu teste. A mudança renomeia a coluna:

```sql
ALTER TABLE ws4_demo.clients RENAME COLUMN description TO name;
COMMENT ON COLUMN ws4_demo.clients.name IS 'Nome de exibição do cliente de demonstração';
```

O push executa os testes em um banco isolado. A migração pode executar e seu teste de estrutura passar, mas a regressão da consulta vigente falha: a coluna `description` deixou de existir. O check `versoes` fica vermelho, impedindo o merge. O banco compartilhado continua com a versão anterior; a falha aconteceu no ambiente de validação.

Pergunta: basta o ALTER estar sintaticamente correto? Não. É necessário verificar os consumidores da coluna e o contrato do relatório.

## 3. Decidir se a mudança será mantida

Se o novo nome não for necessário, retire a proposta ainda não publicada. Se for mantido, acrescente `08_Select_Clients.sql` e seu teste ao mesmo PR:

```sql
SELECT id, name AS description FROM ws4_demo.clients ORDER BY id;
```

O alias mantém a saída `description` para os consumidores. Os dados e a expectativa continuam iguais. O teste da nova versão usa o mesmo identificador `cadastro-demo`; a maior versão desse contrato passa a ser a consulta vigente para as regressões. A versão antiga permanece imutável como evidência histórica, mas não deve ser executada como consulta atual após a mudança.

Faça novo push na develop. O workflow aplica a sequência em uma base limpa e verifica a última consulta de cada contrato no estado final. Com os checks aprovados, revise e faça merge. O lote pendente é aplicado em uma transação: uma falha desfaz esse lote.

## 4. Alterar somente a descrição da coluna

`09_Alter_Clients_Comment.sql` usa somente `COMMENT ON COLUMN`. Isso altera a documentação do campo no PostgreSQL; não renomeia a coluna, não muda seu tipo e não altera os valores. A consulta vigente deve continuar retornando Ana e Bruno. Esse exemplo diferencia uma mudança de metadado de uma mudança que afeta o SQL.

## 5. Investigar o que chegou ao banco

```sql
SELECT versao, arquivo, commit_sha, execucao, aplicado_em
FROM ws4_controle.versoes
ORDER BY versao;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ws4_demo' AND table_name = 'clients'
ORDER BY ordinal_position;
```

Relacione o arquivo ao diff do PR, à decisão registrada e à execução do Actions. O commit identifica o código publicado; o PR reúne a discussão e as contas envolvidas. O registro da automação identifica o lote aplicado, sem presumir que o autor do commit é a única pessoa responsável pela decisão.

## E se alguém alterar o banco diretamente?

Uma alteração fora do fluxo não cria automaticamente um commit ou um PR. A divergência entre o esquema esperado e o observado ajuda no diagnóstico, e a próxima validação das consultas vigentes pode detectar a incompatibilidade. Porém o Git e `ws4_controle.versoes` não identificam o autor de comandos manuais. Para isso, um ambiente real precisa de controle de acesso e auditoria/logs de DDL no banco. Este laboratório não configura essa auditoria.

A proteção da main protege o código no GitHub. Ela não impede que alguém com credenciais suficientes execute ALTER diretamente no PostgreSQL.
