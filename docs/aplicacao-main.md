# Publicação da develop para a main e execução no banco

A [pasta consultas/](../consultas/README.md) contém os scripts numerados e seus testes. O [guia completo](fluxo-develop-main.md) mostra como criar uma versão, validar, abrir PR e conferir o banco.

## Fluxo atual

1. Altere a develop. Novos scripts são adicionados a `consultas/`, sem modificar versões já incorporadas à main.
2. O push executa os checks em bancos temporários do GitHub. Não publica no banco da demonstração.
3. Abra um PR com origem develop e destino main. A origem e os quatro checks são obrigatórios.
4. Revise o diff e confirme o merge. A proteção também vale para administradores.
5. Um merge que altera `consultas/` ou `sql/` dispara a aplicação no PostgreSQL existente do laboratório.
6. Confira o log, o resumo e o histórico de versões no banco.

```sql
SELECT versao, arquivo, commit_sha, execucao, aplicado_em, resultado
FROM ws4_controle.versoes
ORDER BY versao;
```

O SELECT de um script de consulta produz linhas, mas não cria automaticamente uma nova tabela nem altera pedidos. O código fica publicado no Git e sua execução fica registrada no histórico. Um script DDL, por sua vez, pode alterar a estrutura indicada no modelo.

## Validações do catálogo

O check `versoes` confere nomes e números únicos, presença dos testes, preservação do histórico em relação à base do PR, sintaxe do PostgreSQL 17, comandos permitidos no laboratório e resultados esperados. Também executa testes positivos e negativos dos modelos.

A execução registra o hash conjunto do SQL e do teste. Uma versão aplicada é preservada; alteração posterior do mesmo arquivo é rejeitada. Uma nova correção deve usar o próximo número. Scripts e testes removidos ou renomeados também são rejeitados.

Os testes de SELECT declaram o resultado esperado. Os testes de DDL verificam a estrutura criada ou alterada. Uma saída com nomes de coluna repetidos é rejeitada: use aliases claros.

## Transação e repetição

O lote de versões novas do catálogo é executado em uma transação. Se um script ou teste falhar, nenhuma dessas versões novas é confirmada. O histórico já existente permanece. Repetir a aplicação não executa novamente versões com o mesmo hash.

O exercício anterior em `sql/` mantém seu próprio fluxo transacional e os estados inicial/corrigido. Ele só é reaplicado quando `sql/` muda ou em acionamento manual. Sua transação é separada do lote do catálogo. A publicação de uma nova consulta em `consultas/` não substitui automaticamente a consulta desse exercício.

## Configuração e disponibilidade

O executor Docker `workshop4-docker` usa a rede do PostgreSQL do laboratório. Não é usado nos jobs de PR. A aplicação confere o commit mesclado e a validação final do PR. Fechar sem merge, usar outra origem ou fazer apenas push na develop não aplica os scripts nesse banco.

Docker Desktop, banco e executor precisam estar ligados. O PostgreSQL usa armazenamento temporário: encerrar ou recriar seu contêiner descarta dados e histórico local. Nesse caso, prepare novamente a base; o catálogo pode ser reconstruído a partir dos scripts preservados no Git.

O acionamento manual em Actions permite reaplicar a main. Isso executa somente versões ainda não registradas, além do exercício anterior quando solicitado pelo fluxo manual.

## Exercício anterior de consultas

O relatório `ws4.resumo_clientes` e `sql/estado-demonstracao.txt` preservam a investigação do Workshop 4. No estado inicial, o contrato deve falhar por ausência de Bruno e Carla. No corrigido, os dois cenários devem passar. O teste de reprodução da falha não equivale à aprovação do contrato de negócio.

A correção e o retorno estão registrados nos PRs nº 1 e nº 2. Para novas consultas e releases, use o catálogo numerado. A [arquitetura](arquitetura-automacao.md) e os [registros de validação](validacao/) explicam a implementação e o histórico.
