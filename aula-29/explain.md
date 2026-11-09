# Relatório de Atividade Prática: Plano de Execução com EXPLAIN

**Base de dados:** `lab_otimizacao`  
**Tema:** Otimização de Consultas em Locadora de Carros  

---

## Parte 0 — Preparação

A base de dados `lab_otimizacao` possui **50.000 clientes** e **500.000 locações**. Inicialmente, apenas as chaves primárias (`PRIMARY KEY`) existiam nas tabelas.

---

## Parte 1 — Diagnóstico sem índices

### Registro (sem índices)

| Consulta | Tabela | type | key | rows | Observações (Extra) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Q1** | `locacao` | `ALL` | `NULL` | 498.636 | Using where |
| **Q2** | `locacao` (`l`) | `ALL` | `NULL` | 498.636 | *Nenhuma (NULL)* |
| **Q2** | `cliente` (`c`) | `eq_ref` | `PRIMARY` | 1 | Using where |

- **Tempo real da Q1 (`EXPLAIN ANALYZE`):** `197` ms

#### Pergunta: Por que o MySQL não teve alternativa a ler a tabela inteira?
**Resposta:** Como a coluna `id_cliente` na tabela `locacao` não possuía nenhum índice secundário criado, o MySQL não tinha uma estrutura de busca rápida para localizar diretamente os registros pertencentes ao cliente `4242`. Dessa forma, o otimizador foi forçado a executar um *Full Table Scan*, lendo o disco linha por linha em quase 500 mil registros para avaliar a condição informada no `WHERE`.

---

## Parte 2 — Criando índices e comparando

Foram criados os seguintes índices:
```sql
CREATE INDEX idx_loc_cliente ON locacao(id_cliente);
CREATE INDEX idx_cli_cpf     ON cliente(cpf);
ANALYZE TABLE cliente, locacao;
```

### Registro (com índices)

| Consulta | Tabela | type | key | rows |
| :--- | :--- | :--- | :--- | :--- |
| **Q1** | `locacao` | `ref` | `idx_loc_cliente` | 10 |
| **Q2** | `cliente` (`c`) | `ref` | `idx_cli_cpf` | 1 |
| **Q2** | `locacao` (`l`) | `ref` | `idx_loc_cliente` | 9 |

- **Tempo real da Q1 agora:** `0.077` ms

### Seletividade na prática

Índice criado na coluna `status`:
```sql
CREATE INDEX idx_loc_status ON locacao(status);
ANALYZE TABLE locacao;
```

| Filtro | Parcela aproximada | type | key | rows |
| :--- | :--- | :--- | :--- | :--- |
| `status = 'cancelada'` | cerca de 2% | `ref` | `idx_loc_status` | 18.332 |
| `status = 'concluida'` | cerca de 73% | `ref` | `idx_loc_status` | 249.318 |

#### Pergunta: O índice `idx_loc_status` existe nos dois casos. Por que o resultado do plano é diferente?
**Resposta:** A seletividade de um filtro determina a eficiência do índice. 
- Para `status = 'cancelada'`, a seletividade é alta, fazendo com que o MySQL examine poucas linhas rapidamente via índice.
- Para `status = 'concluida'`, a seletividade é baixa, exigindo a leitura de muitas linhas. Apesar dessa execução o MySQL ainda ter indicado o uso do índice `ref`, o custo de I/O aumenta bastante devido as idas e vindas aleatórias necessárias na chave primária para resgatar o resto dos dados de cada registro.

---

## Parte 3 — Índices que o MySQL ignora

Índices criados para teste:
```sql
CREATE INDEX idx_loc_data ON locacao(data_retirada);
CREATE INDEX idx_cli_nome ON cliente(nome);
ANALYZE TABLE cliente, locacao;
```

### Consultas Reescritas

- **3A — Função aplicada na coluna:**
  ```sql
  -- Consulta reescrita usando intervalo de datas:
  SELECT * FROM locacao 
  WHERE data_retirada >= '2025-06-01' AND data_retirada < '2025-07-01';
  ```

- **3B — LIKE com % no início:**
  ```sql
  -- Consulta reescrita filtrando o prefixo:
  SELECT * FROM cliente 
  WHERE nome LIKE 'Cliente 123%';
  ```

