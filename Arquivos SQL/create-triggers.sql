-- Trigger 1 (verificação de campos durante atualizações na tabela passagem)
CREATE OR REPLACE FUNCTION conferePassagem()
RETURNS trigger AS $$
DECLARE
	voo1 VOO%ROWTYPE;
	cap AVIAO.capacidade%TYPE;
BEGIN
	SELECT * FROM voo WHERE NEW.fk_nvoo=voo.nvoo INTO voo1;
	-- Caso o voo inserido não exista:
	IF(voo1 IS NULL) THEN
		RAISE EXCEPTION 'O voo informado não existe!';
	END IF;
	IF(NOT EXISTS(SELECT 1 FROM cliente c WHERE NEW.fk_cpf=c.cpf)) THEN
		RAISE EXCEPTION 'O cpf informado não pertence a nenhum cliente!';
	END IF;
	
	SELECT capacidade FROM aviao WHERE aviao.naviao=voo1.fk_naviao INTO cap;
	-- Caso o número da poltrona seja maior que a capacidade do avião:
	IF(NEW.npoltrona > cap) THEN
		RAISE EXCEPTION 'Numero de poltrona inválido!';
	END IF;
	-- Caso o novo lugar escolhido esteja ocupado:
	IF(EXISTS(SELECT 1 FROM passagem p WHERE NEW.npoltrona=p.npoltrona AND p.fk_nvoo=NEW.fk_nvoo)
	  AND (TG_OP='INSERT' OR TG_OP='UPDATE' AND OLD.npoltrona!=NEW.npoltrona)) THEN
		RAISE EXCEPTION 'Esta poltrona não pode ser escolhida, pois já esta ocupada!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TrigPoltrona BEFORE INSERT OR UPDATE ON PASSAGEM
FOR EACH ROW EXECUTE PROCEDURE conferePassagem();

-- Trigger 2 (tabela de auditoria para a tabela voo)
create table audit_voo (operacao char, data timestamp, usuario varchar, nvoo varchar(100), companhia varchar(100), horario date, fk_naviao integer, fk_codaeropor varchar(100));

CREATE OR REPLACE FUNCTION process_voo_audit()
RETURNS TRIGGER AS $voo_audit$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO audit_voo SELECT 'D', now(), user, OLD.*;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO audit_voo SELECT 'U', now(), user, NEW.*;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO audit_voo SELECT 'I', now(), user, NEW.*;
		RETURN NEW;
	END IF;
	RETURN NULL;
END;
$voo_audit$ LANGUAGE plpgsql;
CREATE TRIGGER voo_audit
AFTER INSERT OR UPDATE OR DELETE ON voo
FOR EACH ROW EXECUTE PROCEDURE process_voo_audit();

update voo
	set companhia='LATAM'
	where  nvoo='60-781-3268';
select * from audit_voo;

--Trigger 3 (verificação do nome do cliente, durante inserções e atualizações)
CREATE OR REPLACE FUNCTION verificaNomeCliente()
RETURNS trigger AS $vernome$
BEGIN
	IF NEW.nome~'^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,''-]+$' THEN
		RETURN NEW;
	END IF;
	RAISE EXCEPTION 'O nome não deve conter números e símbolos desnecessários!';
END;
$vernome$ LANGUAGE plpgsql;
CREATE TRIGGER verifica_nome_cliente
BEFORE INSERT OR UPDATE ON cliente
FOR EACH ROW EXECUTE PROCEDURE verificaNomeCliente();

update cliente
	set nome='J04051NH0'
	where cpf='245-24-2123';
