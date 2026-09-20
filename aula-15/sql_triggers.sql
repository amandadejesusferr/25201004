-- ===========================================
-- Aluno: Amanda de Jesus Ferreira 
-- Curso: Ciência da Computação 
-- Banco de dados: bd_aeroporto
-- Descrição: Modelo de gestão aeroportuária
-- Logs de auditoria e triggers
-- ===========================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema bd_aeroporto
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `bd_aeroporto` ;

-- -----------------------------------------------------
-- Schema bd_aeroporto
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bd_aeroporto` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `bd_aeroporto` ;

-- -----------------------------------------------------
-- Table `AERONAVE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `AERONAVE` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `AERONAVE` (
  `id_AERONAVE` INT NOT NULL AUTO_INCREMENT,
  `modelo` VARCHAR(50) NOT NULL,
  `capacidade` INT NOT NULL,
  `status` VARCHAR(30) NOT NULL DEFAULT 'DISPONIVEL',
  PRIMARY KEY (`id_AERONAVE`),
  CONSTRAINT `chk_capacidade_positiva` CHECK (`capacidade` > 0))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `PASSAGEIRO`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `PASSAGEIRO` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `PASSAGEIRO` (
  `id_PASSAGEIRO` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `cpf` VARCHAR(11) NOT NULL,
  PRIMARY KEY (`id_PASSAGEIRO`),
  CONSTRAINT `cpf_UNIQUE` UNIQUE (`cpf`))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `TELEFONE_PASSAGEIRO`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `TELEFONE_PASSAGEIRO` ;

SHOW WARNINGS;
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

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `VOO`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `VOO` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `VOO` (
  `id_VOO` INT NOT NULL AUTO_INCREMENT,
  `num_voo` VARCHAR(45) NOT NULL,
  `origem` VARCHAR(100) NOT NULL,
  `destino` VARCHAR(100) NOT NULL,
  `data_partida` DATETIME NOT NULL,
  `data_chegada` DATETIME NOT NULL,
  `id_AERONAVE` INT NOT NULL,
  PRIMARY KEY (`id_VOO`),
  CONSTRAINT `chk_origem_destino_diferentes` CHECK (`origem` <> `destino`),
  CONSTRAINT `fk_voo_aeronave`
    FOREIGN KEY (`id_AERONAVE`)
    REFERENCES `AERONAVE` (`id_AERONAVE`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
    ENGINE = InnoDB;

SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `LOG_VOO` (
	id_log INT NOT NULL AUTO_INCREMENT,
    id_VOO INT NOT NULL,
    num_voo_antigo VARCHAR(45),
    num_voo_novo VARCHAR(45),
    data_partida_antiga DATETIME,
    data_partida_nova DATETIME,
    data_chegada_antiga DATETIME,
    data_chegada_nova DATETIME,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) DEFAULT (CURRENT_USER),
    PRIMARY KEY (id_log)
) ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

DELIMITER //

CREATE TRIGGER trg_auditoria_voo
AFTER UPDATE ON VOO
FOR EACH ROW
BEGIN
	INSERT INTO LOG_VOO (
		id_voo,
        num_voo_antigo,
        num_voo_novo,
        data_partida_antiga,
		data_partida_nova,
		data_chegada_antiga,
		data_chegada_nova
	)
    VALUES (
		NEW.id_VOO,
        OLD.num_voo,
        NEW.num_voo,
        OLD.data_partida,
        NEW.data_partida,
        OLD.data_chegada,
        NEW.data_chegada
        );
END //
CREATE TRIGGER trg_valida_voo
BEFORE UPDATE ON VOO
FOR EACH ROW
BEGIN
	IF NEW.data_partida >= NEW.data_chegada THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'A data/hora de partida não pode ser posterior ou igual à de chegada.';
	END IF;
END //

CREATE TRIGGER trg_sincroniza_aeronave
AFTER INSERT ON VOO
FOR EACH ROW
BEGIN
	UPDATE AERONAVE
    SET status = 'EM VOO'
    WHERE id_AERONAVE = NEW.id_AERONAVE;
END //

DELIMITER ;

-- TESTES

-- INSERIR AERONAVE

INSERT INTO AERONAVE (modelo, capacidade, status) VALUES ('Boeing 737', 150, 'DISPONIVEL');

-- INSERIR VOO VÁLIDO

INSERT INTO VOO (num_voo, origem, destino, data_partida, data_chegada, id_AERONAVE)
VALUES ('VOO-101', 'BSB', 'GRU', '2026-12-10 10:00:00', '2026-12-10 15:00:00', 1);

-- TESTAR SINCRONIZAÇÃO

SELECT * FROM AERONAVE;

-- TESTE DO UPDATE

UPDATE VOO
SET num_voo = 'VOO-MODIFICADO'
WHERE id_VOO = 1;

-- AUDITORIA

SELECT * FROM LOG_VOO;

-- TESTE VOO INVÁLIDO

UPDATE VOO
SET data_partida = '2026-12-10 18:00:00',
	data_chegada = '2026-12-10 12:00:00'
WHERE id_VOO = 1;
