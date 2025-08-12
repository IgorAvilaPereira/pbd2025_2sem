# 🎬 Lista 1 - Consultas SQL – Sistema de Cinema

## 🔍 1. Filmes com diretores e gêneros

Lista todos os filmes com seus respectivos diretores e os gêneros associados.

<!--```sql
SELECT f.titulo, f.duracao, f.classificacao_etaria, d.nome AS diretor,
       STRING_AGG(g.nome, ', ') AS generos
FROM filme f
JOIN filme_direcao fd ON f.id = fd.filme_id
JOIN direcao d ON fd.direcao_id = d.id
JOIN filme_genero fg ON f.id = fg.filme_id
JOIN genero g ON fg.genero_id = g.id
GROUP BY f.id, d.nome;
```-->

## 2. Sessões com filme, sala, data e horários

Mostra as sessões agendadas com nome do filme, número da sala, data e horários.

<!--```sql
SELECT s.id AS sessao_id, f.titulo AS filme, sa.id AS sala, s.data, s.hora_inicio, s.hora_fim
FROM sessao s
JOIN filme f ON s.filme_id = f.id
JOIN sala sa ON s.sala_id = sa.id;
```-->

## 3. Ingressos vendidos com detalhes

Lista os ingressos vendidos, informando CPF do comprador, nome do filme, número da poltrona e valor.

<!--```sql
SELECT i.id AS ingresso_id, i.cpf, f.titulo AS filme,
       p.fileira || p.posicao AS poltrona, i.valor
FROM ingresso i
JOIN sessao s ON i.sessao_id = s.id
JOIN filme f ON s.filme_id = f.id
JOIN poltrona p ON i.poltrona_id = p.id;
```-->

## 4. Poltronas disponíveis em uma sala

Mostra as poltronas não ocupadas da sala 1.

<!--```sql
SELECT p.id, p.fileira, p.posicao, p.tipo
FROM poltrona p
WHERE p.sala_id = 1 AND p.id NOT IN (SELECT poltrona_id FROM ingresso);
```-->

## 5. Ocupação por sessão

Exibe quantidade de ingressos vendidos e poltronas restantes para cada sessão.

<!--```sql
SELECT s.id AS sessao_id, COUNT(i.id) AS ingressos_vendidos,
       sa.ocupacao AS capacidade_total,
       sa.ocupacao - COUNT(i.id) AS poltronas_disponiveis
FROM sessao s
JOIN sala sa ON s.sala_id = sa.id
LEFT JOIN ingresso i ON s.id = i.sessao_id
GROUP BY s.id, sa.ocupacao;
```-->

## 6. Total de ingressos vendidos por filme

<!--```sql
SELECT f.titulo, COUNT(i.id) AS ingressos_vendidos
FROM ingresso i
JOIN sessao s ON i.sessao_id = s.id
JOIN filme f ON s.filme_id = f.id
GROUP BY f.titulo;
```-->

## 7. Arrecadação total por filme

<!--```sql
SELECT f.titulo, SUM(i.valor) AS total_arrecadado
FROM ingresso i
JOIN sessao s ON i.sessao_id = s.id
JOIN filme f ON s.filme_id = f.id
GROUP BY f.titulo;
```-->

## 8. Sessões futuras

Mostra todas as sessões agendadas a partir da data atual.

<!--```sql
SELECT * FROM sessao WHERE data >= CURRENT_DATE;
```-->

## 9. Filmes com mais de 2 horas de duração

<!--```sql
SELECT * FROM filme WHERE duracao > 120;
```-->

## 10. Filmes com classificação etária 18

<!--```sql
SELECT * FROM filme WHERE classificacao_etaria = '18';
```-->

## 11. Poltronas luxo disponíveis em uma sessão

<!--```sql
SELECT p.*
FROM poltrona p
JOIN sessao s ON p.sala_id = s.sala_id
WHERE p.tipo = 'luxo' AND s.id = 1
AND p.id NOT IN (SELECT poltrona_id FROM ingresso WHERE sessao_id = s.id);
```-->

