-- 10.
-- Trigger que impeça que um piloto possa ser alocado a um voo se não tiver as certificações 
-- e horas de voo requeridas no tipo de avião requerido para esse voo.
CREATE OR REPLACE TRIGGER TG_VERIFICAR_PILOTO_ALOCADO
BEFORE INSERT OR UPDATE ON TRIPULANTE_TECNICO
FOR EACH ROW
DECLARE
  CAT_INSERTED INTEGER;
  DIFF_HORAS_VOO INTEGER;
BEGIN
  -- Obter categoria de tripulante introduzida
  SELECT T.CATEGORIA
  INTO CAT_INSERTED
  FROM TRIPULANTE T
  WHERE T.TRIPULANTE_ID = :NEW.TRIPULANTE;
   
  IF (CAT_INSERTED <> 1)
  THEN
    RAISE_APPLICATION_ERROR( -20001, 'O tripulante inserido tem de ser da categoria piloto.');
  END IF;
  
  IF (:NEW.FUNCAO = 'PILOTO')
  THEN
    -- Obter diferença de horas de voo necessárias (horas de voo do piloto - horas de voo requeridas, se positivo tem)
    SELECT (HV.HORAS_VOO - TA.HORAS_VOO_MIN)
    INTO DIFF_HORAS_VOO
    FROM TIPO_AVIAO TA, HORAS_VOO HV
    WHERE TA.MARCA_MODELO = HV.MARCA_MODELO
      AND HV.PILOTO_ID = :NEW.TRIPULANTE
      AND HV.MARCA_MODELO IN (
                              SELECT A.MARCA_MODELO
                              FROM AVIAO A, VOO_REGULAR VR, VIAGEM_PLANEADA VP
                              WHERE A.NUM_SERIE = VR.AVIAO
                                AND VR.VOO_REGULAR_ID = VP.VOO_REGULAR
                                AND VP.VIAGEM_PLANEADA_ID = :NEW.VIAGEM_PLANEADA
                              );
    IF (DIFF_HORAS_VOO < 0)
    THEN
      RAISE_APPLICATION_ERROR( -20002, 'O tripulante inserido não tem as horas de voo necessárias para pilotar o tipo de avião da viagem inserida.');
    END IF;
  END IF;
END TG_VERIFICAR_PILOTO_ALOCADO;
/

-- 11.
-- Trigger que impeça que um tripulante possa ser alocado a um voo se o número
-- de voos com inicio no mesmo dia for superior a 2 ou, no caso da 2ª viagem do
-- dia, o aeroporto de partida for diferente do da chegada da 1ª viagem.

-- Trigger 11 para os tripulantes técnicos
CREATE OR REPLACE TRIGGER TG_ALOCACAO_TRIPULANTE_TECNICO
BEFORE INSERT OR UPDATE ON TRIPULANTE_TECNICO
FOR EACH ROW
DECLARE
  NUMERO_VIAGENS_ALOCADAS NUMBER;
  DATA_DA_ALOCACAO DATE;
  AERO_DEST_VIAGEM_1 VOO.AEROPORTO_DESTINO%TYPE;
  AERO_ORIGEM_VIAGEM_2  VOO.AEROPORTO_ORIGEM%TYPE;
