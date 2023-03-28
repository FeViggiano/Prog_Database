--Tratamento de exceções
DO $$
BEGIN
	RAISE NOTICE '%', 1 / 0;
EXCEPTION
	WHEN division_by_zero THEN
		RAISE NOTICE 'Não dividirás por 0';
END;
$$



DO $$
DECLARE 
	aux INT := valor_aleatorio_entre(0, 3);
BEGIN 
	If aux = 0 THEN
		RAISE 'aux não pode ser zero';
	ELSE 
		RAISE 'aux: %', aux;
	END IF;
EXCEPTION WHEN OTHERS THEN
	RAISE NOTICE 'Execeção %, %', SQLSTATE, SQLERRM; -- SQLERM (mensagem de erro)



--Foreach, vetor, matriz, slice(fatia)
DO $$
DECLARE

	vetor INT[] := ARRAY [1, 2, 3];
	matriz INT[] := ARRAY [
		[1, 2, 3],
		[4, 5, 6], --Objeto de duas dimensões (linha e coluna)
		[7, 8, 9]
	];
	var_aux INT;
	vet_aux INT [];

BEGIN
	--vetor sem slice
	FOREACH var_aux IN ARRAY vetor LOOP
		RAISE NOTICE '%', var_aux;
		
	END LOOP;
	--vetor com slice igual a 1
	FOREACH vet_aux SLICE 1 IN ARRAY vetor LOOP
		RAISE NOTICE '%', vet_aux;
	
	
	END LOOP;
	--matriz, sem slice
	FOREACH var_aux IN ARRAY matriz LOOP
		RAISE NOTICE '%', var_aux;
	END LOOP;
	
	
	FOREACH vet_aux SLICE 1 IN ARRAY matriz LOOP -- 1 dimensão
		RAISE NOTICE '%', vet_aux;
	END LOOP;
	
	

	FOREACH vet_aux SLICE 2 IN ARRAY matriz LOOP -- 1 dimensão
		RAISE NOTICE '%', vet_aux;
	END LOOP;

END;
$$





--Foreach com vetor simples
DO $$
DECLARE
	valores INT[] := ARRAY [
	valor_aleatorio_entre(1,10),
	valor_aleatorio_entre(1,10),
	valor_aleatorio_entre(1,10),
	valor_aleatorio_entre(1,10),
	valor_aleatorio_entre(1,10)
	];
	
	valor INT;
	soma INT := 0;
	
BEGIN
	FOREACH valor IN ARRAY valores LOOP
		RAISE NOTICE 'Valor da vez: %', valor;
		soma := soma + valor;
	END LOOP;
	RAISE NOTICE 'Soma: %', soma;

END;
$$

	
		
	
-- Clase Aluno
DO $$
DECLARE 
	aluno RECORD;
	media NUMERIC(10, 2) := 0;
	total INT;
	menor INT := 10;
	maior INT := 0;
	--Mostrar a menor nota
BEGIN 
	FOR aluno IN
		SELECT * FROM tb_aluno
	LOOP
		RAISE NOTICE '%', aluno;
		RAISE NOTICE 'Código: % e nota:%', aluno.cod_aluno, aluno.nota;
		media := media + aluno.nota;
		IF aluno.nota < menor THEN
			menor := aluno.nota;
		END IF;
		IF aluno.nota > maior THEN
			maior := aluno.nota;
		END IF;
	END LOOP;
	SELECT COUNT(*) FROM tb_aluno INTO total;
	RAISE NOTICE 'Média: %', media / total;
	RAISE NOTICE 'A menor nota foi: %', menor;
	RAISE NOTICE 'A maior nota foi: %', maior;

END;
$$

SELECT MAX(nota) FROM tb_aluno


-- Iterando sobre as linhas de uma tabela com FOR
DO $$
BEGIN
	FOR i IN 1..10 LOOP
		INSERT INTO tb_aluno (nota) VALUES (valor_aleatorio_entre(0, 10));
	END LOOP;
END;
$$

SELECT * FROM tb_aluno



