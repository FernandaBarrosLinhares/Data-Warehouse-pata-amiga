# Pata Amiga — Modelagem Dimensional (DW)

Projeto de modelagem dimensional para a rede de petshops **Pata Amiga** (Santa Catarina), construído em MySQL 8.0 a partir de três tabelas de staging com dados sujos, seguindo o roteiro da disciplina de Análise de Dados com Python/SQL.

## Como reproduzir o banco do zero

Rode os scripts na pasta `sql/`, **nesta ordem**, cada um até o fim antes de passar pro próximo:

1. `01-carga-staging.sql` — cria o banco `dw_pata_amiga` e carrega as três tabelas de staging (`stg_pedido`, `stg_loja`, `stg_loja_praca`) exatamente como vieram da origem.
2. `02-dimensoes-prontas.sql` — cria as tabelas do modelo (todas vazias) e já preenche `dim_tempo` e `dim_loja`.
3. `03-dimensoes.sql` — preenche `dim_categoria`, `dim_praca` e a tabela ponte `bridge_loja_praca`.
4. `04-fato.sql` — preenche `fato_pedido` a partir da staging, com um único `INSERT ... SELECT`.
5. `05-perguntas.sql` — as cinco consultas de negócio.

O arquivo `00-conferencia.sql` não faz parte da entrega: é uma ferramenta de apoio, rodada bloco a bloco após cada etapa, para conferir se os números batem com o esperado.

---

## Tarefa 1 — Diagnóstico da origem

Ao abrir as três tabelas de staging (`stg_pedido`, `stg_loja`, `stg_loja_praca`), encontrei os seguintes problemas de qualidade de dados:

**Grafias inconsistentes**
- `CategoriaProduto`: **18 grafias distintas** (considerando a collation do MySQL, que ignora acento e maiúscula/minúscula). Ex.: "Racao", "RACAO", "Ração", "RAÇÃO" e "Rac." representam a mesma categoria escritas de formas diferentes — por isso a Tarefa 3 monta uma `dim_categoria` para padronizar isso em 7 categorias.
- `Loja-Nome`: **128 grafias distintas**, incluindo variações de digitação, apelidos e abreviações da mesma loja, além do sufixo "/SC" e espaços duplos em alguns nomes.

**Dados faltantes**
- **1.575 pedidos (~39%)** vieram sem `Cod Loja` preenchido.
- **3 pedidos** vieram sem `Loja-Nome` — esses vão para a linha -1 ("Não Informado") da `dim_loja`.

**Marcos do processo em branco** (etapas do fluxo de entrega ainda não cumpridas na data de extração dos dados):
- `Dt Separacao Estoque`: **1.077** em branco
- `DtNotaFiscal`: **1.338** em branco
- `Dt_Despacho_Transportadora`: **1.665** em branco
- `DtEntregaCliente`: **1.953** em branco (quase metade dos pedidos ainda não foi entregue)

Esses marcos em branco indicam pedidos com o processo de entrega ainda em aberto — por isso, na Tarefa 4, essas ausências são gravadas como `NULL` (nunca como 0), preservando o significado de "etapa não cumprida".

---

## Tarefa 2 — Tratamento

_[a preencher: máscara de data escolhida e por quê, de-para das categorias, padronização do nome da loja]_

## Tarefa 3 — Construção das dimensões

_[a preencher: como `dim_categoria`, `dim_praca` e `bridge_loja_praca` foram montadas]_

## Tarefa 4 — Tabela fato

_[a preencher: decisões sobre `fato_pedido`]_

## Tarefa 5 — Respostas de negócio

_[a preencher: as cinco perguntas, cada uma com o número e a explicação]_

## Diagrama do modelo

_[a preencher: imagem do modelo estrela]_

## Vídeo

_[a preencher: link do vídeo no Google Drive]_
