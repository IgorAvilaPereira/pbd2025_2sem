DROP DATABASE IF EXISTS cinema;

CREATE DATABASE cinema;

\c cinema;


CREATE OR REPLACE FUNCTION isnumeric(text) RETURNS BOOLEAN AS $$
DECLARE 
    x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

--drop function valida_cpf(character varying);
CREATE OR REPLACE FUNCTION valida_cpf(cpf character(11)) RETURNS BOOLEAN as $$
DECLARE
    i integer := 1; 
    resultado integer := 0;
    multiplicador integer := 10; 
    resto1 integer := 0;
    digito1 integer := 0;
    
    resto2 integer := 0;
    digito2 integer := 0;
BEGIN
    IF (isnumeric(cpf) is FALSE) THEN
        RETURN FALSE;
    END IF;

	IF cpf = REPEAT('1', 11) OR cpf = REPEAT('2', 11) OR cpf = REPEAT('3', 11) OR cpf = REPEAT('4', 11) OR cpf = REPEAT('5', 11) OR cpf = REPEAT('6', 11) OR cpf = REPEAT('7', 11) OR cpf = REPEAT('8', 11) OR cpf = REPEAT('9', 11) OR cpf = REPEAT('0', 11) THEN
		RETURN FALSE;
	END IF;	
	
	i := 1;
    WHILE i <= 9 LOOP
        resultado := resultado + cast(SUBSTRING(cpf, i, 1) as int) * multiplicador;
        i := i + 1;
        multiplicador := multiplicador - 1;
    END LOOP;
    
    resto1 :=  resultado % 11;
    IF resto1 < 2 THEN
        digito1 := 0;
    ELSE
        digito1 := 11 - resto1;
    END IF;
    	
    i := 1;
    multiplicador := 11;
    resultado := 0;
    WHILE i <= 10 LOOP
        resultado := resultado + cast(SUBSTRING(cpf, i, 1) as int) * multiplicador;
        i := i + 1;
        multiplicador := multiplicador - 1;
    END LOOP;
    
	
    resto2 :=  resultado % 11;
    IF resto2 < 2 THEN
        digito2 := 0;
    ELSE
        digito2 := 11 - resto2;
    END IF;

    IF digito1 = CAST(SUBSTRING(cpf, 10, 1) as int) AND digito2 = CAST(SUBSTRING(cpf, 11, 1) as int) THEN
       RETURN TRUE;
    END IF; 
   RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

CREATE TABLE filme (
    id serial primary key,
    titulo text not null,
    duracao integer check (duracao > 0),
    classificacao_etaria character varying(2) check (classificacao_etaria in ('L','10', '12', '14', '16', '18')),
    sinopse text
);
INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse) VALUES
('SUPERMAN', 130, 'L', 'superman do james gun');

INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse) VALUES
('GUARDIOES DA GALAXIA', 130, 'L', 'GUARDIOES do james gun');

CREATE TABLE direcao (
    id serial primary key,
    nome text not null
);
INSERT INTO direcao (nome) VALUES
('JAMES GUN');

CREATE TABLE genero (
    id serial primary key,
    nome character varying(100) not null
);
INSERT INTO genero (nome) VALUES
('AVENTURA'),
('DRAMA'),
('TERROR'),
('AÇÃO');

CREATE TABLE filme_direcao (
    filme_id integer references filme (id),
    direcao_id integer references direcao (id),
    primary key (filme_id, direcao_id)
);
INSERT INTO filme_direcao (filme_id, direcao_id) VALUES
(1,1);

INSERT INTO filme_direcao (filme_id, direcao_id) VALUES
(2,1);

CREATE TABLE filme_genero (
    filme_id integer references filme (id),
    genero_id integer references genero (id),
    primary key (filme_id, genero_id)
);
INSERT INTO filme_genero (filme_id, genero_id) VALUES
(1, 1),
(1, 4);

CREATE TABLE sala (
    id serial primary key,
    ocupacao integer check (ocupacao > 0)
);
INSERT INTO sala (ocupacao) VALUES 
(100),
(50);

