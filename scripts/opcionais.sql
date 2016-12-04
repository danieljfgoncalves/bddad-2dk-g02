-- ##################### FUNÇÕES #####################

-- 12.
-- Função que para uma dada reserva de uma viagem já registada na BD devolva
-- o código de um lugar disponível e aloque esse lugar à reserva.
CREATE OR REPLACE FUNCTION FC_ALOCAR_LUGAR (CODIGO_RESERVA IN NUMBER)
RETURN LUGAR%ROWTYPE IS
  MARCA_MODELO_DA_RESERVA NUMBER;
  LUGAR_DISPONIVEL LUGAR%ROWTYPE;
BEGIN
  -- Obter marca modelo da reserva
  SELECT A.MARCA_MODELO INTO MARCA_MODELO_DA_RESERVA
  FROM RESERVA R, VIAGEM_PLANEADA VP, VOO_REGULAR VR, AVIAO A
  WHERE R.RESERVA_ID = CODIGO_RESERVA
  AND R.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID
  AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
  AND VR.AVIAO = A.NUM_SERIE;
  
  -- Obter lugares que ainda não foram reservados
  SELECT L1.* INTO LUGAR_DISPONIVEL FROM LUGAR L1
  WHERE L1.MARCA_MODELO = MARCA_MODELO_DA_RESERVA
  AND (L1.NUM_FILA, L1.LETRA, L1.CLASSE) NOT IN
      (
        SELECT R2.NUM_FILA_LUGAR, R2.LETRA_LUGAR, R2.CLASSE
        FROM RESERVA R2, VIAGEM_PLANEADA VP2, VOO_REGULAR VR2, AVIAO A2
        WHERE R2.VIAGEM_PLANEADA = VP2.VIAGEM_PLANEADA_ID
        AND VP2.VOO_REGULAR = VR2.VOO_REGULAR_ID
        AND VR2.AVIAO = A2.NUM_SERIE
        AND A2.MARCA_MODELO = MARCA_MODELO_DA_RESERVA
      )
  AND ROWNUM = 1;
  
  -- Alocar o lugar à reserva
  UPDATE RESERVA R
  SET R.NUM_FILA_LUGAR = LUGAR_DISPONIVEL.NUM_FILA,
      R.LETRA_LUGAR = LUGAR_DISPONIVEL.LETRA,
      R.CLASSE = LUGAR_DISPONIVEL.CLASSE
  WHERE RESERVA_ID = CODIGO_RESERVA;
  
  RETURN LUGAR_DISPONIVEL;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
    RETURN NULL;
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
    RETURN NULL;
END;
/


-- 13.
-- Função que dado um aeroporto origem e um aeroporto destino devolva o número mínimo de voos de ligação 
-- requeridos para ir de um aeroporto para o outro. No caso de haver ligação direta o valor é 1 
-- e no caso de não haver rota possível o valor é 0. 
CREATE OR REPLACE FUNCTION FC_NUM_VOOS_MIN 
  (A_ORIGEM_PARAM IN VARCHAR, A_DESTINO_PARAM IN VARCHAR)
  RETURN INTEGER 
IS
  NUM_VOOS_MIN INTEGER := NULL;
  -- Vars
  TMP_A_ORIGEM VARCHAR(3);
  TMP_A_DESTINO VARCHAR(3);
  TMP_NUM_VOOS INTEGER;
BEGIN
  -- Iterar as rotas
  FOR ROTA_REC IN (
                  SELECT ROTA_ID
                  FROM ROTA
                  )
  LOOP
    -- Obter aeroporto origem da rota em questao
    SELECT V.AEROPORTO_ORIGEM
    INTO TMP_A_ORIGEM
    FROM VOO_ROTA VR, VOO V
    WHERE VR.ROTA_ID = ROTA_REC.ROTA_ID
    AND VR.VOO_ID = V.VOO_ID
    AND V.AEROPORTO_ORIGEM NOT IN (
                                    SELECT V1.AEROPORTO_DESTINO
                                    FROM VOO_ROTA VR1, VOO V1
                                    WHERE VR1.ROTA_ID = ROTA_REC.ROTA_ID
                                    AND VR1.VOO_ID = V1.VOO_ID
                                    );
    -- Obter aeroporto destino da rota em questao                                
    SELECT V.AEROPORTO_DESTINO
    INTO TMP_A_DESTINO
    FROM VOO_ROTA VR, VOO V
    WHERE VR.ROTA_ID = ROTA_REC.ROTA_ID
    AND VR.VOO_ID = V.VOO_ID
    AND V.AEROPORTO_DESTINO NOT IN (
                                    SELECT V1.AEROPORTO_ORIGEM
                                    FROM VOO_ROTA VR1, VOO V1
                                    WHERE VR1.ROTA_ID = ROTA_REC.ROTA_ID
                                    AND VR1.VOO_ID = V1.VOO_ID
                                    );                                  
    -- Verificar se a rota tem a origem e destino pertendido
    IF ((A_ORIGEM_PARAM = TMP_A_ORIGEM) AND (A_DESTINO_PARAM = TMP_A_DESTINO))
    THEN
      -- Contar voos da rota
      SELECT COUNT(*)
      INTO TMP_NUM_VOOS
      FROM VOO_ROTA V_R
      WHERE ROTA_ID = ROTA_REC.ROTA_ID;

      -- Verificar se a rota tem menos voos do que anteriormente selecionada
      IF ((NUM_VOOS_MIN IS NULL) OR (NUM_VOOS_MIN > TMP_NUM_VOOS))
      THEN
        NUM_VOOS_MIN := TMP_NUM_VOOS;
      END IF;
    END IF;
  END LOOP;

  IF (NUM_VOOS_MIN IS NULL)
  THEN
    RETURN 0;
  END IF;

  RETURN NUM_VOOS_MIN;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Não existem rotas planeadas '||SYSDATE);
    RETURN NULL;
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Existe alguma rota malformada '||SYSDATE);
    RETURN NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
    RETURN NULL;
