-- CREATE TABLE log_tentativa_exclusao(id serial primary key, texto text not null);
-- CREATE TABLE log_exclusao(id serial primary key, texto text not null);


DELETE FROM ingresso WHERE sessao_id = 3; DELETE FROM sessao WHERE id = 3;

CREATE OR REPLACE FUNCTION gerar_log_exclusao_sessao_data() RETURNS TRIGGER AS
$$
BEGIN
  INSERT INTO log_exclusao(texto) VALUES('SESSAO '||OLD.id||' excluida em'||to_char(CURRENT_DATE, 'dd/mm/yyyy'));
  RETURN OLD;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER gerar_log_exclusao_sessao_data_trigger AFTER DELETE ON sessao
FOR EACH ROW EXECUTE PROCEDURE gerar_log_exclusao_sessao_data();

CREATE OR REPLACE FUNCTION gerar_log_exclusao_sala() RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(SELECT * FROM sessao JOIN sala ON sessao.sala_id = sala.id WHERE sala.id = OLD.id AND data >= CURRENT_DATE) THEN    
        RAISE NOTICE 'Ha sessoes futuras! Logo, sala NAO pode ser excluida ainda!';
        RETURN NULL;
    END IF;
--    DELETE FROM poltrona WHERE sala_id = OLD.id;
--    DELETE FROM sala WHERE id = OLD.id;
--    DELETE FROM ingresso WHERE sessao_id IN (SELECT id FROM sessao WHERE sala_id = OLD.id);
--    DELETE FROM sessao WHERE sala_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER gerar_log_exclusao_sala_trigger BEFORE DELETE ON sala
FOR EACH ROW EXECUTE PROCEDURE gerar_log_exclusao_sala();

CREATE OR REPLACE FUNCTION gerar_log_exclusao() RETURNS TRIGGER AS
$$
BEGIN
    IF EXISTS(SELECT * FROM ingresso WHERE id = OLD.id AND preco_id IS NULL) THEN
        INSERT INTO log_tentativa_exclusao(texto) VALUES ('INGRESSO '||OLD.id||' sofreu tentativa de exclusao mas esta tentativa foi bloqueado por falta de pagamento!');
        RETURN NULL;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER gerar_log_exclusao_trigger BEFORE DELETE ON ingresso
FOR EACH ROW EXECUTE PROCEDURE gerar_log_exclusao();
