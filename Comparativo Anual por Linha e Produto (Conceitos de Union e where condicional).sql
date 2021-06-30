-- Traz Saidas do tipo 'VENDA','TROCA','ORDEM DE SERVIÇO'
-- Filtradas por PERIODO, LINHA  e PRODUTO
-- O valor total e qtde é ref. apenas ao produto vendido
-- Já considerando os descontos da venda
-- Traz resultado ref. a comparação do Periodo Base com o ano anterior
print 'teste';
DECLARE @PB_INICIAL AS NVARCHAR(10); 
DECLARE @PB_FINAL AS NVARCHAR(10);
DECLARE @PC_INICIAL AS NVARCHAR(10);
DECLARE @PC_FINAL AS NVARCHAR(10);  
SET @PB_INICIAL = '?PERIODO BASE INICIAL: *?'; 
SET @PB_FINAL = '?PERIODO BASE FINAL: *?';
--SET @PB_INICIAL = '17/03/2021'; 
--SET @PB_FINAL = '17/03/2021';
------------------------------
SET @PC_INICIAL = convert(varchar(15),((dateadd(year,-1,@PB_INICIAL))),103);
--PRINT @PC_INICIAL;
SET @PC_FINAL =  convert(varchar(15),((dateadd(year,-1,@PB_FINAL))),103);
--PRINT @PC_FINAL;
--SET @PC_INICIAL = '17/03/2021';
--SET @PC_FINAL = '17/03/2021';

DECLARE @SAIDASVALOR AS nvarchar(MAX);

DECLARE @PRODUTO AS NVARCHAR (MAX)
SET @PRODUTO = '?COD PRODUTO?'
--SET @PRODUTO = ''
DECLARE @LINHA AS NVARCHAR (MAX)
SET @LINHA = '?COD LINHA?'
--SET @LINHA = ''

SELECT
Produto,
Linha,
PeriodoBase,
SUM(PBQtd) AS PBQtd,
SUM(PBTotal) AS PBTotal,
' | ' as ' | ' ,
PeriodoComparativo,
SUM(PCQtd) AS PCQtd,
SUM(PCTotal) AS PCTotal

FROM
(
	SELECT
	Produto,
	Linha AS Linha,
	@PB_INICIAL + ' - ' + @PB_FINAL AS 'PeriodoBase',
	SUM(qtde) AS 'PBQtd' ,
	SUM(totaldescontado) AS 'PBTotal',
	@PC_INICIAL + ' - ' + @PC_FINAL AS 'PeriodoComparativo',
	SUM(0) AS 'PCQtd',
	SUM(0) AS 'PCTotal'

	FROM  
	(
		SELECT
		@PB_INICIAL + ' - ' + @PB_FINAL AS Ano, 
		Produtos.Nome AS Produto, 
		Linhas.Nome AS Linha,
		sum( SaidasProdutos.Quantidade) AS Qtde,

		sum(SaidasProdutos.ValorTotal - (SaidasProdutos.ValorTotal * ((((Saidas.ProdutoTotal * 100) / Saidas.ProdutoSubTotal) - 100) * (-1)/100))) as 'TotalDescontado'

		From Saidas
		INNER JOIN SaidasProdutos ON Saidas.Codigo = SaidasProdutos.CodigoSaida
		INNER JOIN Produtos ON SaidasProdutos.CodigoProduto = Produtos.Codigo
		INNER JOIN Linhas ON Produtos.CodigoLinha = Linhas.Codigo
		WHERE
			(Saidas.data >= @PB_INICIAL AND  Saidas.data <= @PB_FINAL)
			AND Saidas.Cancelado <> 'SIM'
			AND Saidas.Tipo IN ('VENDA','TROCA','ORDEM DE SERVIÇO')
			AND SaidasProdutos.CodigoProduto = 
			(
				CASE WHEN @PRODUTO = '' THEN
					CodigoProduto 
				ELSE
					@PRODUTO
				END
			)
			AND Produtos.CodigoLinha = 
			(
				CASE WHEN @LINHA = '' THEN
					CodigoLinha 
				ELSE
					@LINHA
				END
			)
		GROUP BY Produtos.Nome,
				 Linhas.nome

		) AS sub
	GROUP BY
	Produto,
	Linha

	-------------------
	UNION
	-------------------

	SELECT
	Produto,
	Linha AS Linha,
	@PB_INICIAL + ' - ' + @PB_FINAL AS 'PeriodoBase',
	SUM(0) AS 'PBQtd',
	SUM(0) AS 'PBTotal',
	@PC_INICIAL + ' - ' + @PC_FINAL AS 'PeriodoComparativo',
	SUM(qtde) AS 'PCQtd' ,
	SUM(totaldescontado) AS 'PCTotal'

	FROM  
	(
		Select
		@PC_INICIAL + ' - ' + @PC_FINAL AS Ano,  
		Produtos.Nome AS Produto, 
		Linhas.Nome AS Linha,
		SUM( SaidasProdutos.Quantidade) AS Qtde,

		SUM(SaidasProdutos.ValorTotal - (SaidasProdutos.ValorTotal * ((((Saidas.ProdutoTotal * 100) / Saidas.ProdutoSubTotal) - 100) * (-1)/100))) as 'TotalDescontado'

		From Saidas
		INNER JOIN SaidasProdutos ON Saidas.Codigo = SaidasProdutos.CodigoSaida
		INNER JOIN Produtos ON SaidasProdutos.CodigoProduto = Produtos.Codigo
		INNER JOIN Linhas ON  Produtos.CodigoLinha = Linhas.Codigo
		WHERE
			(Saidas.data >= @PC_INICIAL AND  Saidas.data <= @PC_FINAL)
			AND Saidas.Cancelado <> 'SIM'
			AND Saidas.Tipo IN ('VENDA','TROCA','ORDEM DE SERVIÇO')
			AND SaidasProdutos.CodigoProduto =  
			(
				CASE WHEN @PRODUTO = '' THEN
					CodigoProduto 
				ELSE
					@PRODUTO
				END
			)
			AND Produtos.CodigoLinha = 
			(
				CASE WHEN @LINHA = '' THEN
					CodigoLinha 
				ELSE
					@LINHA
				END
			)
		GROUP BY Produtos.Nome,
				 Linhas.nome

		) AS SUB01

	GROUP BY
	Produto,
	Linha
	) AS SUB02

GROUP BY Produto,
		Linha,
		PeriodoBase,
		PeriodoComparativo
ORDER BY PBTotal desc