CREATE TABLE sessao (
    id serial primary key,
    filme_id integer references filme (id),
    sala_id integer references sala (id),
    data date default current_date,
    hora_inicio time default current_time,
    hora_fim time default current_time
); 
INSERT INTO sessao (filme_id, sala_id) VALUES
(1,1);
INSERT INTO sessao (filme_id, sala_id) VALUES
(1,2);

INSERT INTO sessao (filme_id, sala_id) VALUES
(2,1);
INSERT INTO sessao (filme_id, sala_id) VALUES
(2,2);

INSERT INTO sessao (filme_id, sala_id, data) VALUES
(1,2, CURRENT_DATE + INTERVAL '7 DAYS');

CREATE TABLE poltrona (
    id serial primary key,
    fileira character(1) not null,
    posicao integer check (posicao > 0),
    tipo character varying(100) check (tipo = 'luxo' or tipo = 'simples'),
    sala_id integer references sala (id)
);
INSERT INTO poltrona (fileira, posicao, tipo, sala_id) VALUES
('A', 1, 'simples', 1),
('A', 2, 'simples', 1),
('A', 3, 'simples', 1),
('A', 4, 'luxo', 1),
('A', 5, 'simples', 1);

INSERT INTO poltrona (fileira, posicao, tipo, sala_id) VALUES
('A', 1, 'simples', 2);

INSERT INTO poltrona (fileira, posicao, tipo, sala_id) VALUES
('A', 10, 'luxo', 2);

CREATE TABLE ingresso (
    id serial primary key,
    cpf character(11) not null check(valida_cpf(cpf) is TRUE),
    sessao_id integer references sessao (id),
    valor numeric(8,2) check (valor >= 0),
    poltrona_id integer references poltrona (id),
    unique(sessao_id, poltrona_id)
);

INSERT INTO ingresso (cpf, sessao_id, valor, poltrona_id) VALUES
('17658586072', 1, 1.99, 1);

INSERT INTO ingresso (cpf, sessao_id, valor, poltrona_id) VALUES
('17658586072', 2, 1.99, 6);

INSERT INTO ingresso (cpf, sessao_id, valor, poltrona_id) VALUES
('0177777777', 1, 1.99, 2);

INSERT INTO ingresso (cpf, sessao_id, valor, poltrona_id) VALUES
('17658586072', 4, 1.99, 2);

-- 1) 

-- v1) SELECT filme.titulo, direcao.nome, genero.nome FROM filme JOIN filme_direcao ON (filme.id = filme_direcao.filme_id) JOIN direcao ON (filme_direcao.direcao_id = direcao.id)JOIN filme_genero ON (filme.id = filme_genero.filme_id) JOIN genero ON (genero.id = filme_genero.genero_id);

-- v2) SELECT filme.titulo, STRING_AGG(DISTINCT direcao.nome, ',') as diretores, STRING_AGG(genero.nome, ',') as generos FROM filme JOIN filme_direcao ON (filme.id = filme_direcao.filme_id) JOIN direcao ON (filme_direcao.direcao_id = direcao.id)JOIN filme_genero ON (filme.id = filme_genero.filme_id) JOIN genero ON (genero.id = filme_genero.genero_id) GROUP BY filme.id;

-- 2) SELECT filme.titulo, sessao.sala_id, to_char(sessao.data, 'DD/MM/YYYY') as data, to_char(sessao.hora_inicio, 'HH24:MI:SS') as hora FROM filme inner join sessao on (filme.id = sessao.filme_id);

-- 3) SELECT filme.id, filme.titulo, ingresso.cpf, cast(ingresso.valor as money), poltrona.fileira||poltrona.posicao as cadeira FROM filme INNER JOIN sessao ON filme.id = sessao.filme_id inner join ingresso on ingresso.sessao_id = sessao.id inner join poltrona on poltrona.id = ingresso.poltrona_id ORDER BY filme.id; 

