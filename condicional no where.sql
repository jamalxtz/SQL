Existem diversas soluções, vou citar 3 delas.

Nos exemplos abaixo verifico se a variável @idUsuario é nula, se não for efetuo a busca do nome do usuário com o idUsuario correspondente a variável.

Alternativa com CASE WHEN:

DECLARE @idUsuario INT 
SET @idUsuario = 1

SELECT 
    Nome 
FROM
    Usuario
WHERE 
    idUsuario = (
        CASE WHEN @idUsuario IS NULL THEN
            idUsuario 
        ELSE
            @idUsuario 
        END
    )