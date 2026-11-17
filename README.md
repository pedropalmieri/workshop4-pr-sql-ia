# Workshop 4: prática com PostgreSQL

Repositório de apoio: https://github.com/pedropalmieri/workshop4-pr-sql-ia

**A branch `main` contém o erro intencional para a demonstração.** A correção de referência fica na branch `fix/clientes-sem-pagamento`, em PR separado. O arquivo em `solucao/` é apoio prévio do instrutor. Os slides editáveis e o roteiro estão em `materiais/`.

```bash
git clone https://github.com/pedropalmieri/workshop4-pr-sql-ia.git
cd workshop4-pr-sql-ia
```

Como o repositório é privado, o clone exige autenticação e autorização na conta.

Encontro de 19/11/2026. Caso didático: relatório de clientes e pedidos pagos. A consulta inicial tem um erro intencional. O workshop não tem entregável próprio, conforme o briefing. O enunciado oficial do Desafio Final continua sendo a referência para sua entrega.

## Preparação

Requisitos no computador: Docker Desktop em execução com Docker Compose, Git, editor de texto e Bash. No Windows, usar Git Bash ou WSL com integração do Docker habilitada. Não é necessário instalar PostgreSQL, psql ou Python na máquina.

Abra o terminal na raiz deste repositório. Todos os comandos abaixo pressupõem esta pasta. A imagem é `postgres:17.12-alpine`, disponível para arquiteturas usuais do Docker. O primeiro uso precisa de internet para baixar a imagem. Não há porta de banco publicada, evitando conflito com bancos locais. Os dados são descartáveis, mantidos em memória pelo contêiner. Se o contêiner parar, execute `base` e `aplicar` novamente.

```bash
bash demo.sh subir
bash demo.sh base
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Na versão inicial, a consulta retorna **Ana e Diego**, e o teste termina com `FAIL` e código de saída diferente de zero. Essa falha é proposital. `base` recarrega os dados fictícios e `aplicar` instala a consulta que estiver em `sql/02_consulta.sql`.

## Diagnóstico e correção

Leia `docs/contrato.md`. Use `docs/prompts-tutora.md` para obter uma explicação, sem pedir código pronto. Altere manualmente `sql/02_consulta.sql`: mova `p.status = 'pago'` do `WHERE` para a condição `ON`, combinando-a com a chave do cliente por `AND`. Remova o `WHERE` antigo. Mantenha `COUNT(p.id)` e `COALESCE(SUM(p.valor), 0)`.

```bash
bash demo.sh aplicar
bash demo.sh consultar
bash demo.sh testar
```

Agora devem aparecer os quatro clientes do contrato e dois avisos `PASS`. O arquivo `solucao/02_consulta.sql` é uma referência de recuperação para o instrutor, escrita previamente. Ele não representa uma solução produzida pela IA durante a aula.

Para capturar a saída real da versão corrigida, incluindo avisos do PostgreSQL e o código de saída:

```bash
{
  echo 'Comando: bash demo.sh consultar'
  bash demo.sh consultar
  echo 'Comando: bash demo.sh testar'
  bash demo.sh testar
  resultado=$?
  echo "Codigo de saida dos testes: $resultado"
} > docs/evidencias.txt 2>&1
cat docs/evidencias.txt
```

Preencha `docs/registro-ia.md` a partir do modelo. Registre as interações reais, incluindo tarefa, motivo da delegação, validação, falhas e retrabalho. O arquivo de exemplo está identificado como simulação.

## Git e Pull Request

Use uma nova branch a partir de `main` para ensaiar a correção, ou consulte o PR de referência. A base já está versionada. Para repetir a abertura de um PR durante a aula, use outro nome de branch, por exemplo `aula/correcao-clientes`. A pasta `.github` já está na raiz e contém o template do PR e a validação automatizada.

O fluxo é: branch de correção, alteração, testes, registro, commit, push, abertura do PR, revisão, ajustes e nova validação. A configuração do GitHub Actions é opcional e roda os mesmos testes com Docker no runner. Ele só executará depois que o material estiver no GitHub e o workflow estiver habilitado. Sua execução remota não foi validada neste kit.

## Encerramento

```bash
bash demo.sh encerrar
```

Isso remove apenas os recursos do projeto Docker `ws4-workshop`. Não executa limpeza global do Docker. Para repetir a demonstração, restaure manualmente a consulta inicial ou use uma cópia limpa do kit, depois execute `subir`, `base` e `aplicar`.

## Se algo falhar

- Docker não conecta: abra o Docker Desktop e aguarde o mecanismo iniciar. Confira `docker info`.
- Imagem não baixa: faça o download antes do encontro. Depois de baixada, a parte SQL local funciona sem internet.
- Banco reiniciou ou relação não existe: execute `bash demo.sh base` e `bash demo.sh aplicar`.
- Teste falha após a correção: compare os quatro resultados com o contrato, verifique o filtro no ON e confira `COUNT(p.id)`.
- GitHub ou IA indisponível: use o diff local e os exemplos explicitamente simulados. Não apresente isso como um PR ou interação real.

## Referências técnicas

- [PostgreSQL: JOIN](https://www.postgresql.org/docs/current/tutorial-join.html)
- [PostgreSQL: funções de agregação](https://www.postgresql.org/docs/current/functions-aggregate.html)
- [GitHub: Pull requests](https://docs.github.com/en/pull-requests/reference/pull-requests)
