-- 7.
-- Procedimento que permita obter as viagens que ainda não foram realizadas e
-- que ainda têm lugares por reservar, indicando o código do voo, a data, a hora, o
-- aeroporto origem, o aeroporto destino e o número de lugares disponíveis na
-- classe económica e na executiva.
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
  dbms_output.put_line('| CODIGO_VOO | DATA_HORA_PARTIDA | AEROPORTO_ORIGEM | AEROPORTO_DESTINO | LUGARES_ECONOMICOS_DISPONIVEIS | LUGARES_EXECUTIVOS_DISPONIVEIS |');

  FOR VNR IN VIAGENS_NAO_REALIZADAS
  LOOP
    -- Obter o voo da viagem_planeada em questão
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
    AND CLASSE = (SELECT C.CLASSE_ID FROM CLASSE C WHERE C.NOME = 'ECONOMICA')
    AND (NUM_FILA, LETRA, MARCA_MODELO, CLASSE) NOT IN
    (
      -- Obter lugares executivos RESERVADOS
      SELECT L2.*
      FROM LUGAR L2, RESERVA R2
      WHERE L2.NUM_FILA = R2.NUM_FILA_LUGAR AND L2.LETRA = R2.LETRA_LUGAR AND L2.CLASSE = R2.CLASSE
      AND L2.MARCA_MODELO = L_MARCA_MODELO
      AND R2.CLASSE = (SELECT C2.CLASSE_ID FROM CLASSE C2 WHERE C2.NOME = 'ECONOMICA')
    );
  
    -- Obter numero de lugares disponiveis na classe executiva
    SELECT COUNT(*) INTO L_LUGARES_EXECUTIVOS FROM LUGAR
    WHERE MARCA_MODELO = L_MARCA_MODELO
    AND CLASSE = (SELECT C.CLASSE_ID FROM CLASSE C WHERE C.NOME = 'EXECUTIVA')
    AND (NUM_FILA, LETRA, MARCA_MODELO, CLASSE) NOT IN
    (
      -- Obter lugares executivos RESERVADOS
      SELECT L2.*
      FROM LUGAR L2, RESERVA R2
      WHERE L2.NUM_FILA = R2.NUM_FILA_LUGAR AND L2.LETRA = R2.LETRA_LUGAR AND L2.CLASSE = R2.CLASSE
      AND L2.MARCA_MODELO = L_MARCA_MODELO
      AND R2.CLASSE = (SELECT C2.CLASSE_ID FROM CLASSE C2 WHERE C2.NOME = 'EXECUTIVA')
    );
    
    -- imprimir a data
    dbms_output.put_line('| ' || L_VOO.VOO_ID || ' | '
    || TO_CHAR(VNR.DATA_PLANEADA_PARTIDA, 'YYYY/MM/DD HH:MI') || ' | '
    || L_VOO.AEROPORTO_ORIGEM || ' | '
    || L_VOO.AEROPORTO_DESTINO || ' | '
    || L_LUGARES_ECONOMICOS || ' | '
    || L_LUGARES_EXECUTIVOS || ' | ');
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


-- Procedures
-- 8. 
-- Procedimento que atribua um avião e a tripulação a cada voo regular definido para um período. 
-- Considere que a tripulação e o avião são sempre os mesmos para todas as viagens que se realizam 
-- nesse período correspondentes ao mesmo voo_regular.
-- PARAMS: PLANO_ID
CREATE OR REPLACE PROCEDURE FC_ATRIBUIR_AVIAO_TRIPULACAO(PLANO_PARAM IN INTEGER)
IS
  --EXCEPCOES PERSONALIZADAS
  TRIPULANTES_INSUF EXCEPTION;
  -- VARS
  NUM_T_CAB INTEGER; -- Numero de tripulantes cabine registados
  NUM_T_TEC INTEGER; -- Numero de tripulantes tecnicos registados
  TMP_NUM_COMISSARIOS INTEGER;-- numero de comissarios necessarios para cada voo (var tmp)
  V_VR_AVIAO VARCHAR(3); -- numero de serie de aviao (var tmp)
  TMP_TRIP_TEC_ID INTEGER;
  CURSOR C_VR IS 
              SELECT VOO_REGULAR_ID 
              FROM VOO_REGULAR
              WHERE PLANO_ID = PLANO_PARAM
              FOR UPDATE;
  -- Função local para ver se existe algum tripulante disponivel para alocar
  FUNCTION FC_PODE_ALOCAR_TRIP 
    (VP_PARAM IN INTEGER, CAT_PARAM IN INTEGER)
    RETURN INTEGER 
  IS
    TRIP_ID INTEGER;
    TRIP_JA_ALOCADO INTEGER;
  BEGIN
    FOR TRIP_REC IN (SELECT TRIPULANTE.TRIPULANTE_ID 
                    FROM TRIPULANTE
                    WHERE CATEGORIA = CAT_PARAM
                    ORDER BY dbms_random.value)
    LOOP
      SELECT COUNT(*)
      INTO TRIP_JA_ALOCADO
      FROM (SELECT TC.TRIPULANTE
            FROM TRIPULANTE_CABINE TC
            WHERE TC.VIAGEM_PLANEADA = VP_PARAM
            UNION ALL
            SELECT TT.TRIPULANTE
            FROM TRIPULANTE_TECNICO TT
            WHERE TT.VIAGEM_PLANEADA = VP_PARAM)SUBQ
      WHERE TRIPULANTE = TRIP_REC.TRIPULANTE_ID;
      IF (TRIP_JA_ALOCADO = 0)
      THEN
        RETURN TRIP_REC.TRIPULANTE_ID;
      END IF;
    END LOOP;
    RETURN NULL; -- Nao existe nenhum tripulante disponivel 
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Não existem tripulantes com categoria #'|| CAT_PARAM || ' registados '||SYSDATE);
      RETURN NULL;
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
      RETURN NULL;
  END;
