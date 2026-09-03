# Atividade — Regras de Integridade do Banco de Dados

---

# Identificação das regras de integridade

- Integridade de entidade: PRIMARY KEY em todas as tabelas (id_AERONAVE, id_PASSAGEIRO, id_TELEFONE, id_VOO). Garante que cada registro em uma tabela posssa ser identificado de forma única 
- Integridade referencial: FOREIGN KEY em TELEFONE_PASSAGEIRO(id_PASSAGEIRO) com PASSAGEIRO(id_PASSAGEIRO) e VOO(id_AERONAVE) com AERONAVE(id_AERONAVE). Evita telefones sem associação ou voos em aeronaves inexistentes
- Integridade de domínio: Aplicada nos dados DATETIME, INT, VARCHAR e o CHECK. Evita inserções inválidas
- Integridade de chave/Restrições de unicidade:  UNIQUE em cpf da tabela PASSAGEIRO e em (num_voo, dia_horario) da tabela VOO. Impede CPFs duplicados e voos iguais no mesmo horário
- Obrigatoriedade de preenchimento: NOT NULL nas colunas essenciais. Impede cadastros incompletos
- Regras relacionadas ao negócio do sistema: CHECK em validações específicas (capacidade > 0)

---

# Aplicação das regras de integridade

Tabela AERONAVE

```sql
CREATE TABLE IF NOT EXISTS `AERONAVE` (
  `id_AERONAVE` INT NOT NULL AUTO_INCREMENT,
  `modelo` VARCHAR(50) NOT NULL,
  `capacidade` INT NOT NULL,
  PRIMARY KEY (`id_AERONAVE`),
  CONSTRAINT `chk_capacidade_positiva` CHECK (`capacidade` > 0))
ENGINE = InnoDB;
```
- id_AERONAVE INT NOT NULL AUTO_INCREMENT & PRIMARY KEY (id_AERONAVE): Integridade de Entidade. Garante que cada aeronave tenha um identificador único
- modelo VARCHAR(50) NOT NULL & capacidade INT NOT NULL: Obrigatoriedade de Preenchimento (Domínios). Impede o cadastro de informações incompletas
- CONSTRAINT chk_capacidade_positiva CHECK (capacidade > 0): Integridade de Domínio. Impede a inserção de números de assentos iguais a zero ou negativos

Tabela PASSAGEIRO

```sql
CREATE TABLE IF NOT EXISTS `PASSAGEIRO` (
  `id_PASSAGEIRO` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `cpf` VARCHAR(11) NOT NULL,
  PRIMARY KEY (`id_PASSAGEIRO`),
  CONSTRAINT `cpf_UNIQUE` UNIQUE (`cpf`))
ENGINE = InnoDB;
```
- id_PASSAGEIRO INT NOT NULL AUTO_INCREMENT & PRIMARY KEY (id_PASSAGEIRO): Integridade de Entidade. Garante que cada passageiro tenha um identificador único
- nome VARCHAR(150) NOT NULL: Obrigatoriedade de Preenchimento (Domínios). Garante que cada passageiro possua um nome cadastrado
- cpf VARCHAR(11) NOT NULL & CONSTRAINT cpf_UNIQUE UNIQUE (cpf): Obrigatoriedade de Preenchimento e Restrição de Unicidade. Impede cadastros incompletos e que mais de um cadastro tenha um mesmo CPF 

Tabela TELEFONE_PASSAGEIRO

```sql
CREATE TABLE IF NOT EXISTS `TELEFONE_PASSAGEIRO` (
  `id_TELEFONE` INT NOT NULL AUTO_INCREMENT,
  `telefone` VARCHAR(15) NOT NULL,
  `id_PASSAGEIRO` INT NOT NULL,
  PRIMARY KEY (`id_TELEFONE`),
  CONSTRAINT `fk_TELEFONE_PASSAGEIRO`
    FOREIGN KEY (`id_PASSAGEIRO`)
    REFERENCES `PASSAGEIRO` (`id_PASSAGEIRO`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
    ENGINE = InnoDB;
```
- id_TELEFONE INT NOT NULL AUTO_INCREMENT & PRIMARY KEY (id_TELEFONE): Integridade de Entidade. Garante que cada telefone do passageiro tenha um identificador único
- telefone VARCHAR(15) NOT NULL: Integridade de Domínio e Obrigatoriedade de Preenchimento. Evita a inserção de textos longos e despadronizados e impede cadastros incompletos
- id_PASSAGEIRO INT NOT NULL & PRIMARY KEY (id_TELEFONE) & FOREIGN KEY (id_PASSAGEIRO) & REFERENCES PASSAGEIRO (id_PASSAGEIRO) & ON DELETE CASCADE & ON UPDATE CASCADE: Integridade Referencial. Faz a associação do passageiro e do telefone e o CASCADE garante a exclusão de todos os telefones automaticamente caso haja a exclusão do cadastro do passageiro 

