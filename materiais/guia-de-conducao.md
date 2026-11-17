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

### 1. Requisito e resultado manual, 3 minutos

Abra o contrato e mostre as duas tabelas da base. Pergunte: “Qual deveria ser o resultado de Ana? E de Carla?”. Aguarde uma resposta antes de abrir a consulta.

Fala de apoio: “A regra pede todos os clientes. Isso inclui quem não pagou e quem nem tem pedido. Vamos usar essa regra para julgar o resultado.”

### 2. Erro e teste, 3 minutos

```bash
bash demo.sh consultar
bash demo.sh testar
```

Mostre o FAIL. Diga que a falha é esperada e exponha a diferença entre sintaxe válida e regra atendida. Não gaste o bloco explicando toda a estrutura DO do teste.

Fala de apoio: “O teste sabe o resultado porque nós o calculamos antes. A consulta em teste não é a fonte da resposta esperada.”

### 3. IA tutora e diagnóstico, 4 minutos

Use o primeiro prompt de `docs/prompts-tutora.md`. Peça explicação e perguntas, sem implementação. Se necessário, mostre:

```bash
bash demo.sh diagnosticar
```

Fala de apoio: “Carla fica com campos de pedido nulos. Bruno tem uma correspondência, mas cancelada. O WHERE elimina os dois. O filtro no ON permite que o LEFT JOIN preserve quem não tem pagamento.”

Se a IA gerar SQL pronto, peça que retorne ao papel de Tutora. Você faz a alteração no editor.

### 4. Correção e validação, 4 minutos

Em `sql/02_consulta.sql`, mova a condição de status para o ON, unida por AND à chave. Remova o WHERE antigo.

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Mostre quatro clientes e dois PASS. Pergunte por que Diego tem contagem 1 e total zero. O exemplo `contagem` pode ficar para o exercício final.

### 5. Evidência e decisão, 4 minutos

```bash
bash scripts/registrar-evidencia.sh
cp docs/registro-ia-modelo.md docs/registro-ia.md
```

Abra o arquivo de evidência cujo caminho o comando imprime. Mostre o código de saída 0 e explique o vínculo entre versão, execução e resultado.

No registro, escreva a tarefa conceitual delegada, o motivo, a orientação recebida e como você a validou. Para discutir uma rejeição, confronte uma alternativa com o contrato, sem inventar que a IA sugeriu algo que não sugeriu. Se o tempo não permitir uma interação real, mostre o registro fictício como simulação.

### 6. PR e revisão, 7 minutos

Mostre o diff e o commit da sua branch ou abra o PR nº 1 como referência previamente preparada. Ele está aberto e contém evidência local e check remoto. Não precisa realizar merge durante a aula.

Pergunta para revisão: “Onde está a evidência de que Carla precisa aparecer?”. Aponte contrato e teste. Depois mostre que novos commits na mesma branch atualizam o PR.

Não confunda comentário do próprio autor com aprovação independente. Um colega pode realizar a revisão real se isso tiver sido combinado.

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
