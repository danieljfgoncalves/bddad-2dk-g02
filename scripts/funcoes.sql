-- Funções
-- 4. 
-- Função que para um voo de ligação entre dois aeroportos devolva o código do voo regular 
-- com o preço mais baixo dessa ligação para uma dada classe. 
CREATE OR REPLACE FUNCTION FC_VOO_MAIS_BARATO 
  (VOO_PARAM IN INTEGER, CLASSE_PARAM IN INTEGER)
  RETURN INTEGER 
IS
  VR_MAIS_BARATO INTEGER;

BEGIN

  -- Obter o voo regular (correspondente ao voo de ligação e classe passados por parametro) com o preço mais
  -- baixo. (como existe a possibilidade de haver mais de um voo regular (do voo em questão) com o mesmo preco passamos apenas o primeiro registo) 
  SELECT VR1.VOO_REGULAR_ID
    INTO VR_MAIS_BARATO
    FROM PRECO P1, VOO_REGULAR VR1
    WHERE P1.VOO_REGULAR_ID = VR1.VOO_REGULAR_ID
      AND (VR1.VOO_ID, P1.CLASSE_ID, P1.PRECO) IN (
                                                    SELECT VR2.VOO_ID, P2.CLASSE_ID, MIN(P2.PRECO)
                                                    FROM VOO_REGULAR VR2, PRECO P2
                                                    WHERE VR2.VOO_ID = VOO_PARAM
                                                      AND P2.CLASSE_ID = CLASSE_PARAM
                                                      AND VR2.VOO_REGULAR_ID = P2.VOO_REGULAR_ID
                                                    GROUP BY VR2.VOO_ID, P2.CLASSE_ID
                                                  )
      AND ROWNUM = 1; -- Apenas o 1.º registo

RETURN VR_MAIS_BARATO;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Não existe preço para o voo e/ou classe em questão ainda '||SYSDATE);
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
    RETURN NULL;
END FC_VOO_MAIS_BARATO;
/


-- 5. 
-- Função que devolva o salário total de um piloto num dado mês.
CREATE OR REPLACE FUNCTION FC_SALARIO_TOTAL
  (PILOTO_ID IN NUMBER, MES IN NUMBER)
RETURN FLOAT IS
  SALARIO_TOTAL FLOAT;
  BONUS_CAT FLOAT;
  CURSOR VOOS_POR_CAT IS
    (
      -- Obter os voos realizador por cada categoria
      SELECT V.CAT_VOO_ID, COUNT(*) VOOS_REALIZADOS_POR_CATEGORIA
      FROM VIAGEM_REALIZADA VR, VOO V, VOO_REGULAR VoR
      WHERE VR.VIAGEM_REALIZADA_ID IN (SELECT VIAGEM_PLANEADA FROM TRIPULANTE_TECNICO WHERE TRIPULANTE = PILOTO_ID)
        AND TO_CHAR(VR.DATA_REALIZADA_PARTIDA, 'MM') = MES
        AND V.VOO_ID = VoR.VOO_ID
        AND VoR.VOO_REGULAR_ID = VR.VIAGEM_REALIZADA_ID
      GROUP BY V.CAT_VOO_ID
    );
  INVALID_MOUNTH EXCEPTION;
BEGIN
  IF MES NOT BETWEEN 1 AND 12 THEN
    RAISE INVALID_MOUNTH;
  END IF;

  -- Obter o salï¿½rio base do piloto
  SELECT CT.SALARIO_MENSAL INTO SALARIO_TOTAL FROM CATEGORIA_TRIP CT WHERE CT.NOME = 'PILOTO';
  
  FOR VOO_POR_CAT IN VOOS_POR_CAT
  LOOP
    -- Obter o bonus para a categoria atual
    SELECT B.BONUS INTO BONUS_CAT FROM BONUS B
    WHERE B.CAT_VOO_ID = VOO_POR_CAT.CAT_VOO_ID
    AND CATEGORIA_TRIP_ID = (SELECT CT.CATEGORIA_TRIP_ID FROM CATEGORIA_TRIP CT WHERE CT.NOME = 'PILOTO');
    
    -- Somar as ocurrï¿½ncias do bonus ao total
    SALARIO_TOTAL := SALARIO_TOTAL + BONUS_CAT * VOO_POR_CAT.VOOS_REALIZADOS_POR_CATEGORIA; 
  END LOOP;
  
  RETURN SALARIO_TOTAL;
