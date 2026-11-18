# Guia de condução · 19/11/2026

Use junto dos 13 slides e do roteiro de tempo. Este guia concentra os comandos e as falas de apoio. Os exemplos adicionais são reserva, sem aumentar a duração.

## Antes de compartilhar a tela

- Abra o PowerPoint, editor, terminal, chat de IA e [PR de referência](https://github.com/pedropalmieri/workshop4-pr-sql-ia/pull/1).
- Aumente a fonte do terminal e do editor. Feche notificações que possam atrapalhar a apresentação.
- Deixe `docs/contrato.md`, `sql/02_consulta.sql` e `sql/03_testes.sql` disponíveis no editor.
- No terminal, entre em `~/projetos/workshop4-pr-sql-ia`. Confira `git status --short --branch` antes de trocar de branch.
- Execute `bash scripts/ensaio.sh` antes do encontro. Ele usa um banco separado e o remove ao terminar.
- Prepare o banco da aula com os comandos abaixo. O download da imagem deve terminar antes da apresentação.

```bash
bash demo.sh subir
bash demo.sh base
bash demo.sh aplicar
bash demo.sh consultar
```

Na `main`, a saída inicial inclui apenas Ana e Diego. Para manter o ensaio livre de alterações na `main`, crie uma branch própria conforme o laboratório Git.

## Sequência essencial da demonstração, 25 minutos

A parte prática reserva 18 minutos para conexão, leitura das consultas e diagnóstico, 2 para evidência e 5 para PR. Os 16 minutos iniciais de slides continuam apresentando o contrato, testes e papel da IA. As explicações detalhadas ficam em [Explicação das consultas](explicacao-das-consultas.md).

| Minutos da demonstração | Ação e fala principal |
|---|---|
| 00–02 | Execute `conexao`. Mostre banco, usuário e versão. Explique que o cliente e o banco estão no Docker. |
| 02–05 | Abra o contrato e calcule o resultado esperado com a turma. Destaque Bruno, Carla e Diego. |
| 05–11 | No `terminal`, execute os seis blocos de `exemplos/consultas-passo-a-passo.sql`, explicando a diferença no resultado de cada etapa. Use `\q` para sair. |
| 11–14 | Volte à consulta inicial, rode `consultar` e `testar`. Explique por que o WHERE elimina Bruno e Carla. Use `diagnosticar` apenas se necessário. |
| 14–16 | Pergunte à IA tutora sobre o filtro, sem pedir implementação. Discuta a explicação com a turma. |
| 16–18 | Corrija o SQL manualmente. Execute `aplicar`, `consultar` e `testar`. Compare quatro linhas e dois PASS. |
| 18–20 | Rode o script de evidência e mostre o modelo de registro. Identifique qualquer exemplo fictício como simulação. |
| 20–25 | Mostre diff, commit e PR. Prefira o PR de referência se a abertura ao vivo atrasar. Relacione o check ao teste visto localmente. |

Não é necessário mostrar todas as consultas extras de diagnóstico. As seis consultas progressivas explicam as peças do relatório. A consulta com erro demonstra como uma posição diferente do filtro quebra o requisito.

Fala sobre testes: “O resultado esperado vem do cálculo manual. A consulta em teste não determina sozinha o que seria correto.”

Fala sobre IA: “A IA me ajudou a entender o conceito. Eu fiz a alteração e conferi o resultado.” Use essa formulação apenas quando corresponder ao que ocorreu na demonstração.

## Cartão de comandos

```bash
bash demo.sh consultar
bash demo.sh testar
bash demo.sh diagnosticar
# Após a alteração manual do SQL:
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
bash scripts/registrar-evidencia.sh
git diff -- sql/02_consulta.sql
git status --short
```

Os comandos de commit e push estão em `docs/laboratorio-pr.md`. Não faça `git add .` sem conferir o que será enviado.

## Plano de recuperação

| Situação | Como continuar |
|---|---|
| A IA demora ou fica indisponível | Analise as linhas do JOIN com a turma. Mostre o prompt e um exemplo claramente simulado. |
| A resposta vem com código pronto | Redirecione para explicação conceitual e faça a alteração humana. |
| O GitHub não abre | Mostre `git diff`, o template de PR e as evidências locais. Explique que a demonstração remota ficou pendente. |
| O banco perdeu os dados | Execute `base` e `aplicar`. |
| A edição trava e falta tempo | Use `referencia`, identificando o gabarito preparado. O arquivo fonte não muda, então não faça commit fingindo tê-lo corrigido. |
| O banco já começa corrigido | Use `inicio` para demonstrar o erro ou reaplique o arquivo da main. |
| O tempo chega a 50 minutos | Encerre a prática. Faça a pergunta de COUNT em 2 minutos e use o fechamento previsto. |

## O que fica para depois

Explicação detalhada de EXCEPT ALL, novas regras de negócio, ETL e desempenho não são necessários durante a hora. O [SQL comentado](../docs/sql-comentado.md) e as [perguntas extras](perguntas-e-gabarito.md) ficam como apoio.

## Após o encontro

Execute `bash demo.sh encerrar` quando não precisar mais do banco. Preserve a branch da sua demonstração e os registros reais. O workshop não exige coleta de entregas dos alunos.
