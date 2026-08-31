## Comparação com o SQL

Aplicação da 1FN, 2FN, 3FN, 4FN e 5FN

1FN (Primeira Forma Normal): A criação da tabela TELEFONE_PASSAGEIRO isola múltiplos telefones, garantindo a 1FN.

2FN (Segunda Forma Normal): As tabelas possuem chaves primárias simples (INT AUTO_INCREMENT).

3FN (Terceira Forma Normal): Os dados de modelo/capacidade dependem de id_AERONAVE, origem/destino dependem de id_VOO, e nome/CPF dependem de id_PASSAGEIRO.

4FN (Quarta Forma Normal): O criação da tabela TELEFONE_PASSAGEIRO trata a dependência multivalorada.

5FN (Quinta Forma Normal): Eliminar dependências de junção.

## Justificativa

Criação da tabela TELEFONE_PASSAGEIRO: Atende à 1FN e à 4FN ao tirar o atributo multivalorado de telefone da tabela PASSAGEIRO. Impede repetições de linhas de passageiros ou limitação de um número.

## Justificativa das Não Alterações

2FN e 3FN: Não exigiram refatoração nas tabelas base porque todas utilizam chaves primárias automáticas simples de coluna única.

5FN: Não exigiu porque o modelo não possui dependências de junção complexas.
