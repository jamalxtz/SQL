WITH Months (date) 
AS( 
SELECT CAST('01/01/2020' AS DATETIME) 
UNION ALL 
SELECT DATEADD(month, 1, date) 
FROM Months 
WHERE DATEADD(month, 1, date) <= CAST('28/04/2021' AS DATETIME)) 
SELECT [MesNome] = DATENAME(mm, date), [Mes] = DATEPART(mm, date), [Ano] = DATEPART(yy, date), 
[TotalTotal] = (





SELECT SUM(totaistotal) AS RESULTADO
FROM saidas
WHERE 

Month(data) = DATEPART(mm, date) AND Year(data) = DATEPART(yy, date) AND 

data BETWEEN CAST('01/01/2020' AS DATETIME) AND CAST('28/04/2021' AS DATETIME) 


-- eXEMPLO TIRADO DO BI BALANCETE (EVOLU플O) L� TEM A OP플O POR FAZER A EVOLU플O ANUAL TBM


) FROM Months