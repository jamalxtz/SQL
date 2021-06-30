DECLARE @DI AS nvarchar(10)
DECLARE @DF AS nvarchar(10)
DECLARE @SINTETICO AS nvarchar(MAX)
DECLARE @ANALITICO AS nvarchar(MAX)
DECLARE @OPCAO AS INT
DECLARE @VEN AS nvarchar(MAX)
SET @DI = '?DATA INICIAL?'
SET @DF = '?DATA FINAL?'
SET @VEN = '?COD VENDEDOR?'
SET @OPCAO = '?DIGITE A OPCAO (1 - SINTETICO, 2 - ANALITICO)?'
SET @SINTETICO = 'SELECT
	*
FROM
	(SELECT
		SUB.Cliente,
		SUM(SUB.Volume) AS Volume,
		SUM(SUB.Total) AS Total
	FROM
		(SELECT
			Saidas.Codigo,
			LTRIM(STR(Saidas.CodigoCliente)+''  ''+Clientes.NomeRazaoSocial) AS Cliente,
			SUM(SP.Quantidade) AS Volume,
			TotaisTotal AS Total
		FROM
			Saidas
			INNER JOIN SaidasProdutos SP ON Saidas.Codigo = SP.CodigoSaida
			INNER JOIN Clientes ON Saidas.CodigoCliente = Clientes.Codigo
		WHERE
			Saidas.Cancelado <> ''SIM''
			AND Saidas.Tipo IN (''VENDA'',''TROCA'',''ORDEM DE SERVIÇO'')
			AND Saidas.Data BETWEEN '''+@DI+''' AND '''+@DF+'''
			AND Saidas.CodigoVendedor = '''+@VEN+'''
		GROUP BY
			Saidas.CodigoCliente,
			Clientes.NomeRazaoSocial,
			Saidas.Codigo,
			Saidas.TotaisTotal) AS SUB
	GROUP BY
		SUB.Cliente) AS FINAL
ORDER BY
	FINAL.Total DESC'

SET @ANALITICO = 'SELECT
	Saidas.Codigo,
	Saidas.Data,
	Saidas.Tipo,
	LTRIM(STR(Saidas.CodigoCliente)+''  ''+Clientes.NomeRazaoSocial) AS Cliente,
	SUM(SP.Quantidade) AS Volume,
	TotaisTotal AS Total
FROM
	Saidas
	INNER JOIN SaidasProdutos SP ON Saidas.Codigo = SP.CodigoSaida
	INNER JOIN Clientes ON Saidas.CodigoCliente = Clientes.Codigo
WHERE
	Saidas.Cancelado <> ''SIM''
	AND Saidas.Tipo IN (''VENDA'',''TROCA'',''ORDEM DE SERVIÇO'')
	AND Saidas.Data BETWEEN '''+@DI+''' AND '''+@DF+'''
	AND Saidas.CodigoVendedor = '''+@VEN+'''
GROUP BY
	Saidas.Data,
	Saidas.Tipo,
	Saidas.CodigoCliente,
	Clientes.NomeRazaoSocial,
	Saidas.Codigo,
	Saidas.TotaisTotal
ORDER BY
	Saidas.Data DESC'


BEGIN
	IF @OPCAO = 1
		EXECUTE (@SINTETICO);
	IF @OPCAO = 2
		EXECUTE (@ANALITICO);
	IF @OPCAO > 2
		(SELECT '**** OPCAO INVALIDA ****' AS Texto UNION ALL 
		SELECT '1 - CONSULTA RESUMIDA' AS Texto UNION ALL 
		SELECT '2 - CONSULTA DETALHADA' AS Texto)
	IF @OPCAO = ''
		(SELECT '**** OPCAO INVALIDA ****' AS Texto UNION ALL 
		SELECT '1 - CONSULTA RESUMIDA' AS Texto UNION ALL 
		SELECT '2 - CONSULTA DETALHADA' AS Texto)
END