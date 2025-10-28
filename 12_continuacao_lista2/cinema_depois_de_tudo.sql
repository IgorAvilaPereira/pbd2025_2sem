--
-- PostgreSQL database dump
--

\restrict 4FHoM7EGVbumf2p7AkJ5YE9xht0w0EViNjVTqfpzu9nm4F6JkoDDzlfkOosSppr

-- Dumped from database version 14.19 (Ubuntu 14.19-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.19 (Ubuntu 14.19-0ubuntu0.22.04.1)

-- Started on 2025-10-27 21:55:01 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE cinema;
--
-- TOC entry 3529 (class 1262 OID 78214)
-- Name: cinema; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE cinema WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


ALTER DATABASE cinema OWNER TO postgres;

\unrestrict 4FHoM7EGVbumf2p7AkJ5YE9xht0w0EViNjVTqfpzu9nm4F6JkoDDzlfkOosSppr
\connect cinema
\restrict 4FHoM7EGVbumf2p7AkJ5YE9xht0w0EViNjVTqfpzu9nm4F6JkoDDzlfkOosSppr

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 251 (class 1255 OID 78342)
-- Name: adicionar_filme(text, integer, character varying, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adicionar_filme(titulo_aux text, duracao_aux integer, classificacao_aux character varying, sinopse_aux text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    ultimo_filme_adicionado INTEGER := 0;
BEGIN
    INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse)
    VALUES (titulo_aux, duracao_aux, classificacao_aux, sinopse_aux)
    RETURNING id INTO ultimo_filme_adicionado;

    RETURN (ultimo_filme_adicionado > 0);
END;
$$;


ALTER FUNCTION public.adicionar_filme(titulo_aux text, duracao_aux integer, classificacao_aux character varying, sinopse_aux text) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 78374)
-- Name: ajustar_precos_baixa_ocupacao(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ajustar_precos_baixa_ocupacao() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    qtd_ajustados INT; 
BEGIN
    
    -- O UPDATE com JOINs internos garante que apenas as sessões que se qualificam
    -- e os ingressos não vendidos sejam alterados em uma única operação.
    
    UPDATE ingresso i
    SET valor = valor * 0.80 -- Redução de 20%
    FROM sessao s
    JOIN sala sa ON s.sala_id = sa.id
    WHERE i.sessao_id = s.id
      -- Condição de Baixa Ocupação:
      -- A subconsulta calcula o percentual de ingressos VENDIDOS (cpf IS NOT NULL)
      AND (
        SELECT COUNT(ig.id)::FLOAT / sa.ocupacao
        FROM ingresso ig
        WHERE ig.sessao_id = s.id AND ig.cpf IS NOT NULL 
      ) < 0.30
      -- Condição de Tempo (Faltando até 1h):
      AND s.hora_inicio > LOCALTIME
      AND s.hora_inicio <= LOCALTIME + INTERVAL '1 hour'
      -- Filtro Final: Atualizar apenas ingressos NÃO VENDIDOS
      AND i.cpf IS NULL;

    -- Usa o GET DIAGNOSTICS para contar as linhas afetadas (corrigindo o erro de RETURNING INTO)
    GET DIAGNOSTICS qtd_ajustados = ROW_COUNT;

    RETURN qtd_ajustados;
END;
$$;


ALTER FUNCTION public.ajustar_precos_baixa_ocupacao() OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 78346)
-- Name: buscar_filme_por_diretor(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.buscar_filme_por_diretor(nome_aux text) RETURNS TABLE(titulo text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT f.titulo
    FROM filme f
    JOIN filme_direcao fd ON f.id = fd.filme_id
    JOIN direcao d ON d.id = fd.direcao_id
    WHERE d.nome ILIKE nome_aux || '%';
END;
$$;


ALTER FUNCTION public.buscar_filme_por_diretor(nome_aux text) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 78343)
-- Name: cancelar_ingresso(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cancelar_ingresso(poltrona_id_aux integer, sessao_id_aux integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ingresso WHERE poltrona_id = poltrona_id_aux AND sessao_id = sessao_id_aux) THEN
        DELETE FROM ingresso WHERE poltrona_id = poltrona_id_aux AND sessao_id = sessao_id_aux;
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$;


ALTER FUNCTION public.cancelar_ingresso(poltrona_id_aux integer, sessao_id_aux integer) OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 78349)
-- Name: excluir_filme(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.excluir_filme(p_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM ingresso WHERE sessao_id IN (SELECT id FROM sessao WHERE filme_id = p_id);
    DELETE FROM sessao WHERE filme_id = p_id;
    DELETE FROM filme_genero WHERE filme_id = p_id;
    DELETE FROM filme_direcao WHERE filme_id = p_id;
    DELETE FROM filme WHERE id = p_id;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Erro ao excluir filme';
    RETURN FALSE;
END;
$$;


ALTER FUNCTION public.excluir_filme(p_id integer) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 78215)
-- Name: isnumeric(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isnumeric(text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
    x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;
EXCEPTION WHEN others THEN
    RETURN FALSE;
END;
$_$;


ALTER FUNCTION public.isnumeric(text) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 78344)
-- Name: ocupacao_sessao(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ocupacao_sessao(p_sessao integer) RETURNS TABLE(sessao integer, titulo text, sala integer, qtde bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT i.sessao_id, f.titulo, s.sala_id, COUNT(*) AS qtde
    FROM ingresso i
    JOIN sessao s ON s.id = i.sessao_id
    JOIN filme f ON s.filme_id = f.id
    WHERE i.sessao_id = p_sessao
    GROUP BY i.sessao_id, f.titulo, s.sala_id;
END;
$$;


ALTER FUNCTION public.ocupacao_sessao(p_sessao integer) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 78383)
-- Name: remanejar_poltrona(character, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.remanejar_poltrona(IN p_cpf_cliente character, IN p_id_sessao integer, IN p_poltrona_antiga integer, IN p_poltrona_nova integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    poltrona_ocupada BOOLEAN;
    poltrona_pertence_sessao_antiga BOOLEAN;
BEGIN
    SELECT TRUE INTO poltrona_ocupada
    FROM ingresso
    WHERE sessao_id = p_id_sessao
        AND poltrona_id = p_poltrona_nova
    LIMIT 1;

    IF poltrona_ocupada THEN
        RAISE EXCEPTION 'A nova poltrona % já está ocupada.', p_poltrona_nova;
    END IF;

    SELECT TRUE INTO poltrona_pertence_sessao_antiga
    FROM ingresso
    WHERE sessao_id = p_id_sessao
        AND poltrona_id = p_poltrona_antiga
        AND cpf = p_cpf_cliente
    LIMIT 1;

    IF NOT poltrona_pertence_sessao_antiga THEN
        RAISE EXCEPTION 'Não foi encontrado ingresso para o cliente % na poltrona % e sessão %.', p_cpf_cliente, p_poltrona_antiga, p_id_sessao;
    END IF;

    UPDATE ingresso
    SET poltrona_id = p_poltrona_nova
    WHERE cpf = p_cpf_cliente
        AND sessao_id = p_id_sessao
        AND poltrona_id = p_poltrona_antiga;

    INSERT INTO log_remanejamento(cpf_cliente, id_sessao, poltrona_antiga, poltrona_nova)
    VALUES (p_cpf_cliente, p_id_sessao, p_poltrona_antiga, p_poltrona_nova);
END;
$$;


ALTER PROCEDURE public.remanejar_poltrona(IN p_cpf_cliente character, IN p_id_sessao integer, IN p_poltrona_antiga integer, IN p_poltrona_nova integer) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 78348)
-- Name: sessoes_disponiveis(time without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sessoes_disponiveis(p_hora time without time zone) RETURNS TABLE(sessao integer, sala integer, titulo text, hora time without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.sala_id, f.titulo, s.hora_inicio
    FROM sessao s
    JOIN filme f ON s.filme_id = f.id
    WHERE s.data = CURRENT_DATE
    AND s.hora_inicio = p_hora
    ORDER BY s.id;
END;
$$;


ALTER FUNCTION public.sessoes_disponiveis(p_hora time without time zone) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 78373)
-- Name: simular_ocupacao_sessao(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.simular_ocupacao_sessao(p_id_sessao integer, p_percentual numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    capacidade_total INT;
    poltronas_ocupadas INT;
    qtd_simular INT;
    valor_padrao NUMERIC(10,2);
BEGIN
    SELECT sa.ocupacao INTO capacidade_total
    FROM sala sa
    JOIN sessao ss ON ss.sala_id = sa.id
    WHERE ss.id = p_id_sessao;

    IF capacidade_total IS NULL THEN
        RAISE EXCEPTION 'Sessão não encontrada.';
    END IF;

    SELECT COUNT(*) INTO poltronas_ocupadas FROM ingresso WHERE sessao_id = p_id_sessao;

    qtd_simular := ROUND((p_percentual / 100) * capacidade_total);

    IF qtd_simular <= poltronas_ocupadas THEN
        RAISE EXCEPTION 'Já existem mais poltronas ocupadas do que a simulação deseja.';
    END IF;

    qtd_simular := qtd_simular - poltronas_ocupadas;

    SELECT AVG(valor) INTO valor_padrao FROM ingresso WHERE sessao_id = p_id_sessao;

    FOR i IN 1..qtd_simular LOOP
        INSERT INTO ingresso_simulado(sessao_id, poltrona, valor)
        VALUES (p_id_sessao, i + poltronas_ocupadas, COALESCE(valor_padrao, 30.00));
    END LOOP;

    RETURN qtd_simular;
END;
$$;


ALTER FUNCTION public.simular_ocupacao_sessao(p_id_sessao integer, p_percentual numeric) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 78347)
-- Name: top5(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top5() RETURNS TABLE(titulo text, valor_arrecadado money)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT f.titulo, SUM(i.valor)::money
    FROM ingresso i
    JOIN sessao s ON s.id = i.sessao_id
    JOIN filme f ON f.id = s.filme_id
    GROUP BY f.id
    ORDER BY SUM(i.valor) DESC
    LIMIT 5;
END;
$$;


ALTER FUNCTION public.top5() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 78345)
-- Name: transferir_sessao_para_outra_sala(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transferir_sessao_para_outra_sala(p_sessao integer, p_sala integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    data_aux date;
    hora_inicio_aux time;
    hora_fim_aux time;
BEGIN
    SELECT data, hora_inicio, hora_fim INTO data_aux, hora_inicio_aux, hora_fim_aux
    FROM sessao WHERE id = p_sessao;

    IF EXISTS (SELECT 1 FROM sessao WHERE id = p_sessao)
        AND EXISTS (SELECT 1 FROM sala WHERE id = p_sala) THEN
        IF NOT EXISTS (
            SELECT 1 FROM sessao
            WHERE data = data_aux
            AND hora_inicio = hora_inicio_aux
            AND sala_id = p_sala
        ) THEN
            UPDATE sessao SET sala_id = p_sala WHERE id = p_sessao;
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Já existe uma sessão nesta sala e neste horário';
            RETURN FALSE;
        END IF;
    END IF;
    RETURN FALSE;
END;
$$;


ALTER FUNCTION public.transferir_sessao_para_outra_sala(p_sessao integer, p_sala integer) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 78216)
-- Name: valida_cpf(character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.valida_cpf(cpf character) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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

	IF cpf = REPEAT('1', 11) OR cpf = REPEAT('2', 11) OR cpf = REPEAT('3', 11) OR cpf = REPEAT('4', 11) OR
    cpf = REPEAT('5', 11) OR cpf = REPEAT('6', 11) OR cpf = REPEAT('7', 11) OR cpf = REPEAT('8', 11) OR cpf = REPEAT('9', 11) OR cpf = REPEAT('0', 11) THEN
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
$$;


ALTER FUNCTION public.valida_cpf(cpf character) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 78390)
-- Name: verifica_exclusao_cliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verifica_exclusao_cliente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS(SELECT * FROM ingresso WHERE cpf = OLD.cpf) THEN
        RETURN NULL;
    ELSE
        RETURN TRUE;
    END IF;
END;
$$;


ALTER FUNCTION public.verifica_exclusao_cliente() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 235 (class 1259 OID 78402)
-- Name: auditoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria (
    id integer NOT NULL,
    preco_antigo numeric(10,2),
    preco_atual numeric(10,2),
    preco_id integer
);


ALTER TABLE public.auditoria OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 78401)
-- Name: auditoria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auditoria_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auditoria_id_seq OWNER TO postgres;

--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 234
-- Name: auditoria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auditoria_id_seq OWNED BY public.auditoria.id;


--
-- TOC entry 225 (class 1259 OID 78337)
-- Name: cliente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cliente (
    cpf character(11) NOT NULL,
    nome character varying(100) NOT NULL
);


ALTER TABLE public.cliente OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 78229)
-- Name: direcao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direcao (
    id integer NOT NULL,
    nome text NOT NULL
);


ALTER TABLE public.direcao OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 78228)
-- Name: direcao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.direcao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.direcao_id_seq OWNER TO postgres;

--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 211
-- Name: direcao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.direcao_id_seq OWNED BY public.direcao.id;


--
-- TOC entry 210 (class 1259 OID 78218)
-- Name: filme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filme (
    id integer NOT NULL,
    titulo text NOT NULL,
    duracao integer,
    classificacao_etaria character varying(2),
    sinopse text,
    CONSTRAINT filme_classificacao_etaria_check CHECK (((classificacao_etaria)::text = ANY ((ARRAY['L'::character varying, '10'::character varying, '12'::character varying, '14'::character varying, '16'::character varying, '18'::character varying])::text[]))),
    CONSTRAINT filme_duracao_check CHECK ((duracao > 0))
);


ALTER TABLE public.filme OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 78244)
-- Name: filme_direcao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filme_direcao (
    filme_id integer NOT NULL,
    direcao_id integer NOT NULL
);


ALTER TABLE public.filme_direcao OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 78259)
-- Name: filme_genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.filme_genero (
    filme_id integer NOT NULL,
    genero_id integer NOT NULL
);


ALTER TABLE public.filme_genero OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 78217)
-- Name: filme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.filme_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.filme_id_seq OWNER TO postgres;

--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 209
-- Name: filme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.filme_id_seq OWNED BY public.filme.id;


--
-- TOC entry 214 (class 1259 OID 78238)
-- Name: genero; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genero (
    id integer NOT NULL,
    nome character varying(100) NOT NULL
);


ALTER TABLE public.genero OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 78237)
-- Name: genero_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genero_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genero_id_seq OWNER TO postgres;

--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 213
-- Name: genero_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genero_id_seq OWNED BY public.genero.id;


--
-- TOC entry 224 (class 1259 OID 78317)
-- Name: ingresso; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingresso (
    id integer NOT NULL,
    cpf character(11) NOT NULL,
    sessao_id integer,
    valor numeric(8,2),
    poltrona_id integer,
    preco_id integer,
    CONSTRAINT ingresso_cpf_check CHECK ((public.valida_cpf(cpf) IS TRUE)),
    CONSTRAINT ingresso_valor_check CHECK ((valor >= (0)::numeric))
);


ALTER TABLE public.ingresso OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 78316)
-- Name: ingresso_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingresso_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingresso_id_seq OWNER TO postgres;

--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 223
-- Name: ingresso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingresso_id_seq OWNED BY public.ingresso.id;


--
-- TOC entry 229 (class 1259 OID 78361)
-- Name: ingresso_simulado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingresso_simulado (
    id_simulacao integer NOT NULL,
    sessao_id integer NOT NULL,
    poltrona integer NOT NULL,
    valor numeric(10,2),
    criado_em timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ingresso_simulado OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 78360)
-- Name: ingresso_simulado_id_simulacao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingresso_simulado_id_simulacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingresso_simulado_id_simulacao_seq OWNER TO postgres;

--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 228
-- Name: ingresso_simulado_id_simulacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingresso_simulado_id_simulacao_seq OWNED BY public.ingresso_simulado.id_simulacao;


--
-- TOC entry 231 (class 1259 OID 78376)
-- Name: log_remanejamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_remanejamento (
    id_log integer NOT NULL,
    cpf_cliente character(11),
    id_sessao integer,
    poltrona_antiga integer,
    poltrona_nova integer,
    data_hora timestamp without time zone DEFAULT now()
);


ALTER TABLE public.log_remanejamento OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 78375)
-- Name: log_remanejamento_id_log_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_remanejamento_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_remanejamento_id_log_seq OWNER TO postgres;

