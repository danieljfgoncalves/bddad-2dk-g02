SET SERVEROUTPUT ON;

-- ##################### VIEWS #####################

-- ### TESTAR VIEW 1 ###
  SELECT * FROM VW_HORAS_VOO_POR_AVIAO;
-- ### FIM TESTE VIEW 1 ###

-- ### TESTAR VIEW 2 ###
  SELECT * FROM VW_VOOS_TD_SEMANA;
-- ### FIM TESTE VIEW 2 ###

-- ### TESTAR VIEW 3 ###
  SELECT * FROM VW_VIAGENS_MAIOR_ATRASO;
-- ### FIM TESTE VIEW 3 ###


-- ##################### FUNÇÕES #####################

-- ### TESTAR FUNCTION 4 ###
	-- PARAM: VOO_ID, CLASSE_ID
	SELECT FC_VOO_MAIS_BARATO(1, 1) FROM DUAL;
	-- Output (Verificar se é realmente o mais barato para aquele voo)
	SELECT VR.VOO_REGULAR_ID, P.CLASSE_ID
    FROM VOO_REGULAR VR, PRECO P
    WHERE VR.VOO_ID = 1
      AND P.CLASSE_ID = 1
      AND VR1.VOO_REGULAR_ID = P1.VOO_REGULAR_ID;
-- ### FIM TESTE FUNCTION 4 ###

-- ### TESTAR FUNCTION 5 ###
  SELECT FC_SALARIO_TOTAL(13, 12) FROM DUAL;
-- ### FIM TESTE FUNCTION 5 ###

-- ### TESTAR FUNCTION 6 ###
	-- PARAM: VOO_REGULAR_ID
	SELECT FC_PODE_ALOCAR_AVIAO(1) FROM DUAL;
	-- Output: 
	-- Verificar ultima viagem e hora de chegada do aviao
	SELECT VR.AVIAO, V.AEROPORTO_DESTINO, TO_CHAR(VP.DATA_PLANEADA_CHEGADA, 'HH24:MI') AS HORA_CHEGADA
    FROM VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
   	WHERE VP.VOO_REGULAR = VR.VOO_REGULAR_ID
      AND VR.VOO_ID = V.VOO_ID
    ORDER BY VP.DATA_PLANEADA_CHEGADA DESC;
	-- comparar com a origem e hora de partida do voo regular novo
	SELECT V.AEROPORTO_ORIGEM, VR.HORARIO_PARTIDA
    FROM VOO V, VOO_REGULAR VR
   	WHERE VR.VOO_REGULAR_ID = 1
      AND VR.VOO_ID = V.VOO_ID;
-- ### FIM TESTE FUNCTION 6 ###


-- ##################### PROCEDURES #####################

-- ### TESTAR PROCEDURE 7 ###
  EXECUTE PC_VIAGENS_DISPONIVEIS;
-- ### FIM TESTE PROCEDURE 7 ###

-- ### TESTAR PROCEDURE 8 ###
	-- PARAM: PLANO_ID
	EXECUTE PC_ATRIBUIR_AVIAO_TRIPULACAO(1);
	-- Output:
	-- Verificar se aviões foram alocados
	SELECT *
	FROM VOO_REGULAR VR
	WHERE VR.PLANO_ID = 1;
	-- Verificar se os tripulantes cabine foram alocados
	SELECT VR.VOO_REGULAR_ID, TC.TRIPULANTE, TC.FUNCAO
    FROM TRIPULANTE_CABINE TC, VOO_REGULAR VR, VIAGEM_PLANEADA VP
    WHERE VR.PLANO_ID = 1
      AND VP.VIAGEM_PLANEADA_ID = TC.VIAGEM_PLANEADA
      AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
    -- Verificar se os tripulantes tecnicos foram alocados
    SELECT VR.VOO_REGULAR_ID, TT.TRIPULANTE, TT.FUNCAO
    FROM TRIPULANTE_TECNICO TT, VOO_REGULAR VR, VIAGEM_PLANEADA VP
    WHERE VR.PLANO_ID = 1
      AND VP.VIAGEM_PLANEADA_ID = TT.VIAGEM_PLANEADA
      AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID;
-- ### FIM TESTE PROCEDURE 8 ###


-- ### TESTAR PROCEDURE 9 ###
  SELECT * FROM VIAGEM_PLANEADA;
  
  DECLARE
    DATA_INICIO_PERIODO DATE;
    DATA_FINAL_PERIODO DATE;
  BEGIN
    DATA_INICIO_PERIODO := TO_DATE('2016/12/01', 'YYYY/MM/DD');
    DATA_FINAL_PERIODO := TO_DATE('2016/12/31', 'YYYY/MM/DD');
    
    PC_CRIAR_VIAGENS(DATA_INICIO_PERIODO, DATA_FINAL_PERIODO);
  END;
  /
  
  SELECT * FROM VIAGEM_PLANEADA;
-- ### FIM TESTE PROCEDURE 9 ###


-- ##################### TRIGGERS #####################

