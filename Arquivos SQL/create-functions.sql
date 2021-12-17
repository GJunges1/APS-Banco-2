--Criação de funções para consultas corriqueiras
--1. Primeira função (consulta de passagens para um cliente):
CREATE OR REPLACE FUNCTION public.getPassagensCliente(cpf1 varchar(100))
RETURNS TABLE (poltrona integer,num_voo varchar(100),
			   horario date,preco double precision,companhia varchar(100),
			   cod_aviao integer,nome_aeroporto varchar(100)) as $$
BEGIN
	RETURN QUERY SELECT p.npoltrona,v.nvoo,v.horario,p.preco,v.companhia,
				v.fk_naviao as id_aviao,a.nome as aeroporto
				FROM cliente as c
				JOIN passagem as p ON p.fk_cpf = c.cpf
				JOIN voo as v ON v.nvoo = p.fk_nvoo
				JOIN aeroporto as a ON a.codaeropor=v.fk_codaeropor
				WHERE cpf = cpf1;
END;
$$ LANGUAGE plpgsql

select * from getPassagensCliente('317-10-0451');

--2.Função para verificar os voos pela data
CREATE OR REPLACE FUNCTION public.getDecolagensData(data date)
RETURNS TABLE (num_voo varchar(100), companhia varchar(100), nome_aeroporto varchar(100), capacidade integer, tipo_aviao varchar(100)) as $$
BEGIN
	RETURN QUERY SELECT v.nvoo, v.companhia,  ae.nome, av.capacidade, av.tipo
	FROM voo as v
	JOIN aeroporto as ae ON v.fk_codaeropor=ae.codaeropor
	JOIN aviao as av ON v.fk_naviao=av.naviao
	WHERE horario = data;
END;
$$ LANGUAGE plpgsql;

select * from getDecolagensData('2025-12-29')

--3. Retorna uma poltrona livre aleatória para o voo informado
CREATE OR REPLACE FUNCTION getPoltronaLivre(nvoo1 varchar(100))
RETURNS integer AS $$
DECLARE
	voo1 VOO%ROWTYPE;
	cap AVIAO.capacidade%TYPE;
	i integer;
BEGIN
	SELECT * FROM voo INTO voo1 WHERE nvoo=nvoo1;
	IF voo1 IS NULL THEN
		RAISE EXCEPTION 'O voo informado não existe!';
	END IF;
	SELECT capacidade INTO cap FROM aviao WHERE aviao.naviao=voo1.fk_naviao;
	FOR i IN 1..cap LOOP
		IF EXISTS(SELECT 1 FROM passagem WHERE npoltrona=i) THEN
			CONTINUE;
		ELSE
			RETURN i;
		END IF;
	END LOOP;
	RAISE EXCEPTION 'Não há poltronas livres!';
END;
$$ LANGUAGE plpgsql;

select getPoltronaLivre('60-781-3268');
