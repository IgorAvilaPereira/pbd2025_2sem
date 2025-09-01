## 🔰 PL/pgSQL – Resumo Geral

PL/pgSQL é a linguagem procedural do PostgreSQL, usada em:

* **FUNCTIONS** – sempre retornam algo
* **PROCEDURES** – não retornam valor diretamente, mas podem fazer `COMMIT`, `ROLLBACK`, etc.

---

## 🧠 1. **Tipos de variáveis**

```sql
DECLARE
    nome TEXT;
    idade INTEGER;
    ativo BOOLEAN DEFAULT true;
    data_nasc DATE := '1990-01-01';
    total NUMERIC(10, 2);
    contador ALIAS FOR $1;  -- parâmetro posicional
```

---

## 🧱 2. **Condicionais (`IF`, `CASE`)**

### `IF` / `ELSIF` / `ELSE`

```sql
IF idade >= 18 THEN
    RAISE NOTICE 'Maior de idade';
ELSIF idade >= 16 THEN
    RAISE NOTICE 'Pode votar';
ELSE
    RAISE NOTICE 'Menor de idade';
END IF;
```

### `CASE`

```sql
CASE tipo
    WHEN 'A' THEN RAISE NOTICE 'Tipo A';
    WHEN 'B' THEN RAISE NOTICE 'Tipo B';
    ELSE RAISE NOTICE 'Outro tipo';
END CASE;
```

---

## 🔁 3. **Loops**

### `LOOP` + `EXIT WHEN`

```sql
LOOP
    contador := contador + 1;
    EXIT WHEN contador > 10;
END LOOP;
```

### `WHILE`

```sql
WHILE contador <= 10 LOOP
    RAISE NOTICE 'Contador: %', contador;
    contador := contador + 1;
END LOOP;
```

### `FOR` numérico

```sql
FOR i IN 1..5 LOOP
    RAISE NOTICE 'i = %', i;
END LOOP;
```

### `FOR` com resultado de `SELECT`

```sql
FOR aluno IN SELECT nome FROM alunos LOOP
    RAISE NOTICE 'Aluno: %', aluno.nome;
END LOOP;
```

---

## 🌀 4. **Cursores (Cursor)**

```sql
DECLARE
    c_alunos CURSOR FOR SELECT id, nome FROM alunos;
    r RECORD;
BEGIN
    OPEN c_alunos;
    LOOP
        FETCH c_alunos INTO r;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Aluno: % - %', r.id, r.nome;
    END LOOP;
    CLOSE c_alunos;
END;
```

---

## 🧯 5. **Tratamento de Erros (EXCEPTION)**

```sql
BEGIN
    -- tentativa de divisão
    resultado := a / b;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Erro: Divisão por zero';
    WHEN OTHERS THEN
        RAISE NOTICE 'Erro desconhecido';
END;
```

---

## 📌 6. **Function Completa com Tudo**

```sql
CREATE OR REPLACE FUNCTION exemplo_funcao(a INTEGER, b INTEGER)
RETURNS TEXT AS $$
DECLARE
    resultado INTEGER;
BEGIN
    IF b = 0 THEN
        RETURN 'Divisão por zero';
    END IF;

    resultado := a / b;

    FOR i IN 1..resultado LOOP
        RAISE NOTICE 'i: %', i;
    END LOOP;

    RETURN 'Resultado: ' || resultado;
END;
$$ LANGUAGE plpgsql;
```

---

## 📌 7. **Procedure com Transação**

```sql
CREATE OR REPLACE PROCEDURE exemplo_procedure(msg TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_mensagens (mensagem, data_log) VALUES (msg, now());
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'Erro ao inserir log: %', SQLERRM;
END;
$$;
```

---

## 📄 8. **Resumo rápido dos comandos PL/pgSQL**

| Comando              | Uso                             |
| -------------------- | ------------------------------- |
| `DECLARE`            | Declara variáveis               |
| `BEGIN ... END`      | Bloco de código                 |
| `IF ... THEN`        | Condicional                     |
| `LOOP / FOR / WHILE` | Repetição                       |
| `RAISE NOTICE`       | Imprime saída no console        |
| `RETURN`             | Retorna valor (em `FUNCTION`)   |
| `CALL`               | Executa uma `PROCEDURE`         |
| `SELECT`             | Executa query (dentro do bloco) |
| `EXCEPTION`          | Captura erro                    |

---

