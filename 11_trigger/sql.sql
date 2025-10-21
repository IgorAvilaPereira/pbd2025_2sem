--Log de venda de ingresso em tabela log_ingresso.
CREATE OR REPLACE FUNCTION log_trigger_function() RETURNS TRIGGER AS $$
DECLARE
    filme_nome text;
BEGIN
    -- Nome do filme
    select filme.titulo from filme join sessao on sessao.filme_id = filme.id into filme_nome;
    
		INSERT INTO log(texto) VALUES('Telespectador de CPF:'||NEW.cpf||' adquiriu um ingresso para a sessao:'||NEW.sessao_id||' do filme '||filme_nome);		
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

create trigger log_trigger 
AFTER INSERT on ingresso FOR EACH ROW EXECUTE PROCEDURE log_trigger_function(); 


--Impedir venda de poltrona duplicada em uma sessão.
CREATE OR REPLACE FUNCTION verifica_poltrona_duplicada() RETURNS TRIGGER AS
$$
BEGIN
    IF NOT EXISTS(SELECT * FROM ingresso WHERE poltrona_id = NEW.poltrona_id AND sessao_id = NEW.sessao_id) THEN    
        RETURN TRUE;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER verifica_poltrona_duplicada_trigger 
BEFORE INSERT on ingresso FOR EACH ROW EXECUTE PROCEDURE verifica_poltrona_duplicada(); 


--Bloquear exclusão de filme com sessões ativas.
CREATE OR REPLACE FUNCTION verifica_sessao_ativa() RETURNS TRIGGER AS
$$
BEGIN
    IF NOT EXISTS(SELECT * FROM sessao WHERE filme_id = OLD.id AND data >= CURRENT_DATE) THEN
        DELETE FROM filme_direcao WHERE filme_id = OLD.id;
        DELETE FROM filme_genero WHERE filme_id = OLD.id;
        DELETE FROM ingresso WHERE sessao_id IN (SELECT id FROM sessao WHERE filme_id = OLD.id);
        DELETE FROM sessao WHERE filme_id = OLD.id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER verifica_sessao_ativa_trigger 
BEFORE DELETE on filme FOR EACH ROW EXECUTE PROCEDURE verifica_sessao_ativa(); 

--Bloquear exclusão de cliente que tenha ingressos comprados.
--CREATE OR REPLACE FUNCTION verifica_exclusao_cliente



--Atualizar ocupação da sala após venda de ingresso.