Tabela VOO

```sql
CREATE TABLE IF NOT EXISTS `VOO` (
  `id_VOO` INT NOT NULL AUTO_INCREMENT,
  `num_voo` VARCHAR(45) NOT NULL,
  `origem` VARCHAR(100) NOT NULL,
  `destino` VARCHAR(100) NOT NULL,
  `dia_horario` DATETIME NOT NULL,
  `id_AERONAVE` INT NOT NULL,
  PRIMARY KEY (`id_VOO`),
  CONSTRAINT unq_voo_horario UNIQUE (num_voo, dia_horario),
  CONSTRAINT `chk_origem_destino_diferentes` CHECK (`origem` <> `destino`),
  CONSTRAINT `fk_voo_aeronave`
    FOREIGN KEY (`id_AERONAVE`)
    REFERENCES `AERONAVE` (`id_AERONAVE`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
    ENGINE = InnoDB;
```
- id_VOO INT NOT NULL AUTO_INCREMENT & PRIMARY KEY (id_VOO): Integridade de Entidade. Garante que cada voo tenha um identificador único
- num_voo VARCHAR(45) NOT NULL & origem VARCHAR(100) NOT NULL & destino VARCHAR(100) NOT NULL & dia_horario DATETIME NOT NULL: Obrigatoriedade de Preenchimento. Impede cadastros incompletos
- id_aeronave INT NOT NULLL & PRIMARY KEY (id_aeronave) & CREFERENCES PASSAGEIRO (id_PASSAGEIRO) & ON DELETE RESTRICT & ON UPDATE CASCADE: Integridade Referencial. Garante que todo voo esteja associado a uma aeronave existente e o RESTRIC impede a exclusão de uma aeronave enquanto ela possuir voos marcados

---

# Regras de negócio

- Regra de Unicidade do CPF do PASSAGEIRO: um CPF não pode pertencer a mais de um passageiro. Cláusula UNIQUE no atributo cpf da tabela PASSAGEIRO
- Regra da Capacidade Mínima da AERONAVE: a capacidade de uma aeronave é obrigatoriamente um valor positivo maior que zero. Restrição de checagem CONSTRAINT chk_capacidade_positiva CHECK (capacidade > 0) na tabela AERONAVE
- Regra de Agendamento Único de VOO: o mesmo código de voo não pode ser cadastrado mais de uma vez para o mesmo dia e horário. Restrição de unicidade composta CONSTRAINT unq_voo_horario UNIQUE (num_voo, dia_horario) na tabela VOO
- Rota Válida de VOO: o local de origem deve ser diferente do local de destino. Restrição de checagem CONSTRAINT chk_origem_destino_diferentes CHECK (origem <> destino)
  
---

# Testes das regras de integridade

Situação testada: Teste da Regra de Unicidade. Cadastrar duas pessoas com o mesmo CPF
Comando SQL utilizado:
```sql
INSERT INTO PASSAGEIRO (nome, cpf) VALUES ('Carlos Silva', '12345678901');

INSERT INTO PASSAGEIRO (nome, cpf) VALUES ('Mariana Santos', '12345678901');
```
- Resultado esperado: o SQL deve recusar o cadastro com o mesmo CPF e apresentar erro
- Resultado obtido: Error Code:1062.Duplicated entry '12345678901' for key 'PASSAGEIRO.cpf_UNIQUE'

---

Situação testada: Teste da Regra da Capacidade Mínima. Cadastrar uma aeronave com a capacidade <= 0
Comando SQL utilizado:
```sql
INSERT INTO AERONAVE (modelo, capacidade) VALUES ('Boeing 737', 0);
```
- Resultado esperado: o SQL deve recusar o cadastro da capacidade e apresentar erro
- Resultado obtido: Error Code:3819. Check constraint 'chk_capacidade_positiva' is violated

---

Situação testada: Teste da  Rota Válida de VOO. Cadastrar um voo com a origem e o destino iguais
Comando SQL utilizado:
```sql
INSERT INTO AERONAVE (modelo, capacidade) VALUES ('Embraer 195', 110);

INSERT INTO VOO (num_voo, origem, destino, dia_horario, id_AERONAVE) 
VALUES ('G3-1500', 'Brasília', 'Brasília', '2026-10-15 14:00:00', 1);
```
- Resultado esperado: o SQL deve recusar o cadastro do voo e apresentar erro
- Resultado obtido: Error Code:3819. Check constraint 'chk_origem_destino' is violated