-- ### INICIO TESTE AO TRIGGER 10 ###
	INSERT INTO TRIPULANTE_TECNICO VALUES (1, 1, 'PILOTO'); -- INSERIR COMISSARIO (FALSE)
	INSERT INTO TRIPULANTE_TECNICO VALUES (1, 13, 'CO-PILOTO'); -- INSERIR CO-PILOTO (TRUE)
	INSERT INTO TRIPULANTE_TECNICO VALUES (1, 14, 'PILOTO'); -- INSERIR PILOTO S/ MIN HORAS (FALSE)
	INSERT INTO TRIPULANTE_TECNICO VALUES (1, 16, 'PILOTO'); -- INSERIR PILOTO C/ MIN HORAS (TRUE)

	-- SO APARECE O CO-PILOTO #13 E O PILOTO #16
	SELECT * FROM TRIPULANTE_TECNICO WHERE VIAGEM_PLANEADA = 1;
-- ### FIM DO TESTE AO TRIGGER 10 ###


-- ### TESTAR O TRIGGER 11 PARA TRIPULANTES TÉCNICOS ###
	INSERT INTO VOO VALUES (9, 1000, 120, 'VAR', 'LIS', 2); -- NEW
	INSERT INTO VOO_REGULAR VALUES (14, 1, 8, 'F04', 3, '20:00'); --NEW
	INSERT INTO VOO_REGULAR VALUES (15, 1, 9, 'F04', 3, '18:30'); --NEW
	INSERT INTO VIAGEM_PLANEADA VALUES (8, 14, TO_DATE('2016/12/13 20:00','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/13 21:00','YYYY/MM/DD HH24:MI')); -- NEW
	INSERT INTO VIAGEM_PLANEADA VALUES (9, 15, TO_DATE('2016/12/13 18:30','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/13 20:30','YYYY/MM/DD HH24:MI')); -- NEW

	SELECT *
	FROM VIAGEM_PLANEADA VP, TRIPULANTE_TECNICO TP, TRIPULANTE T, VOO_REGULAR VR, VOO V
	WHERE TP.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID AND TP.TRIPULANTE = T.TRIPULANTE_ID
	AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID AND VR.VOO_ID = V.VOO_ID
	AND T.TRIPULANTE_ID = 13 AND TRUNC(VP.DATA_PLANEADA_PARTIDA) = TO_DATE('2016/12/13', 'YYYY/MM/DD');

	INSERT INTO TRIPULANTE_TECNICO VALUES (8, 13, 'PILOTO');
	INSERT INTO TRIPULANTE_TECNICO VALUES (9, 13, 'PILOTO');

	DELETE FROM TRIPULANTE_TECNICO
	WHERE VIAGEM_PLANEADA BETWEEN 8 AND 9
	AND TRIPULANTE = 13;
-- ### FIM DO TESTE AO TRIGGER 11 ###


-- ##################### OPCIONAIS #####################

-- ### TESTAR FUNCTION 12 ###
  INSERT INTO RESERVA VALUES (99, 1, 1, NULL, NULL, NULL);
  SELECT * FROM RESERVA WHERE RESERVA_ID = 99;
  
  DECLARE
    LU LUGAR%ROWTYPE;
  BEGIN
    LU := FC_ALOCAR_LUGAR(99);
    DBMS_OUTPUT.PUT_LINE('NUM -> ' || LU.NUM_FILA || ' LETRA -> ' || LU.LETRA || ' CLASSE -> ' || LU.CLASSE);
  END;
  /
  
  SELECT * FROM RESERVA WHERE RESERVA_ID = 99;
  DELETE FROM RESERVA WHERE RESERVA_ID = 99;
-- ### FIM TESTE FUNCTION 12 ###


-- ### TESTAR FUNCTION 13 ###
	-- PARAM: AEROPORTO_ORIGEM_IATA & AEROPORTO_DESTINO_IATA
	SELECT FC_NUM_VOOS_MIN('OPO', 'MAD') FROM DUAL;
	-- Output (Verificar se é realmente o menor numero de viagens necessárias)
	SELECT V1.AEROPORTO_DESTINO
    FROM VOO_ROTA VR1, VOO V1
    WHERE VR1.ROTA_ID = ROTA_REC.ROTA_ID
    AND VR1.VOO_ID = V1.VOO_ID 
-- ### FIM TESTE FUNCTION 13 ###


-- ### TESTAR PROCEDURE 14 ###
	-- PARAM: AEROPORTO_ORIGEM_IATA & AEROPORTO_DESTINO_IATA
	EXECUTE FC_LISTAR_ROTA('OPO', 'MAD');
-- ### FIM TESTE PROCEDURE 14 ###


-- ### TESTAR PROCEDURE 15 ###
  DECLARE
    CIDADE_1 NUMBER;
    CIDADE_2 NUMBER;
  BEGIN
    SELECT CIDADE_ID INTO CIDADE_1
    FROM CIDADE WHERE NOME = 'PORTO';
    
    SELECT CIDADE_ID INTO CIDADE_2
    FROM CIDADE WHERE NOME = 'VARSOVIA';
    
    PC_OBTER_LIGACAO(CIDADE_1, CIDADE_2);
  END;
  /
-- ### FIM TESTE PROCEDURE 15 ###