## 12. Média de valor de ingressos por sessão

<!--```sql
SELECT sessao_id, AVG(valor) AS media_valor
FROM ingresso
GROUP BY sessao_id;
```-->

## 13. Poltronas vendidas por sessão

<!--```sql
SELECT sessao_id, COUNT(*) AS qtd_vendidas
FROM ingresso
GROUP BY sessao_id;
```-->

## 14. Gêneros com número de filmes

<!--```sql
SELECT g.nome, COUNT(fg.filme_id) AS qtd_filmes
FROM genero g
LEFT JOIN filme_genero fg ON g.id = fg.genero_id
GROUP BY g.nome;
```-->

## 15. Diretores com número de filmes dirigidos

<!--```sql
SELECT d.nome, COUNT(fd.filme_id) AS qtd_filmes
FROM direcao d
LEFT JOIN filme_direcao fd ON d.id = fd.direcao_id
GROUP BY d.nome;
```-->

## 16. Número de sessões por sala

<!--```sql
SELECT sa.id AS sala, sa.ocupacao, COUNT(s.id) AS sessoes_agendadas
FROM sala sa
LEFT JOIN sessao s ON sa.id = s.sala_id
GROUP BY sa.id, sa.ocupacao;
```-->

## 17. Sessões com poltronas disponíveis

<!--```sql
SELECT s.id, sa.ocupacao - COUNT(i.id) AS disponiveis
FROM sessao s
JOIN sala sa ON s.sala_id = sa.id
LEFT JOIN ingresso i ON i.sessao_id = s.id
GROUP BY s.id, sa.ocupacao
HAVING sa.ocupacao - COUNT(i.id) > 0;
```-->

## 18. Filmes sem sessões cadastradas

<!--```sql
SELECT f.*
FROM filme f
LEFT JOIN sessao s ON f.id = s.filme_id
WHERE s.id IS NULL;
```-->

## 19. Clientes que compraram mais de uma vez

<!--```sql
SELECT cpf, COUNT(*) AS compras
FROM ingresso
GROUP BY cpf
HAVING COUNT(*) > 1;
```-->

## 20. Poltronas disponíveis por sala

<!--```sql
SELECT sala_id, COUNT(*) AS disponiveis
FROM poltrona
WHERE id NOT IN (SELECT poltrona_id FROM ingresso)
GROUP BY sala_id;
```-->

---

# ⚙️ Stored Procedures / Funções

## 1. Inserir filme completo (com diretores e gêneros)

<!--```sql
CREATE OR REPLACE FUNCTION inserir_filme_completo(
    titulo_ TEXT, duracao_ INT, classificacao_ VARCHAR, sinopse_ TEXT,
    diretores_ INT[], generos_ INT[]
) RETURNS VOID AS $$
DECLARE
    novo_filme_id INT;
    d INT;
    g INT;
BEGIN
    INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse)
    VALUES (titulo_, duracao_, classificacao_, sinopse_)
    RETURNING id INTO novo_filme_id;

    FOREACH d IN ARRAY diretores_ LOOP
        INSERT INTO filme_direcao (filme_id, direcao_id)
        VALUES (novo_filme_id, d);
    END LOOP;

    FOREACH g IN ARRAY generos_ LOOP
        INSERT INTO filme_genero (filme_id, genero_id)
        VALUES (novo_filme_id, g);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```-->

## 2. Poltronas disponíveis por sessão

<!--```sql
CREATE OR REPLACE FUNCTION poltronas_disponiveis(sessao_id_ INT)
RETURNS TABLE (
    poltrona_id INT, fileira CHAR(1), posicao INT, tipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.fileira, p.posicao, p.tipo
    FROM poltrona p
    JOIN sessao s ON p.sala_id = s.sala_id
    WHERE s.id = sessao_id_
    AND p.id NOT IN (
        SELECT poltrona_id FROM ingresso WHERE sessao_id = sessao_id_
    );
END;
$$ LANGUAGE plpgsql;
```-->

