-- Select apenas para consultar se existe algum produto com uma marca invalida cadastrada.
select produtos.nome,
codigomarca
from Produtos
where CodigoMarca Not IN (
  SELECT Codigo
  FROM marcas);

--Verifica se a marca codigo 0, padrao do sistema j� est� cadastrada.
If Exists (Select * from Marcas where Codigo = 0 )
begin
     --Se a marca existir, exibe mensagem
     print ('Marca padr�o j� est� cadastrada')
 end
else
 begin
   --Se o valor n�o existir, realiza o insert
   Insert into Marcas (codigo,nome, ATZDH, ATZPT) values (0,' ', GETDATE(), '|00|')
select * from Marcas order by Codigo
end



-- Faz o update alterando a marca inv�lida para a marca padr�o (c�digo 0)
UPDATE Produtos
SET codigomarca = 0
where CodigoMarca Not IN (
  SELECT Codigo
  FROM marcas);


  ALTER TABLE Produtos
   ADD CONSTRAINT FK_Marcas_Produtos FOREIGN KEY (CodigoMarca)
      REFERENCES Marcas (Codigo)

-- Teste de verifica��o da chave estrangeira
delete from Marcas
where Codigo = 0
