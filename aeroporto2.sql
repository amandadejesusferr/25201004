SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP SCHEMA IF EXISTS `aeroporto2` ;

CREATE SCHEMA IF NOT EXISTS `aeroporto2` DEFAULT CHARACTER SET utf8 ;
SHOW WARNINGS;
USE `aeroporto2` ;

DROP TABLE IF EXISTS `aeronave` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `aeronave` (
  `id_aeronave` INT NOT NULL AUTO_INCREMENT,
  `modelo` VARCHAR(45) NOT NULL,
  `fabricante` VARCHAR(45) NOT NULL,
  `quantidade_assentos` INT NOT NULL,
  PRIMARY KEY (`id_aeronave`),
  CONSTRAINT `chk_quantidade_assentos` CHECK (`quantidade_assentos` > 0))
ENGINE = InnoDB;

SHOW WARNINGS;

DROP TABLE IF EXISTS `assento` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `assento` (
  `id_assento` INT NOT NULL AUTO_INCREMENT,
  `id_voo` INT NOT NULL,
  `numero` CHAR(5) NOT NULL,
  `classe` VARCHAR(45) NOT NULL DEFAULT 'ECONOMICA',
  `status` VARCHAR(45) NOT NULL DEFAULT 'DISPONIVEL',
  PRIMARY KEY (`id_assento`),
  CONSTRAINT `fk_assento_voo`
    FOREIGN KEY (`id_voo`)
    REFERENCES `voo` (`id_voo`),
   CONSTRAINT `uq_assento_voo` UNIQUE (id_voo, numero))
ENGINE = InnoDB;

SHOW WARNINGS;

DROP TABLE IF EXISTS `passageiro` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `passageiro` (
  `id_passageiro` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(150) NOT NULL,
  `documento` VARCHAR(45) NOT NULL UNIQUE,
  PRIMARY KEY (`id_passageiro`))
ENGINE = InnoDB;

SHOW WARNINGS;

DROP TABLE IF EXISTS `reserva` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `reserva` (
  `id_reserva` INT NOT NULL AUTO_INCREMENT,
  `id_passageiro` INT NOT NULL,
  `id_assento` INT NOT NULL,
  `data_reserva` DATETIME NOT NULL DEFAULT (CURRENT_TIME()),
  `status` VARCHAR(45) NOT NULL DEFAULT 'CONFIRMADA',
  PRIMARY KEY (`id_reserva`),
  CONSTRAINT `fk_reserva_passageiro`
    FOREIGN KEY (`id_passageiro`)
    REFERENCES `passageiro` (`id_passageiro`),
  CONSTRAINT `fk_reserva_assento`
    FOREIGN KEY (`id_assento`)
    REFERENCES `assento` (`id_assento`))
ENGINE = InnoDB;

SHOW WARNINGS;

DROP TABLE IF EXISTS `voo` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `voo` (
  `id_voo` INT NOT NULL AUTO_INCREMENT,
  `codigo` CHAR(15) NOT NULL UNIQUE,
  `origem` VARCHAR(100) NOT NULL,
  `destino` VARCHAR(100) NOT NULL,
  `data_hora_saida` DATETIME NOT NULL,
  `id_aeronave` INT NOT NULL,
  `status` VARCHAR(45) NOT NULL DEFAULT 'PROGRAMADO',
  PRIMARY KEY (`id_voo`),
  CONSTRAINT `fk_voo_aeronave`
    FOREIGN KEY (`id_aeronave`)
    REFERENCES `aeronave` (`id_aeronave`))
ENGINE = InnoDB;

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- DADOS PARA TESTES

INSERT INTO aeronave
    (fabricante, modelo, quantidade_assentos)
VALUES
    ('Airbus', 'A320', 180);

INSERT INTO voo
    (codigo, origem, destino, data_hora_saida, id_aeronave)
VALUES
    (
        'AB1234',
        'Brasília',
        'São Paulo',
        '2026-10-10 10:00:00',
        1
    );

INSERT INTO passageiro
    (nome, documento)
VALUES
    ('Passageiro A', 'DOC001'),
    ('Passageiro B', 'DOC002');
    
INSERT INTO assento (id_voo, numero, classe)
VALUES
    (1, '10A', 'ECONOMICA'),
    (1, '10B', 'ECONOMICA'),
    (1, '10C', 'ECONOMICA');

-- TESTES

SELECT *
FROM assento
WHERE id_voo = 1
  AND numero = '10A'
  AND status = 'DISPONIVEL';

-- TRANSAÇÃO SEM BLOQUEIO EXPLÍCITO

BEGIN;

SELECT id_assento, status
FROM assento
WHERE id_voo = 1
  AND numero = '10A'
  AND status = 'DISPONIVEL';

UPDATE assento
SET status = 'RESERVADO'
WHERE id_assento = 1;

INSERT INTO reserva
    (id_passageiro, id_assento)
VALUES
    (1, 1);

COMMIT;

-- RESERVA SEGURA COM FOR UPDATE 
-- PASSAGEIRO A

BEGIN;

SELECT id_assento, status
FROM assento
WHERE id_voo = 1
  AND numero = '10A'
  AND status = 'DISPONIVEL'
FOR UPDATE;

UPDATE assento
SET status = 'RESERVADO'
WHERE id_assento = 1
  AND status = 'DISPONIVEL';

INSERT INTO reserva
    (id_passageiro, id_assento)
VALUES
    (1, 1);

COMMIT;

-- PASSAGEIRO B

BEGIN;

SELECT id_assento, status
FROM assento
WHERE id_voo = 1
  AND numero = '10A'
  AND status = 'DISPONIVEL'
FOR UPDATE;

-- IMPLEMENTAÇÃO COM ATUALIZAÇÃO CONDICIONAL

BEGIN;

UPDATE assento
SET status = 'RESERVADO'
WHERE id_assento = 1
  AND status = 'DISPONIVEL';
  
INSERT INTO reserva (id_passageiro, id_assento)
VALUES (1, 1);

COMMIT;

INSERT INTO reserva
    (id_passageiro, id_assento)
VALUES
    (1, 1);

COMMIT;

ROLLBACK;

-- RESTRIÇÃO DE UNICIDADE

CREATE UNIQUE INDEX uq_reserva_assento_ativa
ON reserva (id_assento);

-- DEADLOCK

BEGIN;

SELECT *
FROM assento WHERE id_assento = 1 FOR UPDATE;

SELECT * FROM assento WHERE id_assento = 2 FOR UPDATE;

BEGIN;

SELECT * FROM assento WHERE id_assento = 2 FOR UPDATE;

SELECT * FROM assento WHERE id_assento = 1 FOR UPDATE;