## 3. Arrecadação por sessão

<!--```sql
CREATE OR REPLACE FUNCTION arrecadacao_por_sessao(sessao_id_ INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE total NUMERIC(10,2);
BEGIN
    SELECT SUM(valor) INTO total
    FROM ingresso
    WHERE sessao_id = sessao_id_;
    RETURN COALESCE(total, 0.00);
END;
$$ LANGUAGE plpgsql;
```-->

## 4. Inserir nova sessão

<!--```sql
CREATE OR REPLACE PROCEDURE ins_sessao(filme_id INT, sala_id INT, data_ DATE, hora_inicio_ TIME, hora_fim_ TIME)
LANGUAGE SQL AS $$
    INSERT INTO sessao(filme_id, sala_id, data, hora_inicio, hora_fim)
    VALUES (filme_id, sala_id, data_, hora_inicio_, hora_fim_);
$$;
```-->

## 5. Vender ingresso com validação

<!--```sql
CREATE OR REPLACE FUNCTION vender_ingresso(cpf_ TEXT, sessao_id_ INT, poltrona_id_ INT, valor_ NUMERIC)
RETURNS TEXT AS $$
BEGIN
    IF poltrona_id_ IN (SELECT poltrona_id FROM ingresso WHERE sessao_id

\= sessao\_id\_) THEN
RETURN 'Poltrona já vendida';
END IF;

```
INSERT INTO ingresso(cpf, sessao_id, valor, poltrona_id)
VALUES (cpf_, sessao_id_, valor_, poltrona_id_);

RETURN 'Ingresso vendido';
```

END;

$$$LANGUAGE plpgsql;
```-->

## 6. Filmes por classificação mínima
<!--```sql
CREATE OR REPLACE FUNCTION filmes_por_classificacao(min_clas VARCHAR)
RETURNS TABLE (titulo TEXT, classificacao CHARACTER VARYING) AS $$
BEGIN
    RETURN QUERY
    SELECT titulo, classificacao_etaria
    FROM filme
    WHERE classificacao_etaria >= min_clas;
END;
$$ LANGUAGE plpgsql;
```-->

## 7. Listar sessões de um filme
<!--```sql
CREATE OR REPLACE FUNCTION sessoes_por_filme(filme_id_ INT)
RETURNS TABLE (sessao_id INT, data DATE, hora_inicio TIME, hora_fim TIME) AS $$
BEGIN
    RETURN QUERY
    SELECT id, data, hora_inicio, hora_fim
    FROM sessao
    WHERE filme_id = filme_id_;
END;
$$ LANGUAGE plpgsql;
```-->

## 8. Cancelar ingresso
<!--```sql
CREATE OR REPLACE PROCEDURE cancelar_ingresso(ingresso_id INT)
LANGUAGE SQL AS $$
    DELETE FROM ingresso WHERE id = ingresso_id;
$$;
```-->

## 9. Atualizar sinopse do filme
<!--```sql
CREATE OR REPLACE PROCEDURE atualizar_sinopse(filme_id INT, nova_sinopse TEXT)
LANGUAGE SQL AS $$
    UPDATE filme SET sinopse = nova_sinopse WHERE id = filme_id;
$$;
```-->

## 10. Relatório geral de uma sessão
<!--```sql
CREATE OR REPLACE FUNCTION relatorio_sessao(sessao_id_ INT)
RETURNS TABLE (
    sessao_id INT,
    titulo TEXT,
    ingressos_vendidos INT,
    arrecadacao NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, f.titulo, COUNT(i.id), COALESCE(SUM(i.valor), 0)
    FROM sessao s
    JOIN filme f ON s.filme_id = f.id
    LEFT JOIN ingresso i ON i.sessao_id = s.id
    WHERE s.id = sessao_id_
    GROUP BY s.id, f.titulo;
END;
$$ LANGUAGE plpgsql;
```-->

