--Consulta com recursividade bem detalhada

-- O With
WITH Months (VariavelData) 
AS( 
	SELECT CAST('01/01/2021' AS DATETIME) 
	UNION ALL 
	SELECT DATEADD(month, 1, VariavelData) 
	FROM Months 
	WHERE DATEADD(month, 1, VariavelData) <= CAST('20/05/2021' AS DATETIME)
) 


SELECT  DATENAME(mm, VariavelData) as MesNome,
		DATEPART(mm, VariavelData) as Mes,
		DATEPART(yy, VariavelData) as Ano,
		( 
		SELECT Sum(totalsaldo) AS RESULTADO 
		FROM (SELECT CodigoContaContabil, 'CX' AS MOV, IDENTIFICADOR, (ContasContabeis.Nome +' {'+ LTRIM(STR(ContasContabeis.Codigo)) +'}') AS CONTACONTABIL, 
			Sum(CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor) AS totalCREDITO, 
			Sum(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor) AS totalDEBITO, 
			Sum((CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor)-(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor)) AS totalSALDO, 
			(ABS(Sum((CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor)-(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor))*100))/CAST('2127130.50' AS MONEY) AS FAT  
			, 0 Pendente, (SELECT (SUM((QtdMesesSemOrcamento*MediaValorOrcamentosAnuais)+(ValorOrcamentosMensais))/5) Orcamento 
		FROM(/*Referências MENSAIS no período especificado*/ 
		 SELECT 
			 5-(COUNT(*))QtdMesesSemOrcamento, 
			 (CASE WHEN(SUM(Valor))IS NULL THEN 0 ELSE (SUM(Valor))END) ValorOrcamentosMensais, 
			 (/*Referências ANUAIS no período especificado*/ 
				 SELECT (CASE WHEN(AVG(Valor))IS NULL THEN 0 ELSE (AVG(Valor))END) 
				 FROM ContasContabeisOrcamentos ContasContabeisOrcamentosAnuais 
				 WHERE (LEFT(ContasContabeisOrcamentosAnuais.Referencia,2) = 00) /*<- Ao buscar referências ANUAIS, só considera referências com o mês igual a 00*/ 
				 AND (CAST('31/12/' + RIGHT(ContasContabeisOrcamentosAnuais.Referencia,4) AS DATETIME) >= CAST('01/01/2021' AS DATETIME)) 
				 AND (CAST('01/01/' + RIGHT(ContasContabeisOrcamentosAnuais.Referencia,4) AS DATETIME) <= CAST('20/05/2021' AS DATETIME)) 
				 AND (ContasContabeisOrcamentosAnuais.CodigoContaContabil = ContasContabeis.Codigo) 
			 ) MediaValorOrcamentosAnuais 
		 FROM ContasContabeisOrcamentos ContasContabeisOrcamentosMensais 
		 WHERE (LEFT(ContasContabeisOrcamentosMensais.Referencia,2) > 00) /*<- Ao buscar referências MENSAIS, só considera referências com o mês maior que 00*/ 
		 AND (CAST('01/' + RIGHT(ContasContabeisOrcamentosMensais.Referencia,7) AS DATETIME) >= CAST('01/01/2021' AS DATETIME)) 
		 AND (CAST('01/' + RIGHT(ContasContabeisOrcamentosMensais.Referencia,7) AS DATETIME) <= CAST('20/05/2021' AS DATETIME)) 
		 AND (ContasContabeisOrcamentosMensais.CodigoContaContabil = ContasContabeis.Codigo) 
		)AS SubOrc 
		) Orcado 
		FROM ContasCaixasMovimentos INNER JOIN ContasContabeis ON ContasCaixasMovimentos.CodigoContaContabil = ContasContabeis.Codigo 
		WHERE 
		Month(Data) = DATEPART(mm, VariavelData) AND Year(Data) = DATEPART(yy, VariavelData) AND
		(Data BETWEEN CAST('01/01/2021' AS DATETIME) AND CAST('20/05/2021' AS DATETIME) AND ContasCaixasMovimentos.Situacao = 'QUITADO' AND ContasContabeis.Situacao = 'ATIVO'  AND ContasContabeis.ContaResultado IN ('RECEITAS OPERACIONAIS','DEDUÇÕES DE ABATIMENTOS','DEDUÇÕES DE IMPOSTOS','CUSTOS OPERACIONAIS','DESPESAS OPERACIONAIS','OUTRAS RECEITAS OPERACIONAIS','DESPESAS NÃO-OPERACIONAIS','RECEITAS NÃO-OPERACIONAIS','INVESTIMENTOS EM IMOBILIZADO','PARTICIPAÇÕES','NENHUMA')  AND  (ContasCaixasMovimentos.CodigoContaCaixa >= 00000000 AND ContasCaixasMovimentos.CodigoContaCaixa <= 99999999) 
		)GROUP BY ContasContabeis.ContaResultado, ContasContabeis.Codigo, CodigoContaContabil, IDENTIFICADOR, (ContasContabeis.Nome +' {'+ LTRIM(STR(ContasContabeis.Codigo)) +'}')
		 UNION SELECT CodigoContaContabil,'BC' AS MOV, IDENTIFICADOR, (ContasContabeis.Nome +' {'+ LTRIM(STR(ContasContabeis.Codigo)) +'}') AS CONTACONTABIL, 
		Sum(CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor) AS totalCREDITO, 
		Sum(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor) AS totalDEBITO, 
		Sum((CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor)-(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor)) AS totalSALDO, 
		(ABS(Sum((CASE WHEN Operacao='CRÉDITO' THEN 1 ELSE 0 END * Valor)-(CASE WHEN Operacao='DÉBITO' THEN 1 ELSE 0 END * Valor))*100))/CAST('2127130.50' AS MONEY) AS FAT 
		, 0 Pendente, (SELECT (SUM((QtdMesesSemOrcamento*MediaValorOrcamentosAnuais)+(ValorOrcamentosMensais))/5) Orcamento 
		FROM(/*Referências MENSAIS no período especificado*/ 
		 SELECT 
			 5-(COUNT(*))QtdMesesSemOrcamento, 
			 (CASE WHEN(SUM(Valor))IS NULL THEN 0 ELSE (SUM(Valor))END) ValorOrcamentosMensais, 
			 (/*Referências ANUAIS no período especificado*/ 
				 SELECT (CASE WHEN(AVG(Valor))IS NULL THEN 0 ELSE (AVG(Valor))END) 
				 FROM ContasContabeisOrcamentos ContasContabeisOrcamentosAnuais 
				 WHERE (LEFT(ContasContabeisOrcamentosAnuais.Referencia,2) = 00) /*<- Ao buscar referências ANUAIS, só considera referências com o mês igual a 00*/ 
				 AND (CAST('31/12/' + RIGHT(ContasContabeisOrcamentosAnuais.Referencia,4) AS DATETIME) >= CAST('01/01/2021' AS DATETIME)) 
				 AND (CAST('01/01/' + RIGHT(ContasContabeisOrcamentosAnuais.Referencia,4) AS DATETIME) <= CAST('20/05/2021' AS DATETIME)) 
				 AND (ContasContabeisOrcamentosAnuais.CodigoContaContabil = ContasContabeis.Codigo) 
			 ) MediaValorOrcamentosAnuais 
		 FROM ContasContabeisOrcamentos ContasContabeisOrcamentosMensais 
		 WHERE (LEFT(ContasContabeisOrcamentosMensais.Referencia,2) > 00) /*<- Ao buscar referências MENSAIS, só considera referências com o mês maior que 00*/ 
		 AND (CAST('01/' + RIGHT(ContasContabeisOrcamentosMensais.Referencia,7) AS DATETIME) >= CAST('01/01/2021' AS DATETIME)) 
		 AND (CAST('01/' + RIGHT(ContasContabeisOrcamentosMensais.Referencia,7) AS DATETIME) <= CAST('20/05/2021' AS DATETIME)) 
		 AND (ContasContabeisOrcamentosMensais.CodigoContaContabil = ContasContabeis.Codigo) 
		)AS SubOrc 
		) Orcado 
		FROM ContasBancosMovimentos INNER JOIN ContasContabeis ON ContasBancosMovimentos.CodigoContaContabil = ContasContabeis.Codigo 
		WHERE 
		Month(Quitacao) = DATEPART(mm, VariavelData) AND Year(Quitacao) = DATEPART(yy, VariavelData) AND
		(Quitacao BETWEEN CAST('01/01/2021' AS DATETIME) AND CAST('20/05/2021' AS DATETIME) AND ContasBancosMovimentos.Situacao = 'QUITADO' AND ContasContabeis.Situacao = 'ATIVO'  AND ContasContabeis.ContaResultado IN ('RECEITAS OPERACIONAIS','DEDUÇÕES DE ABATIMENTOS','DEDUÇÕES DE IMPOSTOS','CUSTOS OPERACIONAIS','DESPESAS OPERACIONAIS','OUTRAS RECEITAS OPERACIONAIS','DESPESAS NÃO-OPERACIONAIS','RECEITAS NÃO-OPERACIONAIS','INVESTIMENTOS EM IMOBILIZADO','PARTICIPAÇÕES','NENHUMA')  AND  (ContasBancosMovimentos.CodigoContaBanco >= 00000000 AND ContasBancosMovimentos.CodigoContaBanco <= 99999999) 
		)GROUP BY ContasContabeis.ContaResultado, ContasContabeis.Codigo, CodigoContaContabil, IDENTIFICADOR, (ContasContabeis.Nome +' {'+ LTRIM(STR(ContasContabeis.Codigo)) +'}')
		) AS SUB

		   --WHERE CodigoContaContabil = 2
		) AS TotalTotal



FROM Months