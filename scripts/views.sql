-- VIEWS

-- 1.
-- View que permita obter os pilotos que mais horas fizeram de voo por tipo de
-- avi�o (tipo avi�o, c�digo piloto, nome, n�mero horas)

CREATE OR REPLACE VIEW VW_HORAS_VOO_POR_AVIAO AS

SELECT Ma.NOME marca, MM.NOME modelo, HV.PILOTO_ID id_piloto, T.NOME nome_piloto, HV.HORAS_VOO horas_voo

FROM MARCA Ma, MARCA_MODELO MM, TRIPULANTE T, HORAS_VOO HV,

    (SELECT MARCA_MODELO, MAX(HORAS_VOO) HORAS_MAXIMAS
    FROM HORAS_VOO
    GROUP BY MARCA_MODELO) SUBQ

WHERE HV.PILOTO_ID = T.TRIPULANTE_ID
    AND HV.MARCA_MODELO = MM.MARCA_MODELO_ID
    AND MM.MARCA_ID = Ma.MARCA_ID
    AND HV.MARCA_MODELO = SUBQ.MARCA_MODELO
    AND HV.HORAS_VOO = SUBQ.HORAS_MAXIMAS;
    

SELECT * FROM VW_HORAS_VOO_POR_AVIAO;