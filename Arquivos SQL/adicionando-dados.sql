COPY cliente
FROM 'C:\Users\Public\Downloads\pessoas.csv' 
DELIMITER ',' 
CSV HEADER;

--select * from cliente

COPY aviao
FROM 'C:\Users\Public\Downloads\avioes.csv' 
DELIMITER ',' 
CSV HEADER;

--select * from aviao

COPY aeroporto
FROM 'C:\Users\Public\Downloads\aeroporto.csv' 
DELIMITER ',' 
CSV HEADER;

CREATE TEMPORARY TABLE IF NOT EXISTS temp1
(
    nvoo character varying(100) NOT NULL,
    companhia character varying(100) NOT NULL,
    horario date NOT NULL,
    PRIMARY KEY (nvoo)
);

COPY temp1
FROM 'C:\Users\Public\Downloads\voo.csv' 
DELIMITER ',' 
CSV HEADER;
alter table temp1
add column id1 SERIAL NOT NULL;

--select * from temp1
--select * from aeroporto
--(select cpf from cliente order by RANDOM() limit 1;)

do $$
declare
aa temp1%ROWTYPE;
aviaoo aviao.naviao%TYPE;
aero aeroporto.codaeropor%TYPE;
begin
	for i in 1..1000 loop
		select * into aa from temp1 where id1=i;
		select naviao into aviaoo from aviao order by RANDOM() limit 1;
		select codaeropor into aero from aeroporto order by RANDOM() limit 1;
		insert into voo values (aa.nvoo,aa.companhia,aa.horario,aviaoo,aero);
	end loop;
end; $$
language plpgsql;
DROP TABLE temp1;
--select * from voo join aviao on voo.fk_naviao=aviao.naviao

CREATE TEMPORARY TABLE IF NOT EXISTS temp2
(
    npassagem bigint NOT NULL,
    data date NOT NULL,
    classe character varying(20) NOT NULL,
    preco double precision,
    PRIMARY KEY (npassagem)
);

COPY temp2
FROM 'C:\Users\Public\Downloads\passagem.csv' 
DELIMITER ',' 
CSV HEADER;
--select * from temp2
alter table temp2 add column id1 serial;

do $$
declare
pass1 temp2%ROWTYPE;
cpff cliente.cpf%TYPE;
vooo voo%ROWTYPE;
cap aviao.capacidade%TYPE;
polt passagem.npoltrona%TYPE;
begin
	for i in 1..1000 loop
		select * into pass1 from temp2 where id1=i;
		select * into vooo from voo order by RANDOM() limit 1;
		select cpf into cpff from cliente order by RANDOM() limit 1;
		select capacidade into cap from aviao where aviao.naviao=vooo.fk_naviao;
		select npoltrona into polt from passagem where passagem.fk_nvoo=vooo.nvoo order by npoltrona desc limit 1;
		if(polt IS NULL) then
			polt=0;
		elsif(polt=cap) then
			i:=i-1;
			continue;
		end if;
		insert into passagem values (pass1.npassagem,pass1.classe,polt+1,pass1.preco,cpff,vooo.nvoo);
	end loop;
end; $$
language plpgsql;
--select * from passagem
DROP TABLE temp2;