--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 230
-- Name: log_remanejamento_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_remanejamento_id_log_seq OWNED BY public.log_remanejamento.id_log;


--
-- TOC entry 222 (class 1259 OID 78303)
-- Name: poltrona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.poltrona (
    id integer NOT NULL,
    fileira character(1) NOT NULL,
    posicao integer,
    tipo character varying(100),
    sala_id integer,
    CONSTRAINT poltrona_posicao_check CHECK ((posicao > 0)),
    CONSTRAINT poltrona_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['luxo'::character varying, 'simples'::character varying])::text[])))
);


ALTER TABLE public.poltrona OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 78302)
-- Name: poltrona_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.poltrona_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.poltrona_id_seq OWNER TO postgres;

--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 221
-- Name: poltrona_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.poltrona_id_seq OWNED BY public.poltrona.id;


--
-- TOC entry 233 (class 1259 OID 78393)
-- Name: preco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preco (
    id integer NOT NULL,
    descricao text,
    preco_base numeric(10,2)
);


ALTER TABLE public.preco OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 78392)
-- Name: preco_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.preco_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.preco_id_seq OWNER TO postgres;

--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 232
-- Name: preco_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.preco_id_seq OWNED BY public.preco.id;


--
-- TOC entry 226 (class 1259 OID 78350)
-- Name: relatorio_clientes_frequentes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.relatorio_clientes_frequentes AS
 SELECT c.cpf,
    c.nome,
    count(i.id) AS quantidade_ingressos,
    sum(i.valor) AS total_gasto,
    round(avg(i.valor), 2) AS media_por_ingresso
   FROM (public.cliente c
     JOIN public.ingresso i ON ((c.cpf = i.cpf)))
  GROUP BY c.cpf, c.nome
 HAVING (count(i.id) >= 5)
  ORDER BY (sum(i.valor)) DESC;


