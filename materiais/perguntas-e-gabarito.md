# Perguntas e gabarito do instrutor

Escolha conforme o tempo. Não é necessário percorrer todas durante a hora.

| Momento | Pergunta | Resposta esperada |
|---|---|---|
| Abertura | Executar sem erro garante correção? | Não. A consulta pode violar o requisito. Precisamos de resultado esperado e teste. |
| Contrato | Por que guardar o cliente sem pedidos? | O requisito pede todos os clientes. Ausência de pedidos é informação relevante aqui. |
| Diagnóstico | Quem desaparece no WHERE? | Bruno e Carla. Só Ana e Diego têm linhas pagas. |
| Diagnóstico | OR p.id IS NULL resolve tudo? | Não. Carla volta, mas Bruno tem cancelado com id e continua fora. |
| Correção | O que muda ao colocar status no ON? | A condição define os pedidos que correspondem. O LEFT JOIN preserva o cliente sem pagamento. |
| Agregação | Qual a contagem de Carla com COUNT(*)? | 1, por causa da linha preservada. COUNT(p.id) retorna 0. |
| Agregação | Por que Diego tem contagem 1 e total 0? | Há um pedido pago com chave preenchida e valor zero. |
| Agregação | COALESCE sozinho resolve o bug? | Não recupera uma linha eliminada pelo WHERE. |
| Modelagem | Podemos agrupar só por nome? | Clientes diferentes podem ter o mesmo nome. A chave é o id. |
| Testes | Por que comparar nas duas direções? | Para detectar tanto ausências como resultados extras. EXCEPT ALL considera multiplicidade. |
| Testes | Os totais corretos bastam? | Não. Presença, contagem e ausência de linhas extras também fazem parte do contrato. |
| IA | E se a IA mandar código pronto? | Redirecionar para Tutora e pedir explicação. O humano altera e valida. |
| IA | Podemos inventar uma sugestão rejeitada? | Não. O registro real precisa refletir a conversa e a evidência que ocorreram. |
| Git | Commit já cria um PR? | Não. Commit registra, push envia a branch e PR propõe integração com revisão. |
| Git | Trocar de branch muda o banco? | Não. É preciso reaplicar a consulta no banco. |
| Revisão | O que pedir no comentário do PR? | Um esclarecimento verificável, como apontar o teste que garante a presença de Carla. |

## Apoio a iniciantes

Peça primeiro o cálculo manual de Ana. Depois pergunte quem deve aparecer com zero. Mostre `diagnosticar` antes da agregação. A pessoa pode justificar o resultado em linguagem natural, sem escrever SQL de memória.

## Pergunta extra, se sobrar tempo

“Se um cliente tivesse dois pedidos pagos de mesmo valor, SUM(DISTINCT p.valor) seria seguro?”

Não. Valores iguais podem pertencer a pedidos diferentes e ambos devem entrar no total. O identificador do pedido distingue os eventos. Use apenas como discussão opcional, sem mudar a base durante o encontro.

## Encerramento

Peça a alguém que resuma qual regra estava quebrada, qual teste a detectou e que evidência uma pessoa revisora precisa conferir. Isso não é uma nova entrega da turma.