END FC_NUM_VOOS_MIN;
/

-- ##################### PROCEDIMENTOS #####################

-- 14.
-- Procedimento que permita listar as rotas de voos possíveis entre um dado aeroporto origem e um aeroporto destino, 
-- indicando para cada voo de ligação, a Ordem de sequência na viagem, os aeroportos envolvidos, 
-- o tipo de voo (Doméstico/Europa) e a distância . 
-- Rota |  ordem  |  NumVoo |  de |  para |  tipo(D/E) |    distância 
-- PARAMS: AEROPORTO_ORIGEM e AEROPORTO_DESTINO
CREATE OR REPLACE PROCEDURE FC_LISTAR_ROTA(A_ORIGEM_PARAM IN VARCHAR, A_DESTINO_PARAM IN VARCHAR)
IS
  -- VARS
  TMP_ROTA_ORIGEM VARCHAR(3);
  TMP_ROTA_DESTINO VARCHAR(3);
  TMP_ORDEM VARCHAR(100);
  TMP_VOO_ID INTEGER;
  TMP_DE VARCHAR(3);
  TMP_PARA VARCHAR(3);
  TMP_CAT VARCHAR(50);
  TMP_DISTANCIA INTEGER;
  AERO_INTERMEDIO VARCHAR(3);
  TMP_NUM_VOOS INTEGER;
BEGIN
  -- Imprimir cabecalho
  DBMS_OUTPUT.PUT_LINE('| Rota  | Ordem | NumVoo  | de  | para  |   tipo(D/E)    | distância |');
  
  -- Iterar as rotas
  FOR ROTA_REC IN (
                  SELECT ROTA_ID
                  FROM ROTA
                  )
  LOOP
    -- Obter aeroporto origem da rota em questao
    SELECT V.AEROPORTO_ORIGEM
    INTO TMP_ROTA_ORIGEM
    FROM VOO_ROTA VR, VOO V
    WHERE VR.ROTA_ID = ROTA_REC.ROTA_ID
    AND VR.VOO_ID = V.VOO_ID
    AND V.AEROPORTO_ORIGEM NOT IN (
                                    SELECT V1.AEROPORTO_DESTINO
                                    FROM VOO_ROTA VR1, VOO V1
                                    WHERE VR1.ROTA_ID = ROTA_REC.ROTA_ID
                                    AND VR1.VOO_ID = V1.VOO_ID
                                    );
    -- Obter aeroporto destino da rota em questao                                
    SELECT V.AEROPORTO_DESTINO
    INTO TMP_ROTA_DESTINO
    FROM VOO_ROTA VR, VOO V
    WHERE VR.ROTA_ID = ROTA_REC.ROTA_ID
    AND VR.VOO_ID = V.VOO_ID
    AND V.AEROPORTO_DESTINO NOT IN (
                                    SELECT V1.AEROPORTO_ORIGEM
                                    FROM VOO_ROTA VR1, VOO V1
                                    WHERE VR1.ROTA_ID = ROTA_REC.ROTA_ID
                                    AND VR1.VOO_ID = V1.VOO_ID
                                    );                                  
    -- Verificar se a rota tem a origem e destino pertendido
    IF ((A_ORIGEM_PARAM = TMP_ROTA_ORIGEM) AND (A_DESTINO_PARAM = TMP_ROTA_DESTINO))
    THEN
      -- Contar voos da rota
      SELECT COUNT(*)
      INTO TMP_NUM_VOOS
      FROM VOO_ROTA V_R
      WHERE ROTA_ID = ROTA_REC.ROTA_ID;
      -- Obter Sequencia de voos
      AERO_INTERMEDIO := TMP_ROTA_ORIGEM;
      FOR i IN 1..TMP_NUM_VOOS
      LOOP
        -- Iterar sequencia
        SELECT V.VOO_ID, V.AEROPORTO_ORIGEM, V.AEROPORTO_DESTINO, C.NOME, V.DISTANCIA
        INTO TMP_VOO_ID, TMP_DE, TMP_PARA, TMP_CAT, TMP_DISTANCIA
        FROM VOO_ROTA VR, VOO V, CATEGORIA_VOO C
        WHERE VR.VOO_ID = V.VOO_ID
          AND V.AEROPORTO_ORIGEM = AERO_INTERMEDIO
          AND VR.ROTA_ID = ROTA_REC.ROTA_ID
          AND V.CAT_VOO_ID = C.CAT_VOO_ID;
        -- Alterar aeroporto intermedio para o destino do vou anterior
        AERO_INTERMEDIO := TMP_PARA;
        -- Imprimir linha
        DBMS_OUTPUT.PUT_LINE('| ' || ROTA_REC.ROTA_ID || '     |   ' || i || 'º  | ' ||
          TMP_VOO_ID || '       | ' || TMP_DE || ' | ' || TMP_PARA || '   |   ' || TMP_CAT || '     | ' || TMP_DISTANCIA || '    |');
      
      END LOOP;
    END IF;
  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Não existem rotas planeadas '||SYSDATE);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Existe alguma rota malformada '||SYSDATE);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
