-- VIEWS

-- 1.
-- View que permita obter os pilotos que mais horas fizeram de voo por tipo de
-- avião (tipo avião, código piloto, nome, número horas)

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

-- 2.
-- View que permita obter todos os voos regulares que se realizam 
-- entre duas cidades para as quais há ligações todos os dias da 
-- semana (cidade origem, cidade destino, dia semana, horário).

CREATE OR REPLACE VIEW VW_VOOS_TODOS_DIAS AS

SELECT CO.NOME, CD.NOME, VR.DIA_DA_SEMANA, VR.HORARIO_PARTIDA
FROM    CIDADE CO, CIDADE CD, AEROPORTO AO, AEROPORTO AD, VOO V, VOO_REGULAR VR,
        (
          SELECT VR2.VOO_ID
          FROM VOO_REGULAR VR2
          GROUP BY VR2.VOO_ID
          HAVING COUNT(DISTINCT VR2.DIA_DA_SEMANA) = 7
        ) VOO_TODOS_DIAS
WHERE   VR.VOO_ID = V.VOO_ID
    AND V.AEROPORTO_ORIGEM = AO.IATA_ID
    AND V.AEROPORTO_DESTINO = AD.IATA_ID
    AND AO.CIDADE_ID = CO.CIDADE_ID
    AND AD.CIDADE_ID = CD.CIDADE_ID
    AND VOO_TODOS_DIAS.VOO_ID = VR.VOO_ID
ORDER BY DIA_DA_SEMANA;