## Prática: Privilégios no projeto do aeroporto

#### Quais privilégios aparecem no SHOW GRANTS?

GRANT USAGE ON *.* TO `app_aeroporto`@`localhost`

GRANT SELECT, INSERT, UPDATE ON `bd_aeroporto`.`voo`TO `app_aeroporto`@`localhost`

---

| Operação | Esperando | O que aconteceu? |
| :--- | :--- | :--- |
| Listar voos (SELECT) | Funciona | Funciona (os dados foram consultados e exibidos na listagem) |
| Criar voo (INSERT) | Funciona | Funciona (o voo novo foi gravado na base de dados depois de usar um ID de aeronave válido) |
| Editar voo (UPDATE) | Funciona | Funciona (as alterações nos dados do voo foram atualizados) |
| Excluir voo (DELETE) | Erro | Erro (gerou negação de privilégio pelo SGDB por falta da permissão DELETE, sendo contornado na aplicação pelo soft delete) |

Mensagem de erro: ERROR 1142 (42000) DELETE command denied to user 'app_aeroporto'@localhost' for table 'voo'

Mensagem de erro: ERROR 1142 (42000) DROP command denied to user 'app_aeroporto'@'localhost' for table 'voo'

---

- Na tabela usuarios, a Maria tem perfil de atendente. O que mudou para ela quando você trocou root por app_aeroporto? E o que mudou para a conexão?

  Nada mudou. A interface, as regras de negócio e os menus que ela tem acesso continuam os mesmos, porque a autenticação dela é gerida pela tabela usuarios na aplicação PHP. O que mudou para a conexão foi o nível de privilégio técnico utilizado pelo sistema para interagir com a base de dados. Em vez de usar o root, a aplicação passou a se autenticar com a conta app_aeroporto, limitando o que a aplicação pode executar.

- Quem decide se a Maria pode excluir um voo: o banco ou o código PHP? Por quê?
  
  O banco de dados. Embora o PHP possa ter os botões ou regras da interface, a segurança real é imposta pelo SGDB. Como a conta app_aeroporto não possui o privilégio DELETE, qualquer tentativa do código de executar um comando físico de remoção vai ser rejeitada pelo motor do banco com um erro de permissão. A aplicação apenas implementou um soft delete (UPDATE) para contornar essa restrição de forma controlada.

- Se alguém conseguisse uma SQL Injection nesta aplicação agora, o que o atacante ainda conseguiria fazer? E se a conexão ainda fosse root?
  
  app_aeroporto: o atacante estaria limitado aos privilégios concedidos a essa conta. Ele não conseguiria apagar as tabelas (DROP), alterar a estrutura do banco ou apagar registros fisicamente (DELETE).
  root: o atacante teria controle absoluto sobre todo o servidor da base de dados. Poderia ler dados confidenciais, apagar bases de dados inteiras, modificar utilizadores do SGDB ou executar comando no sistema operativo comprometendo a infraestrutura