END FC_LISTAR_ROTA;
/


-- 15.
-- Procedimento que permita obter todos os voos regulares entre duas cidades
-- em que há voo de regresso no mesmo dia, com uma hora de ida inferior às 10
-- da manhã e com uma diferença entre a hora de partida do voo de regresso e a
-- hora de chegada do voo de ida superior a 8 horas.
CREATE OR REPLACE PROCEDURE PC_OBTER_LIGACAO (CIDADE_ID_1 NUMBER, CIDADE_ID_2 NUMBER)
IS
  CURSOR VOOS_REGULARES_IDA IS
      SELECT DISTINCT VR.*, TO_CHAR(TO_DATE(VR.HORARIO_PARTIDA, 'HH24:MI') + V.DURACAO_MINUTOS / (24 * 60), 'HH24:MI') HORARIO_CHEGADA
      FROM VOO_REGULAR VR, VOO V, AEROPORTO AO, AEROPORTO AD, CIDADE C
      WHERE VR.VOO_ID = V.VOO_ID
      AND V.AEROPORTO_ORIGEM = AO.IATA_ID
      AND V.AEROPORTO_DESTINO = AD.IATA_ID
      AND AO.CIDADE_ID = CIDADE_ID_1
      AND AD.CIDADE_ID = CIDADE_ID_2
      AND SUBSTR(VR.HORARIO_PARTIDA, 1, 2) < 10;
BEGIN
  DBMS_OUTPUT.PUT_LINE('| VOO_REGULAR_ID_IDA | AVIAO_IDA | HORARIO_PARTIDA_IDA | HORARIO_CHEGADA_IDA | '
                    || 'VOO_REGULAR_ID_VOLTA | AVIAO_VOLTA | HORARIO_PARTIDA_VOLTA | HORARIO_CHEGADA_VOLTA |');

  FOR IDA IN VOOS_REGULARES_IDA
  LOOP
    FOR VOLTA IN
    (
        SELECT DISTINCT VR.*, TO_CHAR(TO_DATE(VR.HORARIO_PARTIDA, 'HH24:MI') + V.DURACAO_MINUTOS / (24 * 60), 'HH24:MI') HORARIO_CHEGADA
        FROM VOO_REGULAR VR, VOO V, AEROPORTO AO, AEROPORTO AD, CIDADE C
        WHERE VR.VOO_ID = V.VOO_ID
        AND V.AEROPORTO_ORIGEM = AO.IATA_ID
        AND V.AEROPORTO_DESTINO = AD.IATA_ID
        AND AO.CIDADE_ID = CIDADE_ID_2
        AND AD.CIDADE_ID = CIDADE_ID_1
        AND DIA_DA_SEMANA = IDA.DIA_DA_SEMANA
        AND (SUBSTR(VR.HORARIO_PARTIDA, 1, 2) * 60 + SUBSTR(VR.HORARIO_PARTIDA, 4, 5))
          - (SUBSTR(IDA.HORARIO_CHEGADA, 1, 2) * 60 + SUBSTR(IDA.HORARIO_CHEGADA, 4, 5))
          > (8 * 60)
    )
    LOOP
      DBMS_OUTPUT.PUT_LINE('| ' || IDA.VOO_REGULAR_ID || ' | '
                          || IDA.AVIAO || ' | '
                          || IDA.HORARIO_PARTIDA || ' | '
                          || IDA.HORARIO_CHEGADA || ' | '
                          || VOLTA.VOO_REGULAR_ID || ' | '
                          || VOLTA.AVIAO || ' | '
                          || VOLTA.HORARIO_PARTIDA || ' | '
                          || VOLTA.HORARIO_CHEGADA || ' |');
    END LOOP;
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
END;
/