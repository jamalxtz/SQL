SELECT codigobarrasprincipal,
	   Count(*) as 'Qtd repeti��es' 
FROM ProdutosItens
GROUP BY codigobarrasprincipal
HAVING Count(*) > 1 

SELECT ReferenciaPrincipal,
	   Count(*) as 'Qtd repeti��es' 
FROM ProdutosItens
GROUP BY ReferenciaPrincipal
HAVING Count(*) > 1 