-- 4) SELECT poltrona.fileira||poltrona.posicao as cadeira FROM sessao inner join sala on sessao.sala_id = sala.id inner join poltrona on poltrona.sala_id = sala.id where sessao.id = 1 and poltrona.id not in (select poltrona.id from sessao inner join ingresso on sessao.id = ingresso.sessao_id inner join poltrona on poltrona.id = ingresso.poltrona_id where sessao.id = 1);

-- off-topic: ALTER TABLE ingresso ADD UNIQUE(poltrona_id, sessao_id);

-- 5) SELECT COUNT(*) as disponiveis FROM sessao inner join sala on sessao.sala_id = sala.id inner join poltrona on poltrona.sala_id = sala.id where sessao.id = 1 and poltrona.id not in (select poltrona.id from sessao inner join ingresso on sessao.id = ingresso.sessao_id inner join poltrona on poltrona.id = ingresso.poltrona_id where sessao.id = 1);

/*
6) WITH tabela_disponivel AS (
     SELECT COUNT(*) as disponiveis FROM sessao inner join sala on  sessao.sala_id = sala.id inner join poltrona on poltrona.sala_id = sala.id where sessao.id = 1 and poltrona.id not in (select poltrona.id from sessao inner join ingresso on sessao.id = ingresso.sessao_id inner join poltrona on poltrona.id = ingresso.poltrona_id where sessao.id = 1)
),
tabela_ocupados AS (
     SELECT COUNT(*) as ocupados FROM sessao inner join sala on  sessao.sala_id = sala.id inner join poltrona on poltrona.sala_id = sala.id where sessao.id = 1 and poltrona.id in (select poltrona.id from sessao inner join ingresso on sessao.id = ingresso.sessao_id inner join poltrona on poltrona.id = ingresso.poltrona_id where sessao.id = 1)
) select tabela_disponivel.disponiveis, tabela_ocupados.ocupados FROM tabela_disponivel, tabela_ocupados;
*/

-- 7) SELECT filme.titulo, sum(ingresso.valor)::money as valor_arrecadado FROM ingresso inner join sessao on sessao.id = ingresso.sessao_id inner join filme on filme.id = sessao.filme_id group by filme.id; 

-- 8) select sessao.id, filme.titulo FROM sessao join filme on (filme.id = sessao.filme_id) where data > CURRENT_DATE;

-- CREATE VIEW sessoes_futuras AS select sessao.id, filme.titulo FROM sessao join filme on (filme.id = sessao.filme_id) where data > CURRENT_DATE;

-- SELECT * FROM sessoes_futuras;

-- 9) SELECT filme.id, filme.titulo FROM filme where duracao > 120;

-- 10) SELECT filme.id, filme.titulo from filme where classificacao_etaria = '18';

-- 11) 
/*
SELECT poltrona.id 
    from 
        poltrona join sala on poltrona.sala_id = sala.id 
    inner join 
        sessao on sessao.sala_id = sala.id 
    where sessao.id = 1 and poltrona.tipo = 'luxo' and poltrona.id not in 
    (SELECT poltrona.id 
    from 
        sessao inner join sala on sala.id = sessao.sala_id 
    inner join 
        poltrona on poltrona.sala_id = sala.id 
     inner join 
        ingresso on ingresso.poltrona_id = poltrona.id 
     where sessao.id = 1 and poltrona.tipo = 'luxo');
*/

-- 12) SELECT sessao.id, filme.titulo, cast(avg(ingresso.valor) as money) FROM ingresso inner join sessao on sessao.id = ingresso.sessao_id inner join filme on filme.id = sessao.filme_id group by sessao.id, filme.id; 

-- DROP FUNCTION retorna_media;
CREATE OR REPLACE FUNCTION retorna_media(filme_id_aux bigint) RETURNS TABLE 
    (sessao_id int, filme_titulo text, media money) AS