-- Tabela de notas 
CREATE TABLE tb_aluno(
	cod_aluno SERIAL PRIMARY KEY,
	NOTA INT
);
-- Itenrando com FOR
DO $$
BEGIN	
	-- Com REVERSE
	FOR i IN REVERSE 10..1 LOOP
		RAISE NOTICE '%', i;
	END LOOP;

	-- de 1 a 10 de um em um
	FOR i IN 1..10 LOOP
		RAISE NOTICE '%', i;
	END LOOP;
	
	-- e agora?
	RAISE NOTICE 'de 10 a 1...'; --Esse código não faz nada
	FOR i IN 10..1 LOOP
		RAISE NOTICE '%', i;
	END LOOP;
END;
$$


-- Media WHILE
DO $$
DECLARE 
	nota INT;
	media NUMERIC (10, 2) := 0;
	contador INT := 0;
BEGIN
-- Inicialmente, valores de 0 a 11
-- Com o -1, temos valores de -1 a 10
	SELECT valor_aleatorio_entre (0, 11) -1 INTO nota;
	WHILE nota >= 0 LOOP
		RAISE NOTICE '%', nota;
		media := media + nota;
		contador := contador + 1;	
		SELECT valor_aleatorio_entre(0, 11) -1 INTO nota;
	END LOOP; 
		IF contador > 0 THEN
			RAISE NOTICE 'Média %.', media / contador;
		ELSE
			RAISE NOTICE 'Nenhuma nota gerada.';
		END IF;
END; 
$$



-- Utilizando rotulos com CONTINUE
DO $$
DECLARE

	i INT;
	j INT;

BEGIN
	i := 0;
	<<externo>>
	LOOP
		i := i + 1;
		EXIT WHEN i > 10;
		j := 1;
		<<interno>>
		LOOP
			RAISE NOTICE '% %', i, j;
			j := j + I;
			EXIT WHEN j > 10;
			CONTINUE externo WHEN j > 5;
		END LOOP;
		RAISE NOTICE 'teste';
	END LOOP;
END;
$$



--Rótulos
DO $$
DECLARE

	i INT;
	j INT;

BEGIN
	i := 0;
	<<externo>> --Rotulando o loop
	LOOP
		i := i + 1;
		EXIT WHEN i > 10;
		j := 1;
	
		<<interno>> --Rotulando o loop
		LOOP
			RAISE NOTICE '% %', i, j;
			j := j + 1;
			EXIT WHEN j > 10;
			EXIT externo WHEN j > 5;
		
		END LOOP;
	
	
	END LOOP;

END;
$$


--Contador de 10 a 100, pulando múltiplos de 7 e 11
DO $$
DECLARE

	contador INT := 10;
	
BEGIN
	LOOP
		contador := contador + 1;
		EXIT WHEN contador > 100;
		--Ignorar a interação quando o contador for múltiplo de 7
		IF contador % 7 = 0 THEN
			CONTINUE;
		END IF;
		--Ignorar a interação quando o contador for múltiplo de 11
		CONTINUE WHEN contador % 11 = 0;
		RAISE NOTICE '%', contador;
	END LOOP;

END;
$$
-- Conceito de Syntax Sugar


--Possibilidade com exit/when (Contador de 1 a 10)
DO $$
DECLARE

	contador INT :=1;
	
BEGIN
	LOOP
	
		RAISE NOTICE '%', contador;
		contador := contador + 1;
		EXIT WHEN contador > 10;
		
	END LOOP;

END;
$$

--Contador de 1 a 10
DO $$
DECLARE

	contador INT :=1;

BEGIN
	LOOP
		RAISE NOTICE '%', contador;
		contador := contador + 1; -- Não podemos utilizar +=
		
		
		IF contador > 10 THEN
			EXIT; -- Funciona como o 'Break' de Python
	
	
		END IF;
	END LOOP;
	
END;
$$



--Testando um loop simples
DO $$
BEGIN
	LOOP
	
		RAISE NOTICE 'Teste de loop simples...';
	END LOOP;

END;
$$