BEGIN
  -- Verificar quantos tripulante de cabine estao registados na BD
  SELECT COUNT(*)
  INTO NUM_T_CAB
  FROM TRIPULANTE
  WHERE CATEGORIA = 2;
  -- Verificar quantos tripulante de tecnicos estao registados na BD
  SELECT COUNT(*)
  INTO NUM_T_TEC
  FROM TRIPULANTE
  WHERE CATEGORIA = 1;

  FOR VR_REC IN C_VR -- Iterar pelos voo regulares com o mesmo plano 
  LOOP
    -- ATRIBUIR UM AVIAO A CADA VOO_REGULAR
    V_VR_AVIAO := FC_PODE_ALOCAR_AVIAO(VR_REC.VOO_REGULAR_ID);
    -- Atualizar o aviao no voo regular em questao
    UPDATE VOO_REGULAR -- Atualizar coluna aviao
    SET    AVIAO = V_VR_AVIAO
    WHERE  CURRENT OF C_VR;
    
    -- Obter numero de comissarios necessarios para este voo regular
    SELECT CAT.NUM_TRIP_CABINE 
    INTO TMP_NUM_COMISSARIOS
    FROM VOO_REGULAR VR, VOO, CATEGORIA_VOO CAT
    WHERE VR.VOO_ID = VOO.VOO_ID 
    AND VOO.CAT_VOO_ID = CAT.CAT_VOO_ID
    AND VR.VOO_REGULAR_ID = VR_REC.VOO_REGULAR_ID;
    
    -- Iterar por viagens planeadas do voo regular em questão
    FOR VP_REC IN ( SELECT VP.VIAGEM_PLANEADA_ID
                    FROM VIAGEM_PLANEADA VP
                    WHERE VP.VOO_REGULAR = VR_REC.VOO_REGULAR_ID)
    LOOP
    -- ATRIBUIR PILOTO E CO-PILOTO
      IF (NUM_T_TEC < 2)
      THEN
        RAISE TRIPULANTES_INSUF;
      END IF;
      --ATRIBUIR PILOTO
      TMP_TRIP_TEC_ID := FC_PODE_ALOCAR_TRIP(VP_REC.VIAGEM_PLANEADA_ID, 1);
      INSERT INTO TRIPULANTE_TECNICO VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_TRIP_TEC_ID, 'PILOTO');
      --ATRIBUIR CO-PILOTO
      TMP_TRIP_TEC_ID := FC_PODE_ALOCAR_TRIP(VP_REC.VIAGEM_PLANEADA_ID, 1);
      INSERT INTO TRIPULANTE_TECNICO VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_TRIP_TEC_ID, 'CO-PILOTO');
      
    -- ATRIBUIR COMISSARIOS
      IF (NUM_T_CAB < TMP_NUM_COMISSARIOS)
      THEN
        RAISE TRIPULANTES_INSUF;
      END IF;
      --ATRIBUIR COMISSARIO CHEFE
      TMP_TRIP_TEC_ID := FC_PODE_ALOCAR_TRIP(VP_REC.VIAGEM_PLANEADA_ID, 2);
      INSERT INTO TRIPULANTE_CABINE VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_TRIP_TEC_ID, 'COMISSARIO CHEFE');
      -- ATRIBUIR RESTANTES COMISSÃ?RIOS
      FOR i IN 1..(TMP_NUM_COMISSARIOS - 1)
      LOOP
        TMP_TRIP_TEC_ID := FC_PODE_ALOCAR_TRIP(VP_REC.VIAGEM_PLANEADA_ID, 2);
        INSERT INTO TRIPULANTE_CABINE VALUES (VP_REC.VIAGEM_PLANEADA_ID, TMP_TRIP_TEC_ID, 'COMISSARIO');
      END LOOP;
    END LOOP;
  END LOOP;