$$
BEGIN
    
    IF (filme_id_aux IN (SELECT id FROM filme)) THEN
        RETURN QUERY SELECT sessao.id, filme.titulo, cast(avg(ingresso.valor) as money) FROM ingresso inner join sessao on sessao.id = ingresso.sessao_id inner join filme on filme.id = sessao.filme_id WHERE filme.id = filme_id_aux group by sessao.id, filme.id;  
    ELSE
        RAISE NOTICE 'Deu xabum!';
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- 13) jump

-- 14)
--DROP FUNCTION qtde_filmes_por_genero();
CREATE OR REPLACE FUNCTION qtde_filmes_por_genero() RETURNS TABLE (genero_id INT, genero_nome character varying(100), qtde bigint) AS
$$
BEGIN
    RETURN QUERY SELECT genero.id, genero.nome, count(*) FROM genero INNER JOIN filme_genero ON (genero.id = filme_genero.genero_id) group by genero.id, genero.nome ORDER BY genero.id;
END;
$$ LANGUAGE 'plpgsql';

-- 15
--DROP FUNCTION qtde_filmes_por_diretor(integer);
CREATE OR REPLACE FUNCTION qtde_filmes_por_diretor(integer) RETURNS TABLE (diretor_id int, diretor_nome TEXT, qtde bigint) AS
$$
BEGIN
    RETURN QUERY SELECT direcao.id, direcao.nome, count(*) FROM direcao JOIN filme_direcao ON (direcao.id = filme_direcao.direcao_id) WHERE direcao.id = $1 GROUP BY direcao.id, direcao.nome ORDER BY direcao.id;
END;
$$ LANGUAGE 'plpgsql';

-- 16
SELECT sala.id, count(*) as qtde from sala join sessao on (sala.id = sessao.sala_id) group by sala.id ORDER BY sala.id;


-- 17 - 20)  jump

-- 1) stored procedure
-- DROP FUNCTION adicionar_filme(text, integer, character varying(2), text);
CREATE OR REPLACE FUNCTION adicionar_filme(titulo_aux text, duracao_aux integer, classificacao_aux character varying(2), sinopse_aux text) RETURNS BOOLEAN AS
$$
DECLARE
    ultimo_filme_adicionado INTEGER := 0;
BEGIN
    INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse) VALUES
(titulo_aux, duracao_aux, classificacao_aux, sinopse_aux) RETURNING id INTO ultimo_filme_adicionado;

    IF (ultimo_filme_adicionado > 0) THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';


-- 8) cancelar ingresso
CREATE OR REPLACE FUNCTION cancelar_ingresso(poltrona_id_aux integer, sessao_id_aux integer) RETURNS BOOLEAN AS
$$
BEGIN   
    IF (EXISTS(SELECT * FROM ingresso WHERE poltrona_id = poltrona_id_aux AND sessao_id = sessao_id_aux)) THEN
        DELETE FROM ingresso WHERE poltrona_id = poltrona_id_aux AND sessao_id = sessao_id_aux;
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';


-- testes
select valida_cpf('11111111111');
select valida_cpf('17658586072');
select valida_cpf('1SDFSDFSDFF');


-- 12. Verificar ocupação de uma sessao
--DROP FUNCTION ocupacao_sessao;
CREATE OR REPLACE FUNCTION ocupacao_sessao(integer) RETURNS TABLE (sessao integer, titulo TEXT, sala integer, qtde bigint) AS
$$
BEGIN
    RETURN QUERY SELECT sessao_id as sessao, filme.titulo, sala.id as sala, count(*) as qtde from ingresso inner join sessao on (sessao.id = ingresso.sessao_id) join filme on (sessao.filme_id = filme.id) join sala on (sessao.sala_id = sala.id) where sessao_id = $1 group by sessao_id, filme.titulo, sala.id order by sessao_id;
END;
$$ LANGUAGE 'plpgsql';

-- 1) sessao_id, 2) sala_id
CREATE OR REPLACE FUNCTION transferir_sessao_para_outra_sala(integer, integer) RETURNS BOOLEAN AS
$$
DECLARE
    data_aux date;
    hora_inicio_aux time;
    hora_fim_aux time;
