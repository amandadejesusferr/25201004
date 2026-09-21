# Views e Índices

**Banco de Dados:** `bd_aeroporto`

## 1. Proposta de Views 

Para otimizar o acesso a dados relacionados no banco de dados, foram criadas duas views.

### View 1: Detalhes dos Voos e Aeronaves

* **Nome da View:** `vw_voos_detalhados`

* **Tabelas de Origem:** `VOO` e `AERONAVE`

* **Tipo:** JOIN

* Contém junções (`JOIN`) e múltiplos mapeamentos de tabelas.

* Evita a repetição constante da junção entre voos e aeronaves para identificar qual avião está em cada rota.

  ```
  CREATE VIEW vw_voos_detalhados AS
  SELECT 
      v.id_VOO,
      v.num_voo,
      v.origem,
      v.destino,
      v.dia_horario,
      a.modelo AS modelo_aeronave,
      a.capacidade
  FROM VOO v
  JOIN AERONAVE a ON v.id_AERONAVE = a.id_AERONAVE;
  
  ```

### View 2: Contato dos Passageiros

* **Nome da View:** `vw_passageiros_telefones`

* **Tabelas de Origem:** `PASSAGEIRO` e `TELEFONE_PASSAGEIRO`

* **Tipo:** JOIN

* Relacionamento de 1 para N associado por junção.

* Agiliza a consulta aos números de contato dos passageiros cadastrados sem precisar reescrever o `JOIN` toda vez.

  ```
  CREATE VIEW vw_passageiros_telefones AS
  SELECT 
      p.id_PASSAGEIRO,
      p.nome,
      p.cpf,
      t.telefone
  FROM PASSAGEIRO p
  JOIN TELEFONE_PASSAGEIRO t ON p.id_PASSAGEIRO = t.id_PASSAGEIRO;
  
  ```

## 2. Testes de Índices e Desempenho 

Utilizei o `EXPLAIN` para medir o desempenho e as estatísticas do `performance_schema` antes e depois da criação de um índice na tabela `VOO`.

### Tabela de Registro de Resultados

| **Consulta Testada** | **Type (Antes)** | **Rows (Antes)** | **Tempo Médio Antes (ms)** | **Type (Depois)** | **Rows (Depois)** | **Tempo Médio Depois (ms)** | **Conclusão** | 
| `SELECT * FROM VOO WHERE origem = 'Brasília';` | `ALL` | *1* | *3.0436* | `ref` | *1* | *0.5443* | O índice otimizou a busca por evitar varreduras completas (`FULL TABLE SCAN`). | 

### Detalhes do Procedimento Executado:

1. O `performance_schema` foi confirmado como ativo.

2. **Índice:**

   ```
   CREATE INDEX idx_voo_origem ON VOO(origem);
   
   ```

3. **Análise de Comportamento:**

   * **Antes do índice:** O plano de execução (`EXPLAIN`) apontava `type = ALL`, indicando que o banco precisava inspecionar todas as linhas da tabela `VOO`.

   * **Depois do índice:** O `type` mudou para `ref`, mostrando que o otimizador passou a utilizar a estrutura de árvore do índice (`idx_voo_origem`) para localizar os registros de forma direta.

   * Caso a tabela possua um volume muito baixo de dados de teste, a diferença de tempo pode ser quase imperceptível ou ignorada pelo otimizador, o que valida o conceito teórico de que índices trazem retorno expressivo em bases de dados maiores.

## 3. Scripts Finais Aplicados no Banco

```
-- Criação das Views
CREATE VIEW vw_voos_detalhados AS
SELECT 
    v.id_VOO, v.num_voo, v.origem, v.destino, v.dia_horario, 
    a.modelo AS modelo_aeronave, a.capacidade
FROM VOO v
JOIN AERONAVE a ON v.id_AERONAVE = a.id_AERONAVE;

CREATE VIEW vw_passageiros_telefones AS
SELECT 
    p.id_PASSAGEIRO, p.nome, p.cpf, t.telefone
FROM PASSAGEIRO p
JOIN TELEFONE_PASSAGEIRO t ON p.id_PASSAGEIRO = t.id_PASSAGEIRO;

-- Criação do Índice
CREATE INDEX idx_voo_origem ON VOO(origem);

```
