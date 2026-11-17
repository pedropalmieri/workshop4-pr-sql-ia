# Prompts para IA como tutora

Use um chat em modo de conversa. Evite agentes que editam arquivos e geração automática de solução neste exercício. O instrutor explica que esta restrição vem do degrau Tutora do briefing da Sprint 1.

## Diagnóstico

"Você é minha tutora de SQL. Não escreva a consulta corrigida nem edite arquivos. O requisito exige todos os clientes. Minha consulta usa LEFT JOIN e depois WHERE p.status = 'pago'. Bruno só tem pedidos cancelados e Carla não tem pedidos. Ambos desapareceram. Explique a ordem lógica relevante e faça duas perguntas para eu localizar o erro."

## Testes

"Sem escrever SQL, sugira casos de teste para contar pedidos pagos por cliente, incluindo clientes sem pedidos. Explique o resultado esperado de cada caso. Eu vou implementar e executar os testes."

## Discussão de uma alternativa

"Um colega propôs remover clientes com total zero para simplificar o relatório. Compare a ideia com este requisito: todos os clientes devem aparecer e um pedido pago de valor zero é válido. Não escreva código. Que evidência permitiria aceitar ou rejeitar a ideia?"

## Se a IA gerar código pronto

"Retorne ao papel de tutora: explique o conceito e faça perguntas, sem implementar. Vou escrever a alteração e validá-la."

Respostas de IA são variáveis. Registre somente o que realmente ocorreu. O exemplo de sugestão rejeitada do material é uma simulação didática e não deve ser apresentado como interação real.
