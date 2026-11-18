# Exemplo ilustrativo de registro de decisões

Este exemplo é fictício. Não documenta uma conversa real com IA.

## Sugestão aceita

Tarefa delegada: explicar o desaparecimento dos clientes, pois eu ainda precisava compreender o filtro após o JOIN. A tutora sugeriu examinar a diferença entre a condição de correspondência no ON e o filtro no WHERE. Aceitei a orientação e movi manualmente o filtro de status para o ON. Antes, apareciam apenas Ana e Diego. Depois, apareceram os quatro clientes com os valores do contrato. Executei os dois cenários de sql/03_testes.sql. A IA explicou o conceito, eu alterei e validei o SQL.

## Sugestão rejeitada

Em uma discussão simulada, a tutora sugeriu excluir clientes de total zero para simplificar. Rejeitei porque o contrato exige todos os clientes. Bruno e Carla precisam aparecer mesmo sem pagamento. Diego também tem total zero, mas tem um pedido pago. A evidência é o contrato calculado manualmente e o teste que exige as quatro linhas. Retrabalho: mantive a inclusão dos clientes e a contagem por id do pedido.
