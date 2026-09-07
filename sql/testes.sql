SELECT COUNT(*) FROM fato_pedido;

SELECT canal_pedido, COUNT(*) FROM fato_pedido GROUP BY canal_pedido;

SELECT COUNT(*) FROM fato_pedido;                    -- deve dar 4044
SELECT ROUND(SUM(vl_liquido)) FROM fato_pedido;       -- deve dar 1.793.309
SELECT 'Dt Separacao Estoque' AS marco,
       SUM(CASE WHEN dias_integracao_separacao IS NULL THEN 1 ELSE 0 END) AS em_branco
FROM fato_pedido;

SELECT SUM(CASE WHEN dias_separacao_nota IS NULL THEN 1 ELSE 0 END) FROM fato_pedido;

SELECT SUM(CASE WHEN dias_nota_despacho IS NULL THEN 1 ELSE 0 END) FROM fato_pedido;

SELECT SUM(CASE WHEN dias_despacho_entrega IS NULL THEN 1 ELSE 0 END) FROM fato_pedido;

SELECT COUNT(*) AS linhas, '4044' AS esperado FROM fato_pedido;

SELECT 'FK nula' AS teste, COUNT(*) AS deve_ser_zero FROM fato_pedido
WHERE sk_loja IS NULL OR sk_categoria IS NULL
   OR sk_tempo_pedido IS NULL OR sk_tempo_entrega IS NULL;

SELECT MIN(DATE(dt_pedido)) AS primeiro_pedido, MAX(DATE(dt_pedido)) AS ultimo_pedido
FROM fato_pedido;

SELECT 'dias negativos' AS teste, COUNT(*) AS deve_ser_zero FROM fato_pedido
WHERE dias_integracao_separacao < 0 OR dias_separacao_nota < 0
   OR dias_nota_despacho < 0 OR dias_despacho_entrega < 0
   OR dias_total_ate_entrega < 0;