# Atividade de 5 minutos · revisão da consulta

Discussão opcional em dupla ou squad. **Não exige envio, commit ou entrega própria.** É possível participar olhando a tela do instrutor, sem instalar ferramentas.

## Situação

O relatório inclui todos os clientes e conta apenas pedidos pagos. Ana tem dois pagos e um cancelado. Bruno tem somente cancelado. Carla não tem pedidos. Diego tem um pedido pago de valor zero.

Considere a condição correta:

```sql
FROM ws4.clientes c
LEFT JOIN ws4.pedidos p
  ON p.cliente_id = c.id AND p.status = 'pago'
```

## Discussão

**Primeiros 2 minutos:** discutam duas perguntas.

1. Se alguém trocar COUNT(p.id) por COUNT(*), qual será a contagem de Carla? Qual linha o banco está contando?
2. Diego deveria aparecer com contagem 0 ou 1? Por quê?

**Próximos 2 minutos:** uma dupla ou squad apresenta a conclusão. Outra pessoa aponta qual teste deveria detectar uma alteração incorreta.

**Último minuto:** o instrutor mostra `bash demo.sh contagem` e relaciona o resultado ao contrato.

## Para continuar depois, se quiser

Peça à IA uma explicação conceitual sobre contar linhas e contar chaves não nulas. Não peça a implementação. Compare a resposta com o resultado observado e registre sua decisão somente se tiver usado a ferramenta de fato.

O gabarito fica em `materiais/perguntas-e-gabarito.md` para consulta após a discussão.