ALTER TABLE public.relatorio_clientes_frequentes OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 78275)
-- Name: sala; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sala (
    id integer NOT NULL,
    ocupacao integer,
    CONSTRAINT sala_ocupacao_check CHECK ((ocupacao > 0))
);


ALTER TABLE public.sala OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 78274)
-- Name: sala_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sala_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sala_id_seq OWNER TO postgres;

--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 217
-- Name: sala_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sala_id_seq OWNED BY public.sala.id;


--
-- TOC entry 220 (class 1259 OID 78283)
-- Name: sessao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessao (
    id integer NOT NULL,
    filme_id integer,
    sala_id integer,
    data date DEFAULT CURRENT_DATE,
    hora_inicio time without time zone DEFAULT CURRENT_TIME,
    hora_fim time without time zone DEFAULT CURRENT_TIME
);


ALTER TABLE public.sessao OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 78282)
-- Name: sessao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sessao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessao_id_seq OWNER TO postgres;

--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 219
-- Name: sessao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sessao_id_seq OWNED BY public.sessao.id;


--
-- TOC entry 227 (class 1259 OID 78355)
-- Name: sessoes_conflitantes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.sessoes_conflitantes AS
 SELECT s1.id AS sessao_a,
    s2.id AS sessao_b,
    s1.filme_id,
    f.titulo,
    s1.hora_inicio,
    s1.sala_id AS sala_a,
    s2.sala_id AS sala_b
   FROM ((public.sessao s1
     JOIN public.sessao s2 ON (((s1.filme_id = s2.filme_id) AND (s1.hora_inicio = s2.hora_inicio) AND (s1.sala_id < s2.sala_id))))
     JOIN public.filme f ON ((s1.filme_id = f.id)))
  ORDER BY s1.hora_inicio;


