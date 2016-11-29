-- VIEWS

-- 1.
-- View que permita obter os pilotos que mais horas fizeram de voo por tipo de
-- avião (tipo avião, código piloto, nome, número horas)

--CREATE OR REPLACE VIEW VW_HORAS_VOO_POR_AVIAO AS

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

-- 3.
-- View que para cada voo de ligação indique a viagem com maior atraso (código
-- voo_regular, data, aeroporto origem, aeroporto destino, tempo de atraso).

SELECT  VoR.VOO_REGULAR_ID codigo_voo_regular, 
        TO_CHAR(ViR.DATA_REALIZADA_CHEGADA,'YYYY/MM/DD') data_voo_realizado, 
        AO.NOME aeroporto_origem, 
        AD.NOME aeroporto_destino, 
        TO_CHAR(ViR.DATA_REALIZADA_CHEGADA,'HH:MI') tempo_atraso

FROM    VIAGEM_REALIZADA ViR, VOO_REGULAR VoR, AEROPORTO AO, AEROPORTO AD, VIAGEM_PLANEADA VP

WHERE   ViR.VIAGEM_REALIZADA_ID = VP.VIAGEM_PLANEADA_ID
    AND VP.VOO_REGULAR = VoR.VOO_REGULAR_ID;