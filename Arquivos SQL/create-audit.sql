create table audit_passagem (operacao char, data timestamp, usuario varchar, npassagem bigint, classe varchar(20), npoltrona integer, preco double precision, fk_cpf varchar(100), fk_nvoo varchar(100));

CREATE OR REPLACE FUNCTION process_passagem_audit()
RETURNS TRIGGER AS $passagem_audit$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO audit_passagem SELECT 'D', now(), user, OLD.*;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO audit_passagem SELECT 'U', now(), user, NEW.*;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO audit_passagem SELECT 'I', now(), user, NEW.*;
		RETURN NEW;
	END IF;
	RETURN NULL;
END;
$passagem_audit$ LANGUAGE plpgsql;
CREATE TRIGGER passagem_audit
AFTER INSERT OR UPDATE OR DELETE ON passagem
FOR EACH ROW EXECUTE PROCEDURE process_passagem_audit();

update passagem
	set npoltrona=2
	where  fk_nvoo='06-051-0074' AND
	npassagem=6463689017;
	
	select * from audit_passagem