-- 1.Quantidade de voos diários em um aeroporto durante um ano
EXPLAIN ANALYZE
SELECT count(nvoo) as numero_voos
FROM voo JOIN aeroporto
ON aeroporto.codaeropor=voo.fk_codaeropor
WHERE (voo.horario BETWEEN '2024-01-01' AND '2025-01-01') and aeroporto.nome ='Talisman';

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS voo_idx_horario on voo(horario);
CREATE INDEX IF NOT EXISTS aeroporto_idx_nome on aeroporto(nome);
CREATE INDEX IF NOT EXISTS aeroporto_idx_trgm_nome on aeroporto using GIN(nome gin_trgm_ops);

--2.Ver quantidade de voos por empresa num intervalo de tempo
EXPLAIN ANALYZE
SELECT count(nvoo) as numero_voos
FROM voo WHERE companhia='GOL'
AND (voo.horario between '2024-01-01' AND '2025-01-01');

CREATE INDEX IF NOT EXISTS voo_idx_companhia on voo(companhia);

--3. Ver classes de voo mais contratada pelos clientes, em uma dada companhia aérea, em um intervalo de tempo.
EXPLAIN ANALYZE
SELECT cliente.nome, passagem.preco FROM cliente JOIN passagem ON cliente.cpf=passagem.fk_cpf
WHERE passagem.preco BETWEEN 1499.99 AND 2000.00
ORDER BY passagem.preco DESC;

CREATE INDEX IF NOT EXISTS passagem_idx_preco on passagem(preco);
