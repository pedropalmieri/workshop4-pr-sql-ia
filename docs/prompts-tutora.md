# Prompts curtos para IA como Tutora

A [biblioteca de prompts](../prompts/README.md) separa o contexto do caso das perguntas. Envie [00 · Contexto](../prompts/00-contexto-do-caso.txt) uma vez no início da conversa. Depois, use uma pergunta por tarefa, sem repetir toda a base de dados.

## Tarefas

| Tarefa | Prompt |
|---|---|
| Investigar clientes ausentes na consulta inicial | [01 · Diagnóstico](../prompts/01-diagnosticar-consulta.txt) |
| Examinar uma alteração feita pelo Fellow | [02 · Revisão](../prompts/02-revisar-alteracao-humana.txt) |
| Compreender cenários e resultados esperados | [03 · Testes](../prompts/03-planejar-testes-consulta.txt) |
| Explicar contagem, NULL e pagamento de valor zero | [04 · Agregações](../prompts/04-explicar-count-e-zero.txt) |
| Avaliar a hipótese de remover totais zero | [05 · Análise crítica](../prompts/05-avaliar-alternativa-com-evidencia.txt) |
| Interpretar um plano real | [06 · EXPLAIN](../prompts/06-interpretar-plano-execucao.txt) |
| Examinar evidências de um PR | [07 · Pull Request](../prompts/07-analisar-pull-request.txt) |
| Organizar a conversa e a validação reais | [08 · Registro](../prompts/08-organizar-registro-real.txt) |
| Retomar o papel de Tutora | [09 · Redirecionamento](../prompts/09-redirecionar-para-tutoria.txt) |

## Uso na conversa

Substitua os campos entre colchetes antes de enviar. Ao iniciar outra conversa ou trocar de IA, envie novamente o contexto 00. Não é necessário usar todos os prompts.

O Fellow implementa, executa, testa e decide. A IA explica e faz perguntas. Se entregar código pronto ou extrapolar a tarefa, use o prompt 09. A resposta precisa ser confrontada com os dados e os testes.

A hipótese do prompt 05 é apresentada pela pessoa, não uma sugestão espontânea da IA. O registro 08 deve refletir somente o que realmente ocorreu. Consulte o [contrato](contrato.md), o [uso da IA](uso-da-ia.md) e o [modelo de registro](registro-ia-modelo.md).
