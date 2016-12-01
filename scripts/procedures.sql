-- Procedures
-- 8. 
-- Procedimento que atribua um avião e a tripulação a cada voo regular para um período. 
-- Considere que a tripulação e o avião são sempre os mesmos para todas as viagens que 
-- se realizam nesse período correspondentes ao mesmo voo_regular.

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
      -- ATRIBUIR RESTANTES COMISSÁRIOS
      FOR i IN 1..(TMP_NUM_COMISSARIOS - 1)
      LOOP
        FETCH C_TRIP_CAB INTO TMP_COMISSARIO_ID;
        IF (C_TRIP_CAB%NOTFOUND)
        THEN -- Reset ao C_TRIP_CAB
          CLOSE C_TRIP_CAB;
          OPEN C_TRIP_CAB;
        END IF;
        LOOP -- SE O COMISSARIO JÁ FIZER PARTE DESTE VOO, TENTAR O SEGUINTE
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
