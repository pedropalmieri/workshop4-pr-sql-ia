# Conexão com PostgreSQL

## Caminho usado na apresentação

Os comandos abrem o cliente psql **dentro do contêiner**, conectando por TCP ao PostgreSQL em `127.0.0.1:5432`, com usuário `workshop`, banco `workshop` e a senha didática definida em `compose.yaml`. Não dependem de PostgreSQL ou psql instalado no computador.

Esse endereço é o localhost **do contêiner**. Nenhuma porta está publicada no Mac/Windows/Linux. Portanto, esses parâmetros não representam uma conexão direta a partir de Navicat, DBeaver ou outro cliente instalado no computador.

## Verificação rápida antes da aula

Na raiz do clone:

```bash
bash demo.sh subir
bash demo.sh conexao
```

Confira na saída:

| Campo | Esperado |
|---|---|
| Banco | workshop |
| Usuário | workshop |
| Endereço do servidor | 127.0.0.1 |
| Porta | 5432 |
| Versão | PostgreSQL 17.12 |

O comando mostra a conexão estabelecida, não apenas o estado do contêiner. O healthcheck com pg_isready informa se o servidor aceita conexões, mas sozinho não comprova a senha ou a execução de SQL.

O ambiente novo inicializa autenticação SCRAM para conexões TCP e locais. `scripts/ensaio.sh` verifica conexão correta e exige recusa de uma senha incorreta, antes de carregar e testar as consultas. A senha no compose é exclusivamente didática.

## Executar uma consulta por vez

```bash
bash demo.sh base
bash demo.sh terminal
```

No prompt `workshop=>`, use:

```sql
\conninfo
\pset null '(NULL)'
SELECT current_database(), current_user;
SELECT id, nome FROM ws4.clientes ORDER BY id;
```

Agora execute os blocos de `exemplos/consultas-passo-a-passo.sql` individualmente. O ponto e vírgula termina uma instrução SQL. Se o prompt mudar para `workshop->`, provavelmente a instrução está incompleta. `\r` limpa o buffer atual. `\q` sai do psql e volta ao terminal do computador.

Os comandos que começam com barra invertida pertencem ao psql, não ao SQL. A instrução SQL é executada pelo PostgreSQL. A distinção ajuda a explicar o que está acontecendo na tela.

Para executar todos os blocos de uma vez, sem modo interativo:

```bash
bash demo.sh passos
```

## Quando algo falhar

| Mensagem ou situação | Verificação |
|---|---|
| Não conecta ao Docker | Abra o Docker Desktop e execute docker info |
| Serviço db não está rodando | Execute bash demo.sh subir |
| Password authentication failed | Confira banco, usuário e configuração da aula. Use os comandos do kit, que repassam a senha definida no contêiner |
| Relação ws4.clientes não existe | Execute bash demo.sh base |
| View ws4.resumo_clientes não existe | Execute bash demo.sh aplicar depois da base |
| Contêiner saudável, mas consulta falha | A conexão e a correção da consulta são verificações diferentes. Leia o erro SQL e o contrato |

A mudança de autenticação exige inicialização de um contêiner novo. O `compose up` recria o serviço quando sua configuração muda. Como os dados são descartáveis, recarregue `base` e `aplicar` depois. Não use estes comandos para bancos pessoais ou de produção.