EXCEPTION
  WHEN INVALID_MOUNTH THEN
    DBMS_OUTPUT.PUT_LINE('M�s inv�lido '||SYSDATE);
    RETURN -1;
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
    RETURN -1;
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
    RETURN -1;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
    RETURN -1;
END FC_SALARIO_TOTAL;
/


-- 6. 
-- Função que devolva o número de um avião que pode ser alocado a um dado voo regular. 
-- Um avião só pode ser alocado a um voo se o aeroporto origem corresponde ao aeroporto destino 
-- da última viagem que o avião faz (onde o avião se encontra) e a hora de partida é superior a 2 h 
-- em relação ao tempo de chegada desta última viagem. 
CREATE OR REPLACE FUNCTION FC_PODE_ALOCAR_AVIAO 
  (VR_PARAM IN INTEGER)
  RETURN VARCHAR 
IS
  VR_ORIGEM VOO.AEROPORTO_ORIGEM%TYPE;
  HORA_PARTIDA VOO_REGULAR.HORARIO_PARTIDA%TYPE;
  TMP_ULTIMO_DESTINO VOO.AEROPORTO_DESTINO%TYPE;
  TMP_DATA_CHEGADA VIAGEM_PLANEADA.DATA_PLANEADA_CHEGADA%TYPE;
  AVIAO_SEL VARCHAR(3);
  -- Exceções personalizadas
  NULL_RETURN EXCEPTION;

BEGIN

  -- Obter aeroporto de origem do voo regular do parametro
  SELECT V.AEROPORTO_ORIGEM, VR.HORARIO_PARTIDA
    INTO VR_ORIGEM, HORA_PARTIDA
    FROM VOO V, VOO_REGULAR VR
   WHERE VR.VOO_REGULAR_ID = VR_PARAM
     AND VR.VOO_ID = V.VOO_ID;

  -- Iterar cada avião existente
  FOR AVIAO_REC IN (
                    SELECT *
                    FROM AVIAO
                    )
  LOOP
    BEGIN
      -- Obter o ultimo destino do avião
      SELECT V.AEROPORTO_DESTINO, VP.DATA_PLANEADA_CHEGADA
        INTO TMP_ULTIMO_DESTINO, TMP_DATA_CHEGADA
        FROM VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
       WHERE VP.VOO_REGULAR = VR.VOO_REGULAR_ID
         AND VR.VOO_ID = V.VOO_ID
         AND VR.AVIAO = AVIAO_REC.NUM_SERIE
         AND VP.DATA_PLANEADA_CHEGADA IN (
                                          SELECT MAX(VP.DATA_PLANEADA_CHEGADA)
                                          FROM VIAGEM_PLANEADA VP, VOO_REGULAR VR
                                          WHERE VP.VOO_REGULAR = VR.VOO_REGULAR_ID
                                            AND VR.AVIAO = AVIAO_REC.NUM_SERIE
                                        );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN -- Quer dizer que este avião nunca foi utilizado
        RETURN AVIAO_REC.NUM_SERIE;
    END;
                                    
    IF (VR_ORIGEM = TMP_ULTIMO_DESTINO)
    THEN
      -- Comparar se a diferença da hora de partida com a hora de chegada da ultima viagem é > 2
      IF (((SUBSTR(HORA_PARTIDA, 1, 2) + (SUBSTR(HORA_PARTIDA, 4, 2) / 60)) 
           - (TO_CHAR(TMP_DATA_CHEGADA, 'HH24') + (TO_CHAR(TMP_DATA_CHEGADA, 'MI') / 60))) > 2)
      THEN
      
        AVIAO_SEL := AVIAO_REC.NUM_SERIE;
        EXIT;
      
      END IF;
    END IF;  
    
  END LOOP;

  IF (AVIAO_SEL IS NULL)
  THEN
    RAISE NULL_RETURN;
  END IF;

  RETURN AVIAO_SEL;
  
EXCEPTION
  WHEN NULL_RETURN THEN
    DBMS_OUTPUT.PUT_LINE('Nenhum avião disponivel '||SYSDATE);
    RETURN NULL;
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
    RETURN NULL;
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
    RETURN NULL;
END FC_PODE_ALOCAR_AVIAO;
/