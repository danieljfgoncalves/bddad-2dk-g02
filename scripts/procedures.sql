-- 7.
-- Procedimento que permita obter as viagens que ainda n�o foram realizadas e
-- que ainda t�m lugares por reservar, indicando o c�digo do voo, a data, a hora, o
-- aeroporto origem, o aeroporto destino e o n�mero de lugares dispon�veis na
-- classe econ�mica e na executiva.
CREATE OR REPLACE PROCEDURE PC_VIAGENS_DISPONIVEIS IS
  L_VOO VOO%ROWTYPE;
  L_MARCA_MODELO NUMBER;
  L_LUGARES_ECONOMICOS NUMBER;
  L_LUGARES_EXECUTIVOS NUMBER;
  CURSOR VIAGENS_NAO_REALIZADAS
      IS (SELECT VP.* FROM VIAGEM_PLANEADA VP
          WHERE VP.VIAGEM_PLANEADA_ID NOT IN (SELECT VIAGEM_REALIZADA_ID FROM VIAGEM_REALIZADA)
          AND VP.DATA_PLANEADA_PARTIDA - SYSDATE > 0);
BEGIN
  -- Cabecalho da tabela
  dbms_output.put_line('CODIGO_VOO | DATA_HORA_PARTIDA | AEROPORTO_ORIGEM | AEROPORTO_DESTINO | LUGARES_ECONOMICOS_DISPONIVEIS | LUGARES_EXECUTIVOS_DISPONIVEIS');

  FOR VNR IN VIAGENS_NAO_REALIZADAS
  LOOP
    -- Obter o voo da viagem_planeada em quest�o
    SELECT V.* INTO L_VOO FROM VOO V, VOO_REGULAR VR
    WHERE V.VOO_ID = VR.VOO_ID AND VR.VOO_REGULAR_ID = VNR.VOO_REGULAR;
    
    -- Obter marca modelo
    SELECT A.MARCA_MODELO INTO L_MARCA_MODELO
    FROM AVIAO A, VOO_REGULAR VR, VIAGEM_PLANEADA VP
    WHERE VP.VOO_REGULAR = VR.VOO_REGULAR_ID AND VR.AVIAO = A.NUM_SERIE
    AND VP.VIAGEM_PLANEADA_ID = VNR.VIAGEM_PLANEADA_ID;
    
    -- Obter numero de lugares disponiveis na classe economica
    SELECT COUNT(*) INTO L_LUGARES_ECONOMICOS FROM LUGAR
    WHERE MARCA_MODELO = L_MARCA_MODELO
    AND CLASSE = (SELECT C.CLASSE_ID FROM CLASSE C WHERE C.NOME = 'ECONOMICA');
    
    -- Obter numero de lugares disponiveis na classe executiva
    SELECT COUNT(*) INTO L_LUGARES_EXECUTIVOS FROM LUGAR
    WHERE MARCA_MODELO = L_MARCA_MODELO
    AND CLASSE = (SELECT C.CLASSE_ID FROM CLASSE C WHERE C.NOME = 'EXECUTIVA');
    
    -- imprimir a data
    dbms_output.put_line(L_VOO.VOO_ID || ' | '
    || TO_CHAR(VNR.DATA_PLANEADA_PARTIDA, 'YYYY/MM/DD HH:MI') || ' | '
    || L_VOO.AEROPORTO_ORIGEM || ' | '
    || L_VOO.AEROPORTO_DESTINO || ' | '
    || L_LUGARES_ECONOMICOS || ' | '
    || L_LUGARES_EXECUTIVOS || ' | ');
  END LOOP;
END;
/


-- Procedures
-- 8. 
-- Procedimento que atribua um avião e a tripulação a cada voo regular para um peri�?odo. 
-- Considere que a tripulação e o avião são sempre os mesmos para todas as viagens que 
-- se realizam nesse peri�?odo correspondentes ao mesmo voo_regular.

-- PARAMS: PLANO
CREATE OR REPLACE PROCEDURE ATRIBUIR_AVIAO_TRIPULACAO(PLANO_PARAM IN INTEGER)
IS

CAB_ROWS INTEGER; -- Número de comissários registados
CAB_EXISTENTE INTEGER; -- boolean se o comissário já foi atribuido ao voo em questão
TMP_NUM_COMISSARIOS INTEGER;-- número de comissários necessários para cada voo (var tmp)
TMP_PILOTO_ID INTEGER; -- id de piloto (var tmp)
TMP_CO_PILOTO_ID INTEGER; -- id de co-piloto (var tmp)
TMP_COMISSARIO_ID INTEGER; -- id de comissário (var tmp)
V_VR_AVIAO VARCHAR(3); -- número de serie de avião (var tmp)
CURSOR C_VR IS 
            SELECT * 
            FROM VOO_REGULAR
            WHERE PLANO_ID = PLANO_PARAM
            FOR UPDATE;
CURSOR C_AVIAO IS
               SELECT NUM_SERIE
               FROM AVIAO
               ORDER BY dbms_random.value;
CURSOR C_TRIP_TEC IS
                  SELECT TRIPULANTE_ID
                  FROM TRIPULANTE
                  WHERE CATEGORIA = 1
                  ORDER BY dbms_random.value;