BEGIN
    SELECT data, to_char(hora_inicio,'HH24:MI')::time, to_char(hora_fim,'HH24:MI')::time FROM sessao WHERE id = $1 INTO data_aux, hora_inicio_aux, hora_fim_aux;

--    RAISE NOTICE 'data %', data_aux;
--    RAISE NOTICE 'hora_inicio %', to_char(hora_inicio,'HH24:MI');
    
    IF (EXISTS (SELECT id FROM sessao WHERE id = $1) AND EXISTS (SELECT id FROM sala WHERE id = $2)) THEN        


        IF (NOT EXISTS(SELECT * FROM sessao WHERE data = data_aux AND to_char(hora_inicio,'HH24:MI')::time >= hora_inicio_aux AND to_char(hora_fim,'HH24:MI')::time <= hora_fim_aux AND sala_id = $2)) THEN                       

            UPDATE sessao SET sala_id = $2 where id = $1;
            RETURN TRUE;

        ELSE
            RAISE NOTICE 'ja existe uma outra sessao nesta mesma sala e neste mesmo horario';
            RETURN FALSE;
        END IF;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

select * from transferir_sessao_para_outra_sala(1,2);

CREATE OR REPLACE FUNCTION buscar_filme_por_diretor(nome_aux text) RETURNS TABLE (titulo TEXT) AS
$$
BEGIN
    RETURN QUERY SELECT filme.titulo FROM filme JOIN filme_direcao ON (filme.id = filme_direcao.filme_id) JOIN direcao ON 
    (direcao.id = filme_direcao.direcao_id) WHERE direcao.nome ILIKE nome_aux||'%';
END;
$$ LANGUAGE 'plpgsql';

select * from buscar_filme_por_diretor('james');

-- 15. Listar filmes com genero específico

-- 16 
CREATE OR REPLACE FUNCTION top5() RETURNS TABLE (titulo TEXT, valor_arrecadado money) AS
$$
BEGIN
    RETURN QUERY SELECT filme.titulo, sum(ingresso.valor)::money as valor_arrecadado FROM ingresso inner join sessao on sessao.id = ingresso.sessao_id inner join filme on filme.id = sessao.filme_id group by filme.id ORDER BY valor_arrecadado DESC LIMIT 5; 
END;
$$ LANGUAGE 'plpgsql';

SELECT * from top5();

--DROP FUNCTION sessoes_disponiveis;
CREATE OR REPLACE FUNCTION sessoes_disponiveis(time) RETURNS TABLE (sessao integer, sala integer, titulo text, hora time) AS
$$
BEGIN
    RETURN QUERY
    SELECT sessao.id, sala_id, filme.titulo, to_char(hora_inicio,'HH24:MI')::time as hora FROM sessao join filme on (sessao.filme_id = filme.id) WHERE data = CURRENT_DATE AND to_char(hora_inicio,'HH24:MI')::time = $1 order by sessao.id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION excluir_filme(integer) RETURNS BOOLEAN AS 
$$
BEGIN
    DELETE FROM ingresso WHERE sessao_id IN (SELECT id FROM sessao WHERE filme_id = $1);
    DELETE FROM sessao WHERE filme_id = $1;
    DELETE FROM filme_genero WHERE filme_id = $1;
    DELETE FROM filme_direcao WHERE filme_id = $1;
    DELETE FROM filme WHERE id = $1;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN RAISE NOTICE 'deu xabum';
RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

-- 24. Verificar poltrona VIP disponível
-- to-do: pegar poltronas das sessoes disponiveis - nao somente das salas
/*
select sala.id, poltrona.id from sala join poltrona on sala.id = poltrona.sala_id where tipo = 'luxo' 
and poltrona.id NOT IN (select poltrona_id from ingresso join sessao on ingresso.sessao_id = sessao_id where sessao.data >= current_date and to_char(hora_inicio,'HH24:MI')::time >= to_char(current_time,'HH24:MI')::time);
*/


