-- Traz Saidas do tipo 'VENDA','TROCA','ORDEM DE SERVIÇO'
-- Filtradas por ano, linha e vendedor
-- O valor total e qtde é ref. apenas ao produto vendido
-- Já considerando os descontos da venda

DECLARE @ANOBASE AS NVARCHAR(10); 
DECLARE @ANOCOMPARATIVO AS NVARCHAR(10); 
SET @ANOBASE = '?ANO BASE: *?'; 
SET @ANOCOMPARATIVO = '?ANO COMPARATIVO: *?';
DECLARE @SAIDASVALOR AS nvarchar(MAX);

DECLARE @VENDEDOR AS NVARCHAR (MAX)
SET @VENDEDOR = '?CODIGO DO VENDEDOR:?'
DECLARE @LINHA AS NVARCHAR (MAX)
SET @LINHA = ''

select
Vendedor,
Linha,
AnoBase,
SUM(ABQtd) as ABQtd,
SUM(ABTotal) as ABTotal,
AnoComparativo,
SUM(ACQtd) as ACQtd,
SUM(ACTotal) as ACTotal

from
(
select
Vendedor,
Linha AS Linha,
@ANOBASE as 'AnoBase',
sum(qtde) as 'ABQtd' ,
sum(totaldescontado) as 'ABTotal',
@ANOCOMPARATIVO as 'AnoComparativo',
sum(0) as 'ACQtd',
sum(0) as 'ACTotal'

from  
(
Select
YEAR(@ANOBASE) AS Ano, 
Prestadores.NomeRazaoSocial AS Vendedor, 
Linhas.Nome AS Linha,
sum( SaidasProdutos.Quantidade) AS Qtde,

sum(SaidasProdutos.ValorTotal - (SaidasProdutos.ValorTotal * ((((Saidas.ProdutoTotal * 100) / Saidas.ProdutoSubTotal) - 100) * (-1)/100))) as 'TotalDescontado'

From Saidas
inner join SaidasProdutos on Saidas.Codigo = SaidasProdutos.CodigoSaida
inner join Produtos on SaidasProdutos.CodigoProduto = Produtos.Codigo
inner join Linhas on  Produtos.CodigoLinha = Linhas.Codigo
inner join Prestadores on  Saidas.CodigoVendedor = Prestadores.Codigo
WHERE
	 YEAR(Saidas.data) = YEAR(@ANOBASE)
	AND Saidas.Cancelado <> 'SIM'
	AND Saidas.Tipo IN ('VENDA','TROCA','ORDEM DE SERVIÇO')
	AND Saidas.CodigoVendedor = 
	(
        CASE WHEN @VENDEDOR = '' THEN
            CodigoVendedor 
        ELSE
            @VENDEDOR
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
GROUP BY Prestadores.NomeRazaoSocial,
         SaidasProdutos.CodigoPrestador, 
		 Linhas.nome

) as sub
group by
Vendedor,
Linha

union

select
Vendedor,
Linha AS Linha,
@ANOBASE as 'AnoBase',
sum(0) as 'ABQtd',
sum(0) as 'ABTotal',
@ANOCOMPARATIVO as 'AnoComparativo',
sum(qtde) as 'ACQtd' ,
sum(totaldescontado) as 'ACTotal'

from  
(
Select
YEAR(@ANOBASE) AS Ano, 
Prestadores.NomeRazaoSocial AS Vendedor, 
Linhas.Nome AS Linha,
sum( SaidasProdutos.Quantidade) AS Qtde,

sum(SaidasProdutos.ValorTotal - (SaidasProdutos.ValorTotal * ((((Saidas.ProdutoTotal * 100) / Saidas.ProdutoSubTotal) - 100) * (-1)/100))) as 'TotalDescontado'

From Saidas
inner join SaidasProdutos on Saidas.Codigo = SaidasProdutos.CodigoSaida
inner join Produtos on SaidasProdutos.CodigoProduto = Produtos.Codigo
inner join Linhas on  Produtos.CodigoLinha = Linhas.Codigo
inner join Prestadores on  Saidas.CodigoVendedor = Prestadores.Codigo
WHERE
	 YEAR(Saidas.data) = YEAR(@ANOCOMPARATIVO)
	AND Saidas.Cancelado <> 'SIM'
	AND Saidas.Tipo IN ('VENDA','TROCA','ORDEM DE SERVIÇO')
	AND Saidas.CodigoVendedor =  
	(
        CASE WHEN @VENDEDOR = '' THEN
            CodigoVendedor 
        ELSE
            @VENDEDOR
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
GROUP BY Prestadores.NomeRazaoSocial,
         SaidasProdutos.CodigoPrestador,
		 Linhas.nome

) as SUB01
group by
Vendedor,
Linha) AS SUB02
GROUP BY Vendedor,
		Linha,
		AnoBase,
		AnoComparativo
ORDER BY ABTotal desc
