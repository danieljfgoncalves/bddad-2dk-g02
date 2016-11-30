-- Funções
-- 4. 
-- Função que para um voo de ligação entre dois aeroportos devolva 
-- o código do voo regular com o preço mais baixo dessa ligação para uma dada classe.

CREATE OR REPLACE FUNCTION VOO_MAIS_BARATO 
  (VOO_PARAM IN INTEGER, CLASSE_PARAM IN INTEGER)
  RETURN INTEGER 
IS
  VR_MAIS_BARATO INTEGER;
  
  CURSOR VRS_MIN
  IS
    SELECT VR1.VOO_REGULAR_ID
    FROM PRECO P, VOO_REGULAR VR1
    WHERE P.VOO_REGULAR_ID = VR1.VOO_REGULAR_ID
      AND (VR1.VOO_ID, P.CLASSE_ID, P.PRECO) IN (
                                      SELECT VR2.VOO_ID, P.CLASSE_ID, MIN(P.PRECO)
                                      FROM VOO_REGULAR VR2, PRECO P
                                      WHERE VR2.VOO_ID = VOO_PARAM
                                        AND P.CLASSE_ID = CLASSE_PARAM
                                        AND VR2.VOO_REGULAR_ID = P.VOO_REGULAR_ID
                                      GROUP BY VR2.VOO_ID, P.CLASSE_ID
                                    );
BEGIN

  OPEN VRS_MIN;
    FETCH VRS_MIN INTO VR_MAIS_BARATO;
    IF  VRS_MIN%NOTFOUND then
        VR_MAIS_BARATO := 0;
    END IF;
  CLOSE VRS_MIN;

RETURN VR_MAIS_BARATO;

END VOO_MAIS_BARATO;


-- 5. 
-- Função que devolva o salário total de um piloto num dado mês.




-- 6. 
-- Função que devolva o número de um avião que pode ser alocado a um dado voo regular. 
-- Um avião só pode ser alocado a um voo se o aeroporto origem corresponde ao aeroporto 
-- destino da última viagem que o avião faz (onde o avião se encontra) e a hora de partida é 
-- superior a 2 h em relação ao tempo de chegada desta última viagem.