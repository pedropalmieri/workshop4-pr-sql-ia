# Scripts SQL versionados

Esta é a pasta principal para novas consultas e releases de banco do laboratório. Um arquivo publicado permanece no histórico: uma alteração nova recebe outro número, outro script e seu respectivo teste.

## Padrão

```text
consultas/
  01_Select_Clients.sql
  02_Select_Orders.sql
  03_Select_Client_Report.sql
  testes/
    01_Select_Clients.json
    02_Select_Orders.json
    03_Select_Client_Report.json
  modelos/
```

O nome segue `NN_Operacao_Objeto.sql`, como `03_Select_Client_Report.sql`. Use o próximo número livre, sem repetir a numeração. O script começa com comentários sobre seu objetivo. Uma consulta de leitura contém um SELECT. Uma migração DDL pode reunir os comandos necessários à mesma mudança, aplicados na mesma transação.

Cada script possui um teste JSON com o mesmo nome em `testes/`. Para SELECT, o teste declara as linhas esperadas, calculadas independentemente. Para DDL, declara consultas de inspeção e a estrutura esperada. A pasta `testes/` oferece modelos reais desse formato.

Não edite, remova ou renomeie scripts e testes já incorporados à main. Para corrigir uma consulta, crie a próxima versão. O workflow compara o conteúdo com a main. Uma versão ainda não publicada pode receber correções na develop e no mesmo PR; versões já publicadas permanecem imutáveis. O banco também confere o hash das versões já executadas.

Os nomes seguem número, operação e objeto, como `01_Select_Clients.sql` e `02_Alter_Clients.sql`. O número é global no catálogo. Operações: Select, Create, Alter e Drop.

## Fluxo básico

1. Atualize e trabalhe na `develop`.
2. Crie o novo `NN_Operacao_Objeto.sql` e `testes/NN_Operacao_Objeto.json`.
3. Faça commit e push na `develop`. O Actions valida sintaxe PostgreSQL, execução, resultado esperado, numeração e histórico em banco separado.
4. Com os checks aprovados, abra PR com **base main** e **compare develop**.
5. Confira o diff, os testes e a descrição. O merge é confirmado manualmente.
6. Após o merge, a automação executa apenas versões ainda não aplicadas no banco de demonstração. Se uma versão falhar, o lote novo é desfeito.
7. O banco registra arquivo, hash, commit, execução, data e resultado em `ws4_controle.versoes`.

Um SELECT publicado não modifica os registros nem substitui automaticamente outra consulta. Seu arquivo fica na main; sua execução e seu resultado ficam registrados. Uma migração ALTER TABLE muda a estrutura da tabela de destino.

## Conferir a publicação no pgAdmin

```sql
SELECT versao, arquivo, commit_sha, aplicado_em, resultado
FROM ws4_controle.versoes
ORDER BY versao;
```

Execute o conteúdo de um script SELECT no Query Tool para explorar seu resultado novamente. Os testes e os logs da aplicação são a evidência da versão que passou pelo PR.

## Validar localmente com Docker

Na raiz do clone, use um projeto separado para não alterar o banco da demonstração:

```bash
WS4_PROJECT=ws4-versoes-validacao bash demo.sh subir
WS4_PROJECT=ws4-versoes-validacao bash demo.sh base
WS4_PROJECT=ws4-versoes-validacao bash demo.sh inicio
docker compose -p ws4-versoes-validacao --profile validacao build validador
docker compose -p ws4-versoes-validacao --profile validacao run --rm validador
docker compose -p ws4-versoes-validacao --profile validacao run --rm -e WS4_TESTDB=1 validador python -m unittest discover -s tests -v
WS4_PROJECT=ws4-versoes-validacao bash demo.sh encerrar
```

A validação executa as versões em transação e desfaz suas alterações ao terminar. Nenhuma dependência Python precisa ser instalada no computador.

## Modelos complementares de DDL

Os arquivos em `modelos/` são exemplos solicitados para aprofundar a demonstração. Eles **não são aplicados automaticamente**. Copie uma etapa e seu teste para as pastas principais, ajuste ambos ao próximo número livre e publique um PR por etapa para observar o estado intermediário.

| Pasta | Demonstração |
|---|---|
| `modelos/pedidos/` | Adicionar created_at, deleted_at e active; criar identity em clientes e pedidos preservando ids existentes |
| `modelos/tipos/` | Criar uma tabela artificial com float e converter para int somente se não houver frações |
| `modelos/ddl/` | Criar tabela de teste, adicionar coluna, alterar tipo e remover coluna/tabela de teste |
| `modelos/compatibilidade/` | Renomear coluna, detectar quebra de consulta, adaptar o SELECT e alterar somente o comentário do campo |
| `modelos/testes/` | Testes correspondentes, para copiar junto com cada script |

Os modelos podem ter números iguais entre alternativas. Essa numeração deve ser ajustada ao promovê-los: o catálogo ativo exige números únicos. Respeite a ordem das dependências, como criar uma tabela antes de alterar sua coluna.

### Metadados de pedidos

`created_at` e `deleted_at` são timestamp sem fuso no modelo, e `active` é boolean com padrão true. O modelo não inventa datas históricas: created_at fica nulo para os pedidos existentes. deleted_at nulo não exclui uma linha, e active é uma flag; sua presença sozinha não muda a regra de pedidos pagos.

### Identificadores sequenciais

O modelo usa `GENERATED BY DEFAULT AS IDENTITY`. Preserva os ids e sincroniza as novas sequências com o maior id existente. Na base original, os próximos ids serão 5 para clientes e 106 para pedidos quando uma inserção omitir o id. Sequências podem ter lacunas e não prometem uma numeração sem interrupções.

### Float para inteiro

O valor financeiro do caso é numeric(12,2), não float. A conversão é demonstrada em `ws4_demo.metricas`, com dados artificiais. O script rejeita frações antes da conversão: um valor como 12.7 impede a release em vez de ser arredondado silenciosamente. Uma conversão de tipo real exige avaliar também limites do tipo e impacto nas dependências.

## Limites da simulação

O workflow valida as regras implementadas e o resultado esperado fornecido. Isso não prova todos os cenários possíveis de uma base produtiva. O laboratório usa dados fictícios; as migrações permitidas ficam nas tabelas de teste ou nas ampliações explicitamente previstas para pedidos e identity. Clientes e pedidos mantêm seus registros originais.

## Compatibilidade entre esquema e consultas

No final do lote, o validador reexecuta as consultas vigentes. Por padrão, cada SELECT é um contrato independente. Para publicar uma nova implementação do mesmo relatório, os dois testes devem declarar o mesmo campo `contrato`; a maior versão é a vigente. O arquivo antigo permanece no histórico. Leia o [caso completo de alteração de coluna](../docs/alteracao-coluna-e-rastreabilidade.md). Uma mudança manual fora do fluxo exige auditoria do PostgreSQL para identificar o autor; o Git não registra comandos externos automaticamente.

## Tags e releases

Após a confirmação no banco, a automação publica tags anotadas `bd-vNNNN` e releases no GitHub, apontando para o commit registrado em cada versão. Veja [como conferir a release e seu commit](../docs/tags-e-releases.md).