ALTER TABLE public.sessoes_conflitantes OWNER TO postgres;

--
-- TOC entry 3313 (class 2604 OID 78405)
-- Name: auditoria id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria ALTER COLUMN id SET DEFAULT nextval('public.auditoria_id_seq'::regclass);


--
-- TOC entry 3294 (class 2604 OID 78232)
-- Name: direcao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direcao ALTER COLUMN id SET DEFAULT nextval('public.direcao_id_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 78221)
-- Name: filme id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme ALTER COLUMN id SET DEFAULT nextval('public.filme_id_seq'::regclass);


--
-- TOC entry 3295 (class 2604 OID 78241)
-- Name: genero id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genero ALTER COLUMN id SET DEFAULT nextval('public.genero_id_seq'::regclass);


--
-- TOC entry 3305 (class 2604 OID 78320)
-- Name: ingresso id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso ALTER COLUMN id SET DEFAULT nextval('public.ingresso_id_seq'::regclass);


--
-- TOC entry 3308 (class 2604 OID 78364)
-- Name: ingresso_simulado id_simulacao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso_simulado ALTER COLUMN id_simulacao SET DEFAULT nextval('public.ingresso_simulado_id_simulacao_seq'::regclass);


--
-- TOC entry 3310 (class 2604 OID 78379)
-- Name: log_remanejamento id_log; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_remanejamento ALTER COLUMN id_log SET DEFAULT nextval('public.log_remanejamento_id_log_seq'::regclass);


--
-- TOC entry 3302 (class 2604 OID 78306)
-- Name: poltrona id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poltrona ALTER COLUMN id SET DEFAULT nextval('public.poltrona_id_seq'::regclass);


--
-- TOC entry 3312 (class 2604 OID 78396)
-- Name: preco id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preco ALTER COLUMN id SET DEFAULT nextval('public.preco_id_seq'::regclass);


--
-- TOC entry 3296 (class 2604 OID 78278)
-- Name: sala id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala ALTER COLUMN id SET DEFAULT nextval('public.sala_id_seq'::regclass);


--
-- TOC entry 3298 (class 2604 OID 78286)
-- Name: sessao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessao ALTER COLUMN id SET DEFAULT nextval('public.sessao_id_seq'::regclass);


--
-- TOC entry 3523 (class 0 OID 78402)
-- Dependencies: 235
-- Data for Name: auditoria; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3515 (class 0 OID 78337)
-- Dependencies: 225
-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cliente VALUES ('17658586072', 'Cliente Inicial');
INSERT INTO public.cliente VALUES ('65858607217', 'João Silva');
INSERT INTO public.cliente VALUES ('72176585860', 'Maria Souza');
INSERT INTO public.cliente VALUES ('60721765858', 'Carlos Pereira');
INSERT INTO public.cliente VALUES ('58607217658', 'Ana Oliveira');
INSERT INTO public.cliente VALUES ('58586072176', 'Lukas Tester');


--
-- TOC entry 3502 (class 0 OID 78229)
-- Dependencies: 212
-- Data for Name: direcao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.direcao VALUES (1, 'JAMES GUN');


--
-- TOC entry 3500 (class 0 OID 78218)
-- Dependencies: 210
-- Data for Name: filme; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filme VALUES (1, 'SUPERMAN', 130, 'L', 'superman do james gun');
INSERT INTO public.filme VALUES (2, 'GUARDIOES DA GALAXIA', 130, 'L', 'GUARDIOES do james gun');


--
-- TOC entry 3505 (class 0 OID 78244)
-- Dependencies: 215
-- Data for Name: filme_direcao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filme_direcao VALUES (1, 1);
INSERT INTO public.filme_direcao VALUES (2, 1);


--
-- TOC entry 3506 (class 0 OID 78259)
-- Dependencies: 216
-- Data for Name: filme_genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.filme_genero VALUES (1, 1);
INSERT INTO public.filme_genero VALUES (1, 4);


--
-- TOC entry 3504 (class 0 OID 78238)
-- Dependencies: 214
-- Data for Name: genero; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.genero VALUES (1, 'AVENTURA');
INSERT INTO public.genero VALUES (2, 'DRAMA');
INSERT INTO public.genero VALUES (3, 'TERROR');
INSERT INTO public.genero VALUES (4, 'AÇÃO');


--
-- TOC entry 3514 (class 0 OID 78317)
-- Dependencies: 224
-- Data for Name: ingresso; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ingresso VALUES (24, '17658586072', 1, 1.99, 1, NULL);


--
-- TOC entry 3517 (class 0 OID 78361)
-- Dependencies: 229
-- Data for Name: ingresso_simulado; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3519 (class 0 OID 78376)
-- Dependencies: 231
-- Data for Name: log_remanejamento; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3512 (class 0 OID 78303)
-- Dependencies: 222
-- Data for Name: poltrona; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.poltrona VALUES (1, 'A', 1, 'simples', 1);
INSERT INTO public.poltrona VALUES (2, 'A', 2, 'simples', 1);
INSERT INTO public.poltrona VALUES (3, 'A', 3, 'simples', 1);
INSERT INTO public.poltrona VALUES (4, 'A', 4, 'luxo', 1);
INSERT INTO public.poltrona VALUES (5, 'A', 5, 'simples', 1);
INSERT INTO public.poltrona VALUES (6, 'B', 1, 'simples', 2);
INSERT INTO public.poltrona VALUES (7, 'B', 2, 'luxo', 2);
INSERT INTO public.poltrona VALUES (8, 'B', 1, 'simples', 1);
INSERT INTO public.poltrona VALUES (9, 'B', 2, 'simples', 1);
INSERT INTO public.poltrona VALUES (10, 'B', 3, 'simples', 1);
INSERT INTO public.poltrona VALUES (11, 'B', 4, 'simples', 1);
INSERT INTO public.poltrona VALUES (12, 'B', 5, 'simples', 1);
INSERT INTO public.poltrona VALUES (13, 'C', 1, 'luxo', 1);
INSERT INTO public.poltrona VALUES (14, 'C', 2, 'luxo', 1);
INSERT INTO public.poltrona VALUES (15, 'C', 3, 'luxo', 1);
INSERT INTO public.poltrona VALUES (16, 'C', 4, 'luxo', 1);
INSERT INTO public.poltrona VALUES (17, 'C', 5, 'luxo', 1);
INSERT INTO public.poltrona VALUES (18, 'C', 1, 'simples', 2);
INSERT INTO public.poltrona VALUES (19, 'C', 2, 'simples', 2);
INSERT INTO public.poltrona VALUES (20, 'C', 3, 'simples', 2);
INSERT INTO public.poltrona VALUES (21, 'C', 4, 'simples', 2);
INSERT INTO public.poltrona VALUES (22, 'C', 5, 'simples', 2);
INSERT INTO public.poltrona VALUES (23, 'D', 1, 'luxo', 2);
INSERT INTO public.poltrona VALUES (24, 'D', 2, 'luxo', 2);
INSERT INTO public.poltrona VALUES (25, 'D', 3, 'simples', 2);


--
-- TOC entry 3521 (class 0 OID 78393)
-- Dependencies: 233
-- Data for Name: preco; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3508 (class 0 OID 78275)
-- Dependencies: 218
-- Data for Name: sala; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sala VALUES (1, 100);
INSERT INTO public.sala VALUES (2, 50);


--
-- TOC entry 3510 (class 0 OID 78283)
-- Dependencies: 220
-- Data for Name: sessao; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sessao VALUES (1, 1, 1, '2025-10-24', '20:30:55.504385', '20:30:55.504385');
INSERT INTO public.sessao VALUES (2, 1, 2, '2025-10-24', '20:30:55.504385', '20:30:55.504385');
INSERT INTO public.sessao VALUES (3, 2, 1, '2025-10-24', '20:30:55.504385', '20:30:55.504385');
INSERT INTO public.sessao VALUES (4, 2, 2, '2025-10-24', '20:30:55.504385', '20:30:55.504385');
INSERT INTO public.sessao VALUES (5, 1, 2, '2025-10-31', '20:30:55.505641', '20:30:55.505641');


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 234
-- Name: auditoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_id_seq', 1, false);


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 211
-- Name: direcao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.direcao_id_seq', 1, true);


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 209
-- Name: filme_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.filme_id_seq', 2, true);


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 213
-- Name: genero_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genero_id_seq', 4, true);


--
-- TOC entry 3545 (class 0 OID 0)
-- Dependencies: 223
-- Name: ingresso_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingresso_id_seq', 24, true);


--
-- TOC entry 3546 (class 0 OID 0)
-- Dependencies: 228
-- Name: ingresso_simulado_id_simulacao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingresso_simulado_id_simulacao_seq', 1, false);


--
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 230
-- Name: log_remanejamento_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_remanejamento_id_log_seq', 1, false);


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 221
-- Name: poltrona_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.poltrona_id_seq', 25, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 232
-- Name: preco_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.preco_id_seq', 1, false);


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 217
-- Name: sala_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sala_id_seq', 2, true);


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 219
-- Name: sessao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sessao_id_seq', 5, true);


--
-- TOC entry 3343 (class 2606 OID 78407)
-- Name: auditoria auditoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_pkey PRIMARY KEY (id);


--
-- TOC entry 3335 (class 2606 OID 78341)
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (cpf);


--
-- TOC entry 3317 (class 2606 OID 78236)
-- Name: direcao direcao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direcao
    ADD CONSTRAINT direcao_pkey PRIMARY KEY (id);


--
-- TOC entry 3321 (class 2606 OID 78248)
-- Name: filme_direcao filme_direcao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_direcao
    ADD CONSTRAINT filme_direcao_pkey PRIMARY KEY (filme_id, direcao_id);


--
-- TOC entry 3323 (class 2606 OID 78263)
-- Name: filme_genero filme_genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_genero
    ADD CONSTRAINT filme_genero_pkey PRIMARY KEY (filme_id, genero_id);


--
-- TOC entry 3315 (class 2606 OID 78227)
-- Name: filme filme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme
    ADD CONSTRAINT filme_pkey PRIMARY KEY (id);


--
-- TOC entry 3319 (class 2606 OID 78243)
-- Name: genero genero_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genero
    ADD CONSTRAINT genero_pkey PRIMARY KEY (id);


--
-- TOC entry 3331 (class 2606 OID 78324)
-- Name: ingresso ingresso_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_pkey PRIMARY KEY (id);


--
-- TOC entry 3333 (class 2606 OID 78326)
-- Name: ingresso ingresso_sessao_id_poltrona_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_sessao_id_poltrona_id_key UNIQUE (sessao_id, poltrona_id);


--
-- TOC entry 3337 (class 2606 OID 78367)
-- Name: ingresso_simulado ingresso_simulado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso_simulado
    ADD CONSTRAINT ingresso_simulado_pkey PRIMARY KEY (id_simulacao);


--
-- TOC entry 3339 (class 2606 OID 78382)
-- Name: log_remanejamento log_remanejamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_remanejamento
    ADD CONSTRAINT log_remanejamento_pkey PRIMARY KEY (id_log);


--
-- TOC entry 3329 (class 2606 OID 78310)
-- Name: poltrona poltrona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poltrona
    ADD CONSTRAINT poltrona_pkey PRIMARY KEY (id);


--
-- TOC entry 3341 (class 2606 OID 78400)
-- Name: preco preco_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preco
    ADD CONSTRAINT preco_pkey PRIMARY KEY (id);


--
-- TOC entry 3325 (class 2606 OID 78281)
-- Name: sala sala_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala
    ADD CONSTRAINT sala_pkey PRIMARY KEY (id);


--
-- TOC entry 3327 (class 2606 OID 78291)
-- Name: sessao sessao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessao
    ADD CONSTRAINT sessao_pkey PRIMARY KEY (id);


--
-- TOC entry 3357 (class 2620 OID 78391)
-- Name: cliente verifica_exclusao_cliente_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER verifica_exclusao_cliente_trigger BEFORE DELETE ON public.cliente FOR EACH ROW EXECUTE FUNCTION public.verifica_exclusao_cliente();


--
-- TOC entry 3356 (class 2606 OID 78408)
-- Name: auditoria auditoria_preco_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria
    ADD CONSTRAINT auditoria_preco_id_fkey FOREIGN KEY (preco_id) REFERENCES public.preco(id);


--
-- TOC entry 3345 (class 2606 OID 78254)
-- Name: filme_direcao filme_direcao_direcao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_direcao
    ADD CONSTRAINT filme_direcao_direcao_id_fkey FOREIGN KEY (direcao_id) REFERENCES public.direcao(id);


--
-- TOC entry 3344 (class 2606 OID 78249)
-- Name: filme_direcao filme_direcao_filme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_direcao
    ADD CONSTRAINT filme_direcao_filme_id_fkey FOREIGN KEY (filme_id) REFERENCES public.filme(id);


--
-- TOC entry 3346 (class 2606 OID 78264)
-- Name: filme_genero filme_genero_filme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_genero
    ADD CONSTRAINT filme_genero_filme_id_fkey FOREIGN KEY (filme_id) REFERENCES public.filme(id);


--
-- TOC entry 3347 (class 2606 OID 78269)
-- Name: filme_genero filme_genero_genero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.filme_genero
    ADD CONSTRAINT filme_genero_genero_id_fkey FOREIGN KEY (genero_id) REFERENCES public.genero(id);


--
-- TOC entry 3353 (class 2606 OID 78384)
-- Name: ingresso ingresso_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_cpf_fkey FOREIGN KEY (cpf) REFERENCES public.cliente(cpf);


--
-- TOC entry 3352 (class 2606 OID 78332)
-- Name: ingresso ingresso_poltrona_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_poltrona_id_fkey FOREIGN KEY (poltrona_id) REFERENCES public.poltrona(id);


--
-- TOC entry 3354 (class 2606 OID 78413)
-- Name: ingresso ingresso_preco_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_preco_id_fkey FOREIGN KEY (preco_id) REFERENCES public.preco(id);


--
-- TOC entry 3351 (class 2606 OID 78327)
-- Name: ingresso ingresso_sessao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso
    ADD CONSTRAINT ingresso_sessao_id_fkey FOREIGN KEY (sessao_id) REFERENCES public.sessao(id);


--
-- TOC entry 3355 (class 2606 OID 78368)
-- Name: ingresso_simulado ingresso_simulado_sessao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingresso_simulado
    ADD CONSTRAINT ingresso_simulado_sessao_id_fkey FOREIGN KEY (sessao_id) REFERENCES public.sessao(id);


--
-- TOC entry 3350 (class 2606 OID 78311)
-- Name: poltrona poltrona_sala_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.poltrona
    ADD CONSTRAINT poltrona_sala_id_fkey FOREIGN KEY (sala_id) REFERENCES public.sala(id);


--
-- TOC entry 3348 (class 2606 OID 78292)
-- Name: sessao sessao_filme_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessao
    ADD CONSTRAINT sessao_filme_id_fkey FOREIGN KEY (filme_id) REFERENCES public.filme(id);


--
-- TOC entry 3349 (class 2606 OID 78297)
-- Name: sessao sessao_sala_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessao
    ADD CONSTRAINT sessao_sala_id_fkey FOREIGN KEY (sala_id) REFERENCES public.sala(id);


-- Completed on 2025-10-27 21:55:01 -03

--
-- PostgreSQL database dump complete
--

\unrestrict 4FHoM7EGVbumf2p7AkJ5YE9xht0w0EViNjVTqfpzu9nm4F6JkoDDzlfkOosSppr