- **3C — Conversão implícita de tipo:**
  ```sql
  -- Consulta reescrita comparando texto com texto:
  SELECT * FROM cliente 
  WHERE cpf = '00000004242';
  ```

### Registro de Diagnóstico

| Caso | type antes | type depois | Por que o índice não era usado? |
| :--- | :--- | :--- | :--- |
| **3A** | `ALL` | `range` | Aplicar uma função (`DATE_FORMAT`) na coluna força o MySQL a calcular a função para todas as linhas da tabela em tempo de execução, inviabilizando a busca direta na árvore B-Tree do índice. |
| **3B** | `ALL` | `range` | O caractere curinga `%` posicionado no início do padrão impede o SGBD de identificar um ponto de partida ordenado na árvore B-Tree. |
| **3C** | `ALL` | `ref` | Ocorreu uma conversão escondida de tipos (comparação entre `VARCHAR` e `INT`). Internamente, o MySQL aplica uma função de conversão na coluna (`CAST`), desativando o aproveitamento do índice. |

---

## Parte 4 — Índice composto

Criando índice composto:
```sql
CREATE INDEX idx_loc_cli_data ON locacao(id_cliente, data_retirada);
ANALYZE TABLE locacao;
```

1. **Na consulta (a)** `WHERE id_cliente = 4242 AND data_retirada >= '2025-01-01'`:
   - **Índice escolhido (`key`):** `idx_loc_cli_data` (com `type = range` e estimativa de apenas `3` linhas lidas).

2. **Desafio — Consulta (b) com `idx_loc_data` tornado `INVISIBLE`:**
   ```sql
   ALTER TABLE locacao ALTER INDEX idx_loc_data INVISIBLE;

   EXPLAIN SELECT * FROM locacao 
   WHERE data_retirada >= '2025-06-01' AND data_retirada < '2025-07-01';
   ```
   - **Resultado:** `type = ALL`, `key = NULL`, `rows = 486.093`.

#### Desafio: O índice composto ajuda na consulta (b)? Por quê?
**Resposta:** Não ajuda. Ao ocultar o índice simples (`idx_loc_data`), o MySQL ignorou o índice composto `idx_loc_cli_data` e realizou a varredura completa da tabela (`type = ALL`).  
Isso acontece por conta da **regra do prefixo mais à esquerda**. O índice composto `(id_cliente, data_retirada)` é ordenado primordialmente pela primeira coluna (`id_cliente`). Como a consulta (b) filtra unicamente pela segunda coluna (`data_retirada`), o otimizador não consegue navegar na árvore B-Tree do índice composto sem ter um valor definido para `id_cliente`.

```sql
-- Revertendo a visibilidade do índice simples:
ALTER TABLE locacao ALTER INDEX idx_loc_data VISIBLE;
```

---

## Parte 5 — Fechamento

**1. Qual consulta teve o maior ganho com o índice e como você percebeu isso no plano?**  
As consultas **Q1** e **Q2** da Parte 1 apresentaram o maior ganho de desempenho. No plano de execução, esse ganho ficou evidente com a alteração do `type` de `ALL` para `ref`, reduzindo o número estimado de linhas lidas de 498.636 para apenas 1 a 10 linhas, e diminuindo a latência real de **197 ms** para **0.077 ms**.

**2. Cite um caso em que existia índice e ele não foi usado, e a razão.**  
Na consulta (b) da Parte 4 (após desativar a visibilidade do índice simples), o índice composto `idx_loc_cli_data` existia na tabela, mas foi desconsiderado pelo otimizador por descumprir a regra do prefixo mais à esquerda, já que o filtro envolvia apenas a segunda coluna do índice.

**3. Que custo todos esses índices trazem para as operações de escrita (INSERT, UPDATE, DELETE)?**  
Cada índice criado é uma estrutura física que deve ser constantemente atualizada no disco. Em operações de modificação de dados (`INSERT`, `DELETE` ou `UPDATE` nas colunas indexadas), o SGBD precisa reordenar e rebalancear essas árvores, gerando sobrecarga de I/O de disco e processamento de CPU, além de elevar o consumo total de armazenamento.
