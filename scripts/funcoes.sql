-- Funções
-- 4. 
-- Função que para um voo de ligação entre dois aeroportos devolva 
-- o co�?digo do voo regular com o preço mais baixo dessa ligação para uma dada classe.



-- 5. 
-- Função que devolva o sala�?rio total de um piloto num dado mês.
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
BEGIN
  -- Obter o sal�rio base do piloto
  SELECT CT.SALARIO_MENSAL INTO SALARIO_TOTAL FROM CATEGORIA_TRIP CT WHERE CT.NOME = 'PILOTO';
  
  FOR VOO_POR_CAT IN VOOS_POR_CAT
  LOOP
    -- Obter o bonus para a categoria atual
    SELECT B.BONUS INTO BONUS_CAT FROM BONUS B
    WHERE B.CAT_VOO_ID = VOO_POR_CAT.CAT_VOO_ID
    AND CATEGORIA_TRIP_ID = (SELECT CT.CATEGORIA_TRIP_ID FROM CATEGORIA_TRIP CT WHERE CT.NOME = 'PILOTO');
    
    -- Somar as ocurr�ncias do bonus ao total
    SALARIO_TOTAL := SALARIO_TOTAL + BONUS_CAT * VOO_POR_CAT.VOOS_REALIZADOS_POR_CATEGORIA; 
  END LOOP;
  
  RETURN SALARIO_TOTAL;
END FC_SALARIO_TOTAL;
/

-- 6. 
-- Função que devolva o nu�?mero de um avião que pode ser alocado a um dado voo regular. 
-- Um avião so�? pode ser alocado a um voo se o aeroporto origem corresponde ao aeroporto 
-- destino da u�?ltima viagem que o avião faz (onde o avião se encontra) e a hora de partida e�? 
-- superior a 2 h em relação ao tempo de chegada desta u�?ltima viagem.