EXCEPTION
  WHEN TRIPULANTES_INSUF THEN
    DBMS_OUTPUT.PUT_LINE('Não existem tripulantes suficientes para alocar '||SYSDATE);
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
END FC_ATRIBUIR_AVIAO_TRIPULACAO;
/


-- 9. 
-- Procedimento que para um determinado período (datainicio/data fim), crie as
-- viagens dos voos que se devem realizar durante esse período. Considera-se que
-- já foram criados os voos regulares a efetuar nesse período.
CREATE OR REPLACE PROCEDURE PC_CRIAR_VIAGENS
  (DATA_INICIO_PERIODO IN DATE, DATA_FIM_PERIODO IN DATE)
IS
  PLANO_EM_QUESTAO PLANO%ROWTYPE;
  DATA_CONTADOR DATE;
  DATA_PARTIDA_PARA_INSERIR DATE;
  DATA_CHEGADA_PARA_INSERIR DATE;
  MINUTOS_DO_VOO NUMBER;
  ID_PARA_INSERIR NUMBER;
  PERIODO_INVALIDO EXCEPTION;
BEGIN

  -- Obter o ID máximo da tabela viagem planeada
  SELECT MAX(VIAGEM_PLANEADA_ID) INTO ID_PARA_INSERIR FROM VIAGEM_PLANEADA;

  -- Verificar se plano é válido (caso não seja lança a exceção)
  IF DATA_INICIO_PERIODO >= DATA_FIM_PERIODO THEN
    RAISE PERIODO_INVALIDO;
  END IF;

  -- Obter plano em questão
  SELECT * INTO PLANO_EM_QUESTAO FROM PLANO P
  WHERE TRUNC(P.DATA_INICIO) = TRUNC(DATA_INICIO_PERIODO)
  AND TRUNC(P.DATA_FIM) = TRUNC(DATA_FIM_PERIODO);
  
  -- Percorrer todos os voos regulares do plano em questao
  FOR VOO_REGULAR_RECORD IN
  (SELECT * FROM VOO_REGULAR VR WHERE VR.PLANO_ID = PLANO_EM_QUESTAO.PLANO_ID )
  LOOP
  
    -- Para cada voo regular percorrer as datas todas do plano para criar os voos necessários
    DATA_CONTADOR := DATA_INICIO_PERIODO;
    WHILE DATA_CONTADOR < DATA_FIM_PERIODO LOOP
      
      -- Verificar se a data do contador corresponde ao dia da semana do voo regular em questão
      IF TO_CHAR(DATA_CONTADOR, 'D') = TO_CHAR(VOO_REGULAR_RECORD.DIA_DA_SEMANA) THEN
        
        -- Incrementar id a inserir
        ID_PARA_INSERIR := ID_PARA_INSERIR + 1;
        
        -- Definir data planeada partida
        DATA_PARTIDA_PARA_INSERIR := TRUNC(DATA_CONTADOR) 
        + SUBSTR(VOO_REGULAR_RECORD.HORARIO_PARTIDA, 1, 2) / 24 
        + SUBSTR(VOO_REGULAR_RECORD.HORARIO_PARTIDA, 4, 5) / (24 * 60);
        
        -- Obter duracao do voo em minutos
        SELECT DURACAO_MINUTOS INTO MINUTOS_DO_VOO FROM VOO V
        WHERE V.VOO_ID = VOO_REGULAR_RECORD.VOO_ID;
        
        -- Definir data planeada de chegada
        DATA_CHEGADA_PARA_INSERIR := DATA_PARTIDA_PARA_INSERIR + MINUTOS_DO_VOO / (24 * 60);
        
        -- Inseir o registo
        INSERT INTO VIAGEM_PLANEADA
        (VIAGEM_PLANEADA_ID, VOO_REGULAR,
        DATA_PLANEADA_PARTIDA, DATA_PLANEADA_CHEGADA)
        VALUES
        (ID_PARA_INSERIR, VOO_REGULAR_RECORD.VOO_REGULAR_ID,
        DATA_PARTIDA_PARA_INSERIR, DATA_CHEGADA_PARA_INSERIR);
      END IF;
      
      -- incrementar o contador da data a 1 dia
      DATA_CONTADOR := DATA_CONTADOR + 1;
    END LOOP;
  END LOOP;
  
EXCEPTION
  WHEN PERIODO_INVALIDO THEN
    DBMS_OUTPUT.PUT_LINE('Periodo invalido. A data inicio tem de ser menor que a data final. '||SYSDATE);
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Registo inexistente '||SYSDATE);
  WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('Muitos registos '||SYSDATE);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocorreu um erro '||SYSDATE);
END;
/