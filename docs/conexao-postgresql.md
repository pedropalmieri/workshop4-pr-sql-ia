# Conexão com PostgreSQL

## Arquitetura

O projeto usa dois contêineres: PostgreSQL no serviço `db` e pgAdmin no serviço `pgadmin`. O navegador acessa **http://localhost:5050**. O pgAdmin conecta internamente a **db:5432**, na mesma rede Docker.

O PostgreSQL não publica porta no computador. O endereço `127.0.0.1:5432` mostrado por `bash demo.sh conexao` pertence ao contêiner do banco e é usado pelo psql. Ele não é o endereço que deve ser cadastrado no pgAdmin.

## Servidor, banco, schema e cliente

| Conceito | Neste projeto | Função |
|---|---|---|
| Servidor | Serviço Docker db | Executa o PostgreSQL |
| Banco | workshop | Banco selecionado na conexão |
| Schema | ws4 | Organiza os objetos dentro do banco |
| Tabelas | ws4.clientes e ws4.pedidos | Armazenam os dados fictícios |
| View | ws4.resumo_clientes | Define o relatório após aplicar o SQL |
| Interface gráfica | pgAdmin no navegador | Explora os objetos e executa consultas |
| Cliente de terminal | psql no contêiner | Executa scripts e testes |

A conexão seleciona o banco. O schema identifica objetos dentro dele. Usamos nomes como `ws4.clientes` sem depender do search_path da sessão.

## Preparar e conferir

```bash
bash demo.sh interface
bash demo.sh base
bash demo.sh aplicar
bash demo.sh conexao
bash demo.sh estrutura
bash scripts/validar-interface.sh
```

No pgAdmin, o servidor **Workshop 4 - PostgreSQL** já está cadastrado. As credenciais da interface e a navegação pelo Query Tool estão em [pgAdmin](pgadmin.md). O usuário do banco é workshop e o schema é ws4. A view aparece após aplicar o SQL.

O healthcheck com pg_isready informa se o servidor aceita conexões. `conexao` comprova a execução de SQL pelo psql. `validar-interface.sh` verifica HTTP, autenticação e consulta a partir do contêiner do pgAdmin.

## Acesso pelo terminal, como alternativa

```bash
bash demo.sh terminal
```

O usuário didático criado pela imagem é superusuário; o prompt padrão é `workshop=#`.

```sql
\conninfo
SELECT current_database(), current_user;
SELECT id, nome FROM ws4.clientes ORDER BY id;
```

O ponto e vírgula termina uma instrução SQL. Se o prompt mudar para `workshop-#`, a instrução ainda está em composição. `\r` limpa o buffer e `\q` sai do psql. Esses comandos de barra invertida são exclusivos do psql. No Query Tool, utilize somente SQL, como os blocos de [consultas-pgadmin.sql](../exemplos/consultas-pgadmin.sql).

## Endereços e credenciais

| Finalidade | Endereço ou credencial |
|---|---|
| pgAdmin no navegador | localhost:5050 |
| Login do pgAdmin | workshop@example.com / pgadmin_local |
| PostgreSQL visto pelo pgAdmin | db:5432 |
| Banco e usuário PostgreSQL | workshop / workshop |
| Senha PostgreSQL | workshop_local |
| PostgreSQL visto pelo psql dentro de db | 127.0.0.1:5432 |

As senhas são didáticas. O acesso à interface fica limitado ao próprio computador. O cadastro e a senha de conexão do banco são carregados na inicialização, conforme os arquivos de pgadmin/.

## Persistência

O volume pgadmin-data mantém as configurações e sessões da interface. Os dados PostgreSQL são descartáveis. Se o contêiner do banco for parado, recarregue base e aplicar. Uma troca de branch altera arquivos, sem reaplicar a definição da view automaticamente.

## Problemas comuns

| Situação | Verificação |
|---|---|
| Interface não abre | Confira o Docker e execute demo.sh interface |
| Porta 5050 ocupada | Use PGADMIN_PORT=5051 bash demo.sh interface |
| Login rejeitado | Use as credenciais da interface, não as do banco |
| Servidor cadastrado não conecta | Host db, porta 5432 e banco workshop |
| ws4.clientes não existe | Execute demo.sh base |
| resumo_clientes não existe | Execute demo.sh aplicar depois de base |
| Query Tool acusa erro em barra invertida | Utilize a versão consultas-pgadmin.sql |

Referências: [psql](https://www.postgresql.org/docs/current/app-psql.html) e [pgAdmin em Docker](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html).