CURSOR C_TRIP_CAB IS
                  SELECT TRIPULANTE_ID
                  FROM TRIPULANTE
                  WHERE CATEGORIA = 2
                  ORDER BY dbms_random.value; 
BEGIN

  -- Verificar quantos commisários estão registados na BD
  SELECT COUNT(*)
  INTO CAB_ROWS
  FROM TRIPULANTE
  WHERE CATEGORIA = 2;

  OPEN C_AVIAO;
  OPEN C_TRIP_TEC;
  OPEN C_TRIP_CAB;
  FOR VR_REC IN C_VR -- Iterar pelos voo regulares com o mesmo plano 
  LOOP
    -- ATRIBUIR UM AVIAO A CADA VOO_REGULAR
    FETCH C_AVIAO INTO V_VR_AVIAO; 
    IF (C_AVIAO%NOTFOUND)
    THEN -- Reset ao C_AVIAO
      CLOSE C_AVIAO;
      OPEN C_AVIAO;
    END IF;
    UPDATE VOO_REGULAR -- Atualizar coluna aviao
    SET    AVIAO = V_VR_AVIAO
    WHERE  CURRENT OF C_VR;
    
    
-- *** TODO: Adaptar Função 3 a atribuição de um avião ***


    -- Obter número de comissários necessários
    SELECT CAT.NUM_TRIP_CABINE INTO TMP_NUM_COMISSARIOS
      FROM VOO_REGULAR VR, VOO, CATEGORIA_VOO CAT
      WHERE VR.VOO_ID = VOO.VOO_ID AND VOO.CAT_VOO_ID = CAT.CAT_VOO_ID
      AND VR.VOO_REGULAR_ID = VR_REC.VOO_REGULAR_ID;
  
    -- LOOP VIAGENS PLANEADAS
    FOR VP_REC IN (SELECT *
                    FROM VIAGEM_PLANEADA VP
                    WHERE VP.VOO_REGULAR = VR_REC.VOO_REGULAR_ID)
    LOOP
      -- ATRIBUIR PILOTO
      FETCH C_TRIP_TEC INTO TMP_PILOTO_ID;
      IF (C_TRIP_TEC%NOTFOUND)
      THEN -- Reset ao C_TRIP_TEC
        CLOSE C_TRIP_TEC;
        OPEN C_TRIP_TEC;
      END IF;
      FETCH C_TRIP_TEC INTO TMP_CO_PILOTO_ID;
      IF (C_TRIP_TEC%NOTFOUND)
      THEN -- Reset ao C_TRIP_TEC
        CLOSE C_TRIP_TEC;
        OPEN C_TRIP_TEC;
      END IF;
      INSERT INTO TRIPULANTE_TECNICO VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_PILOTO_ID, 'PILOTO');
      INSERT INTO TRIPULANTE_TECNICO VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_CO_PILOTO_ID, 'CO-PILOTO');
      
      -- ATRIBUIR COMISSARIO CHEFE
      FETCH C_TRIP_CAB INTO TMP_COMISSARIO_ID;
      IF (C_TRIP_CAB%NOTFOUND)
      THEN -- Reset ao C_TRIP_CAB
        CLOSE C_TRIP_CAB;
        OPEN C_TRIP_CAB;
      END IF;
      INSERT INTO TRIPULANTE_CABINE VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_COMISSARIO_ID, 'COMISSARIO_CHEFE');
      
      -- Sai do loop caso não haja commissarios suficientes
      IF (CAB_ROWS < TMP_NUM_COMISSARIOS)
      THEN
        EXIT;
      END IF;
      -- ATRIBUIR RESTANTES COMISS�?RIOS
      FOR i IN 1..(TMP_NUM_COMISSARIOS - 1)
      LOOP
        FETCH C_TRIP_CAB INTO TMP_COMISSARIO_ID;
        IF (C_TRIP_CAB%NOTFOUND)
        THEN -- Reset ao C_TRIP_CAB
          CLOSE C_TRIP_CAB;
          OPEN C_TRIP_CAB;
        END IF;
        LOOP -- SE O COMISSARIO J�? FIZER PARTE DESTE VOO, TENTAR O SEGUINTE
          SELECT COUNT(*)
          INTO CAB_EXISTENTE
          FROM TRIPULANTE_CABINE TC
          WHERE TC.VIAGEM_REALIZADA = VP_REC.VIAGEM_PLANEADA_ID
          AND TC.TRIPULANTE = TMP_COMISSARIO_ID;
        EXIT WHEN  CAB_EXISTENTE < 1; 
          FETCH C_TRIP_CAB INTO TMP_COMISSARIO_ID;
          IF (C_TRIP_CAB%NOTFOUND)
          THEN -- Reset ao C_TRIP_CAB
            CLOSE C_TRIP_CAB;
            OPEN C_TRIP_CAB;
          END IF;
        END LOOP;
        INSERT INTO TRIPULANTE_CABINE VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_COMISSARIO_ID, 'COMISSARIO');
      END LOOP;
    END LOOP;
  
  END LOOP;
  CLOSE C_AVIAO;
  CLOSE C_TRIP_TEC;
  CLOSE C_TRIP_CAB;
END;
/
