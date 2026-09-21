## Comportamento nos Testes

Sessão 1: Executa o SELECT... FOR UPDATE e mantém o bloqueio ativo sobre o registro do assento 10A.
Sessão 2: Ao tentar executar o mesmo SELECT... FOR UPDATE simultaneamente, a Sessão 2 é suspensa (colocada em espera) pelo SGBD.
Liberação: Assim que a Sessão 1 conclui com o COMMIT, a Sessão 2 ganha o controle. Ao revalidar o status, ela percebe que o assento já está como RESERVADO, abortando a operação de forma segura (ROLLBACK)

--- 

## Perguntas para discussão

- Por que uma consulta simples de disponibilidade não é suficiente para proteger uma reserva?
Porque ela cria uma condição de corrida. Em sistemas concorrentes, duas ou mais pessoas podem consultar a mesma vaga simultaneamente, ver que ela está livre e tentar reservá-la ao mesmo tempo.
- Qual é a finalidade do FOR UPDATE?
O FOR UPDATE é utilizado para bloquear (fazer um lock) nas linhas retornadas por uma consulta até que a transação atual seja encerrada (commit ou rollback).
- Quando o bloqueio é liberado?
O bloqueio é liberado quando o COMMIT ou o ROLLBACK é acionado. 
- O que acontece com a segunda sessão enquanto a primeira mantém o bloqueio?
Se a segunda sessão tentar modificar os dados, utilizando comandos como o UPDATE, DELETE ou outro SELECT... FOR UPDATE nas mesmas linhas, ela ficará suspensa (aguardando em fila). Assim que a primeira sessão der o COMMIT ou ROLLBACK, a segunda sessão sai da fila.
Se a segunda sessão tentar ler os dados, a leitura não é bloqueada. A segunda sessão terá acesso aos dados antigos (antes da primeira sessão iniciar as modificações).
- Por que a segunda transação precisa validar novamente o status do assento?
Porque, enquanto a segunda sessão estava na fila, a primeira sessão concluiu a reserva e alterou o status do assento para RESERVADO. Se a segunda sessão não checar novamente, ela poderá sobrescrever ou inserir uma reserva inválida.
- O que é uma condição de corrida?
É uma falha que ocorre quando o resultado de um sistema depende da ordem exata em que os processos ou transações são executados.
- Qual é a diferença entre bloqueio e MVCC?
O bloqueio restringe o acesso direto aos dados para evitar conflitos de escrita. Já o MVCC cria versões históricas dos dados, permitindo que leituras ocorram de forma concorrente com escritas sem que uma trave a outra.
- Como ocorre um deadlock?
Ocorre quando dias ou mais transações se bloqueiam mutuamente. Nenhuma das duas podem avançar, criando um impasse eterno que força o SGDB a cancelar uma delas.
- Por que adquirir bloqueios sempre na mesma ordem pode reduzir deadlocks?
Poque elimina a condição de espera circular. Se todas as transações do sistema decidirem sempre bloquear os recursos na mesma sequência, a segunda transação simplesmente esperará na fila de forma linear em vez de cruzar os caminhos de bloqueio.
- Qual é a diferença entre READ COMMITTED, REPEATABLE READ e SERIALIZABLE?
READ COMMITED: Cada comando lê apenas dados já confirmados. Mudanças feitas por outras transações podem ser vistas entre um comando e outro dentro da mesma transação
REPEATABLE READ: Garante que todas as leituras feitas dentro da transação vejam a mesma versão dos dados existente no momento que a transação começou, evitando leituras fantasmas ou inconsistentes
SERIALIZABLE: Simula uma execução totalmente sequencial das transações para garantir máxima consistência, abortando operações caso detecte qualquer risco de conflito
- Por que uma restrição UNIQUE pode ser importante mesmo quando a aplicação já valida a disponibilidade?
Validações na aplicação falham se houver múltiplas instâncias do sistema rodando em paralelo. A restrição UNIQUE na banco atua como a última linha de defesa, garantindo a integridade física dos dados diretamente no motor de armazenamento.
- Como a aplicação deve tratar uma transação abortada por deadlock ou falha de serialização?
A aplicação deve capturar o erro retornado pelo banco de dados, efetuar um ROLLBACK interno e implementar uma estratégia de nova tentativa automática após um breve intervalo de espera.
