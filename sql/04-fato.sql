-- =====================================================================================
--  ARQUIVO 4:  A TABELA FATO
--  Case: Pata Amiga - rede de petshops de SC  |  MySQL 8.0
-- =====================================================================================
--  Rode depois de: 03-dimensoes.sql
--
--  UMA fato, UM unico INSERT ... SELECT. 4.044 linhas = 4.044 pedidos.
-- =====================================================================================

USE dw_pata_amiga;

TRUNCATE TABLE fato_pedido;

INSERT INTO fato_pedido (
    numero_pedido,
    sk_tempo_pedido,
    sk_tempo_entrega,
    sk_loja,
    sk_categoria,
    houve_desconto,
    canal_pedido,
    dt_pedido,
    qt_itens,
    vl_liquido,
    dias_integracao_separacao,
    dias_separacao_nota,
    dias_nota_despacho,
    dias_despacho_entrega,
    dias_total_ate_entrega
)
SELECT
    p.`NumeroPedido`,

    -- sk_tempo_pedido: data do pedido, formato americano com AM/PM
    CAST(DATE_FORMAT(STR_TO_DATE(p.`DtHoraPedido`, '%m/%d/%Y %h:%i %p'), '%Y%m%d') AS SIGNED),

    -- sk_tempo_entrega: ja vem em ISO; entrega em branco -> -1
    CASE WHEN p.`DtEntregaCliente` = '' THEN -1
         ELSE CAST(DATE_FORMAT(DATE(p.`DtEntregaCliente`), '%Y%m%d') AS SIGNED)
    END,

    -- sk_loja: padroniza o nome (REPLACE + CASE das 3 grafias) antes do lookup
    COALESCE(dl.sk_loja, -1),

    -- sk_categoria: JOIN de uma linha so, pela grafia crua
    COALESCE(dc.sk_categoria, -1),

    -- houve_desconto: 17 grafias -> 3 valores
    CASE
        WHEN UPPER(TRIM(p.`HouveDesconto`)) IN ('S','SIM','1','X','TRUE','V') THEN 'Sim'
        WHEN UPPER(TRIM(p.`HouveDesconto`)) IN ('N','NAO','0','FALSE','F')    THEN 'Nao'
        ELSE 'Nao Informado'
    END,

    -- canal_pedido: ORDEM IMPORTA - WHATS antes de APP
    CASE
        WHEN UPPER(TRIM(p.`CanalPedido`)) LIKE '%WHATS%' THEN 'WhatsApp'
        WHEN UPPER(TRIM(p.`CanalPedido`)) LIKE '%APP%'   THEN 'App'
        WHEN UPPER(TRIM(p.`CanalPedido`)) LIKE '%SITE%'  THEN 'Site'
        WHEN UPPER(TRIM(p.`CanalPedido`)) LIKE '%LOJA%'  THEN 'Loja Fisica'
        WHEN UPPER(TRIM(p.`CanalPedido`)) LIKE '%TEL%'   THEN 'Telefone'
        ELSE 'Nao Informado'
    END,

    -- dt_pedido
    STR_TO_DATE(p.`DtHoraPedido`, '%m/%d/%Y %h:%i %p'),

    -- qt_itens: vazio ou '-' vira NULL, nunca 0
    CASE WHEN TRIM(p.`QTD.Itens`) IN ('', '-') THEN NULL
         ELSE CAST(p.`QTD.Itens` AS SIGNED)
    END,

    -- vl_liquido: a regra dos numeros (secao 2 do enunciado)
    CASE WHEN TRIM(REPLACE(p.`ValorLiquidoPedido(R$)`,'R$','')) IN ('','-') THEN NULL
         WHEN p.`ValorLiquidoPedido(R$)` LIKE '%,%'
              THEN CAST(REPLACE(REPLACE(REPLACE(REPLACE(p.`ValorLiquidoPedido(R$)`,'R$',''),' ',''),'.',''),',','.')
                   AS DECIMAL(15,2))
         ELSE CAST(REPLACE(REPLACE(p.`ValorLiquidoPedido(R$)`,'R$',''),' ','') AS DECIMAL(15,2))
    END,

    -- dias_integracao_separacao
    CASE WHEN p.`Dt Separacao Estoque` = '' THEN NULL
         ELSE DATEDIFF(
             DATE(p.`Dt Separacao Estoque`),
             DATE(STR_TO_DATE(p.`DtHoraIntegracaoERP`, '%m/%d/%Y %h:%i %p'))
         )
    END,

    -- dias_separacao_nota
    CASE WHEN p.`Dt Separacao Estoque` = '' OR p.`DtNotaFiscal` = '' THEN NULL
         ELSE DATEDIFF(DATE(p.`DtNotaFiscal`), DATE(p.`Dt Separacao Estoque`))
    END,

    -- dias_nota_despacho
    CASE WHEN p.`DtNotaFiscal` = '' OR p.`Dt_Despacho_Transportadora` = '' THEN NULL
         ELSE DATEDIFF(DATE(p.`Dt_Despacho_Transportadora`), DATE(p.`DtNotaFiscal`))
    END,

    -- dias_despacho_entrega
    CASE WHEN p.`Dt_Despacho_Transportadora` = '' OR p.`DtEntregaCliente` = '' THEN NULL
         ELSE DATEDIFF(DATE(p.`DtEntregaCliente`), DATE(p.`Dt_Despacho_Transportadora`))
    END,

    -- dias_total_ate_entrega: o processo inteiro, do ERP ate a entrega (resposta da P1)
    CASE WHEN p.`DtEntregaCliente` = '' THEN NULL
         ELSE DATEDIFF(
             DATE(p.`DtEntregaCliente`),
             DATE(STR_TO_DATE(p.`DtHoraIntegracaoERP`, '%m/%d/%Y %h:%i %p'))
         )
    END

FROM stg_pedido p
LEFT JOIN dim_loja dl
    ON dl.chave_loja =
       CASE
           WHEN UPPER(TRIM(REPLACE(REPLACE(p.`Loja-Nome`, '/SC', ''), '  ', ' '))) = 'PATA AMIGA BLUMENAL CENTRO' THEN 'PATA AMIGA BLUMENAU CENTRO'
           WHEN UPPER(TRIM(REPLACE(REPLACE(p.`Loja-Nome`, '/SC', ''), '  ', ' '))) = 'PATA AMIGA FLORIPA NORTE'   THEN 'PATA AMIGA FLORIANOPOLIS NORTE'
           WHEN UPPER(TRIM(REPLACE(REPLACE(p.`Loja-Nome`, '/SC', ''), '  ', ' '))) = 'PATA AMIGA JGUA DO SUL'     THEN 'PATA AMIGA JARAGUA DO SUL'
           ELSE UPPER(TRIM(REPLACE(REPLACE(p.`Loja-Nome`, '/SC', ''), '  ', ' ')))
       END
LEFT JOIN dim_categoria dc
    ON dc.categoria_origem = p.`CategoriaProduto`;

-- =====================================================================================
--  Confira o resultado com o 00-conferencia.sql (bloco "DEPOIS DO 04").
-- =====================================================================================

--
--