BEGIN
  -- Obter a data para a qual o tripulante foi alocado
  SELECT DATA_PLANEADA_PARTIDA INTO DATA_DA_ALOCACAO
  FROM VIAGEM_PLANEADA
  WHERE VIAGEM_PLANEADA_ID = :NEW.VIAGEM_PLANEADA;

  -- ver em quantas viagens já foi alocado
  SELECT COUNT(*) INTO NUMERO_VIAGENS_ALOCADAS
  FROM VIAGEM_PLANEADA VP, TRIPULANTE_TECNICO TT
  WHERE TT.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID
  AND TT.TRIPULANTE = :NEW.TRIPULANTE
  AND TRUNC(VP.DATA_PLANEADA_PARTIDA) = TRUNC(DATA_DA_ALOCACAO);
  
  IF (NUMERO_VIAGENS_ALOCADAS = 1) THEN
    -- Obter aeroporto destino da primeira viagem
    SELECT V.AEROPORTO_DESTINO INTO AERO_DEST_VIAGEM_1
    FROM TRIPULANTE_TECNICO TT, VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
    WHERE TT.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID
    AND TT.TRIPULANTE = :NEW.TRIPULANTE
    AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
    AND VR.VOO_ID = V.VOO_ID
    AND TRUNC(VP.DATA_PLANEADA_PARTIDA) = TRUNC(DATA_DA_ALOCACAO);

    -- Obter aeroporto origem da segunda viagem
    SELECT AEROPORTO_ORIGEM INTO AERO_ORIGEM_VIAGEM_2
    FROM VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
    WHERE VP.VIAGEM_PLANEADA_ID = :NEW.VIAGEM_PLANEADA
    AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
    AND VR.VOO_ID = V.VOO_ID;

    IF (AERO_ORIGEM_VIAGEM_2 <> AERO_DEST_VIAGEM_1) THEN
      RAISE_APPLICATION_ERROR( -20001, 'O aeroporto origem da segunda viagem tem de ser o aeroporto destino da primeira viagem.');
    END IF;
    
  ELSIF (NUMERO_VIAGENS_ALOCADAS > 1) THEN
    RAISE_APPLICATION_ERROR( -20002, 'Não pode ser alocado a mais de 2 voos num único dia.');
  END IF;
  
END;
/

-- Trigger 11 para os tripulantes cabine
CREATE OR REPLACE TRIGGER TG_ALOCACAO_TRIPULANTE_CABINE
BEFORE INSERT OR UPDATE ON TRIPULANTE_CABINE
FOR EACH ROW
DECLARE
  NUMERO_VIAGENS_ALOCADAS NUMBER;
  DATA_DA_ALOCACAO DATE;
  AERO_DEST_VIAGEM_1 VOO.AEROPORTO_DESTINO%TYPE;
  AERO_ORIGEM_VIAGEM_2  VOO.AEROPORTO_ORIGEM%TYPE;
BEGIN
  -- Obter a data para a qual o tripulante foi alocado
  SELECT DATA_PLANEADA_PARTIDA INTO DATA_DA_ALOCACAO
  FROM VIAGEM_PLANEADA
  WHERE VIAGEM_PLANEADA_ID = :NEW.VIAGEM_PLANEADA;

  -- ver em quantas viagens já foi alocado
  SELECT COUNT(*) INTO NUMERO_VIAGENS_ALOCADAS
  FROM VIAGEM_PLANEADA VP, TRIPULANTE_CABINE TC
  WHERE TC.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID
  AND TC.TRIPULANTE = :NEW.TRIPULANTE
  AND TRUNC(VP.DATA_PLANEADA_PARTIDA) = TRUNC(DATA_DA_ALOCACAO);
  
  IF (NUMERO_VIAGENS_ALOCADAS = 1) THEN
    -- Obter aeroporto destino da primeira viagem
    SELECT V.AEROPORTO_DESTINO INTO AERO_DEST_VIAGEM_1
    FROM TRIPULANTE_CABINE TC, VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
    WHERE TC.VIAGEM_PLANEADA = VP.VIAGEM_PLANEADA_ID
    AND TC.TRIPULANTE = :NEW.TRIPULANTE
    AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
    AND VR.VOO_ID = V.VOO_ID
    AND TRUNC(VP.DATA_PLANEADA_PARTIDA) = TRUNC(DATA_DA_ALOCACAO);

    -- Obter aeroporto origem da segunda viagem
    SELECT AEROPORTO_ORIGEM INTO AERO_ORIGEM_VIAGEM_2
    FROM VIAGEM_PLANEADA VP, VOO_REGULAR VR, VOO V
    WHERE VP.VIAGEM_PLANEADA_ID = :NEW.VIAGEM_PLANEADA
    AND VP.VOO_REGULAR = VR.VOO_REGULAR_ID
    AND VR.VOO_ID = V.VOO_ID;

    IF (AERO_ORIGEM_VIAGEM_2 <> AERO_DEST_VIAGEM_1) THEN
      RAISE_APPLICATION_ERROR( -20001, 'O aeroporto origem da segunda viagem tem de ser o aeroporto destino da primeira viagem.');
    END IF;
    
  ELSIF (NUMERO_VIAGENS_ALOCADAS > 1) THEN
    RAISE_APPLICATION_ERROR( -20002, 'Não pode ser alocado a mais de 2 voos num único dia.');
  END IF;
  
END;
/