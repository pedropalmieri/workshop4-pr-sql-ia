# ChatGPT como tutora de SQL

## Ferramenta da atividade

Usaremos **ChatGPT, em conversa de texto no navegador**, para discutir os conceitos da consulta. O [contexto único e os prompts curtos](../prompts/README.md) também podem ser usados em outro assistente de linguagem; envie o contexto uma vez e depois a pergunta da tarefa. Eles não dependem de recursos específicos do ChatGPT. O modelo disponível na conta pode variar. Registre a ferramenta e o nome do modelo exibido, quando houver, sem depender de uma versão específica para reproduzir a atividade.

Os dados do exercício são fictícios. O ChatGPT não recebe credenciais e não se conecta ao PostgreSQL. As consultas são exploradas no pgAdmin, com o banco no Docker. Os testes usam o psql pelo terminal. O código é alterado no editor e validado pelos testes do repositório.

## Momento principal: após o teste com falha

1. Execute a consulta inicial e o teste.
2. Compare a ausência de Bruno e Carla com o contrato.
3. No ChatGPT, envie o prompt de diagnóstico disponível em [prompts-tutora.md](prompts-tutora.md).
4. Relacione a explicação recebida às linhas observadas com `bash demo.sh diagnosticar`.
5. Faça a alteração no editor e execute os testes novamente.

O papel de Tutora limita a tarefa a explicar e questionar. Neste exercício, não se delegam edição de arquivos, implementação completa ou decisão de merge.

## Momento complementar: análise de alternativas

Com o resultado em mãos, use o prompt de alternativas para discutir clientes de total zero ou a diferença entre ON e WHERE. Compare a resposta com o contrato e os testes. A discussão complementa o diagnóstico, sem substituir a execução.

Não é necessário usar todos os prompts durante o encontro. A intervenção principal é o diagnóstico do problema já observado. Os demais são material de consulta para aprofundamento.

## Registro

O [modelo de registro](registro-ia-modelo.md) reúne tarefa delegada, justificativa, orientação, decisão, validação e retrabalho. A sugestão aceita precisa de evidência, assim como uma rejeição.

Não invente uma sugestão incorreta ou uma conversa para preencher o registro. Avaliar uma hipótese apresentada pelo próprio aluno não significa que a IA a sugeriu. O [exemplo ilustrativo](registro-ia-exemplo.md) é fictício e serve apenas para explicar o formato.

Se a resposta vier com código pronto, peça uma explicação conceitual e perguntas, conforme o prompt de redirecionamento. Se o serviço estiver indisponível, a análise pode continuar com os dados e o SQL comentado. Nesse caso, não haverá uma interação real de IA a registrar.

## Revisão no GitHub com Copilot

Como complemento solicitado para o laboratório, o repositório contém instruções para orientar comentários de revisão SQL do Copilot. A conta atual está no Copilot Free; a revisão de PRs não está ativa. Veja [disponibilidade e configuração](revisao-copilot.md). A preparação não substitui a conversa de tutoria nem os testes executados no PostgreSQL, e não cria uma entrega adicional.
