# Prompts especializados para IA como Tutora

Os prompts estão organizados em [prompts/README.md](../prompts/README.md), com arquivos de texto prontos para copiar e apresentar à turma. Podem ser usados no ChatGPT ou em outro assistente de linguagem, sem depender de licença Copilot ou integração com o GitHub.

## Contexto e tarefa em cada prompt

Cada prompt completo informa o papel de Tutora, a estrutura das tabelas, os dados fictícios, o contrato e o resultado esperado. Em seguida, delimita uma tarefa e o formato da resposta. Isso permite mudar de ferramenta sem depender de uma conversa anterior.

| Tarefa | Prompt |
|---|---|
| Diagnosticar a consulta inicial e investigar clientes ausentes | [01 · Diagnóstico](../prompts/01-diagnosticar-consulta.txt) |
| Revisar uma alteração feita pelo Fellow | [02 · Revisão conceitual](../prompts/02-revisar-alteracao-humana.txt) |
| Compreender os cenários de teste | [03 · Testes](../prompts/03-planejar-testes-consulta.txt) |
| Explicar COUNT(*), COUNT(p.id), NULL, SUM e zero | [04 · Agregações](../prompts/04-explicar-count-e-zero.txt) |
| Avaliar a hipótese de remover totais zero com evidência | [05 · Análise crítica](../prompts/05-avaliar-alternativa-com-evidencia.txt) |
| Interpretar um plano real de execução | [06 · EXPLAIN](../prompts/06-interpretar-plano-execucao.txt) |
| Examinar diff, testes e rastreabilidade de um PR | [07 · Pull Request](../prompts/07-analisar-pull-request.txt) |
| Organizar um registro sem inventar interações | [08 · Registro real](../prompts/08-organizar-registro-real.txt) |
| Corrigir uma resposta que saiu do papel de Tutora | [09 · Redirecionamento](../prompts/09-redirecionar-para-tutoria.txt) |

## Limites do uso

O Fellow implementa, executa, testa e decide. Os prompts pedem explicações e perguntas, sem código corrigido completo, patches ou aprovação de merge. Também distinguem fatos, hipóteses e informações ausentes.

O plano de resposta solicitado não garante que qualquer modelo siga todas as instruções. Se houver código pronto, conclusão sem evidência ou ampliação do escopo, use o prompt 09 e avalie criticamente a resposta.

O prompt 05 apresenta uma hipótese da própria pessoa. Registre essa origem. O prompt 08 organiza apenas a conversa e a validação reais. Nenhuma sugestão aceita ou rejeitada deve ser fabricada para preencher o registro.

A análise não cria entrega adicional. O [uso da IA](uso-da-ia.md), o [contrato](contrato.md) e o [modelo de registro](registro-ia-modelo.md) completam a documentação da atividade.
