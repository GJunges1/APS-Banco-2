--1. Lista o nome e o cpf dos clientes mais valiosos

create view clientes_mais_valiosos as
	select c.nome,c.cpf,sum(p.preco) as valor_gasto from passagem p
	join cliente c on p.fk_cpf=c.cpf
	group by c.cpf
	having sum(p.preco)>8000
	order by valor_gasto desc;

select * from clientes_mais_valiosos

--2. Lista os aviões da gol e suas informações
create view avioes_da_gol as
select a.fabricante,a.tipo,a.capacidade from aviao a join voo v
on a.naviao=v.fk_naviao
where v.companhia='GOL'
order by a.fabricante,a.tipo;

select * from avioes_da_gol;

--3. Relatório exibindo o número passagens vendidas, número de voos e o lucro burto por ano

create view relatorioanual as
select extract(YEAR from horario) as ano,
	count(p.npoltrona) as passagens_vendidas,
	count(v.nvoo) as numero_voos,
	round(sum(p.preco)::numeric,2) as lucro_bruto
from voo v join passagem p on p.fk_nvoo=v.nvoo
group by ano;

select * from relatorioanual
