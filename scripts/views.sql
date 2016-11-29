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

-- 3.
-- View que para cada voo de ligação indique a viagem com maior atraso (código
-- voo_regular, data, aeroporto origem, aeroporto destino, tempo de atraso).

-- coisas que testei
--TO_CHAR(ViR.DATA_REALIZADA_CHEGADA, 'YYYY/MM/DD HH:MI') data_planeada,
--TO_CHAR(VP.DATA_PLANEADA_CHEGADA, 'YYYY/MM/DD HH:MI') data_chegada
-- O atraso vai em "Horas,Minutos"
--24 * (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) atraso,
   
CREATE OR REPLACE VIEW VW_VIAGENS_MAIOR_ATRASO AS

SELECT  VoR.VOO_REGULAR_ID codigo_voo_regular, 
        TO_CHAR(ViR.DATA_REALIZADA_CHEGADA,'YYYY/MM/DD') data_voo_realizado, 
        AO.NOME aeroporto_origem, 
        AD.NOME aeroporto_destino,
        
         (24 * extract(day from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second))
            + extract(hour from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second)
            + ((1/100) * extract(minute from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second)) ATRASO
        
        
FROM    VIAGEM_REALIZADA ViR, VOO_REGULAR VoR, AEROPORTO AO, AEROPORTO AD, VIAGEM_PLANEADA VP, VOO V,

    (SELECT  sVP.VOO_REGULAR, MAX((24 * extract(day from (sViR.DATA_REALIZADA_CHEGADA - sVP.DATA_PLANEADA_CHEGADA) day(9) to second))
                + extract(hour from (sViR.DATA_REALIZADA_CHEGADA - sVP.DATA_PLANEADA_CHEGADA) day(9) to second)
                + ((1/100) * extract(minute from (sViR.DATA_REALIZADA_CHEGADA - sVP.DATA_PLANEADA_CHEGADA) day(9) to second))) MAX_ATRASO
    FROM VIAGEM_REALIZADA sViR, VIAGEM_PLANEADA sVP
    WHERE sVP.VIAGEM_PLANEADA_ID = sViR.VIAGEM_REALIZADA_ID
    GROUP BY sVP.VOO_REGULAR) SUBQ

WHERE   ViR.VIAGEM_REALIZADA_ID = VP.VIAGEM_PLANEADA_ID
    AND VP.VOO_REGULAR = VoR.VOO_REGULAR_ID
    AND V.VOO_ID = VoR.VOO_ID
    AND V.AEROPORTO_ORIGEM = AO.IATA_ID
    AND V.AEROPORTO_DESTINO = AD.IATA_ID
    AND AO.IATA_ID <> AD.IATA_ID
    AND ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA > 0
    AND SUBQ.VOO_REGULAR = VP.VOO_REGULAR
    AND SUBQ.MAX_ATRASO = (24 * extract(day from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second))
                            + extract(hour from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second)
                            + ((1/100) * extract(minute from (ViR.DATA_REALIZADA_CHEGADA - VP.DATA_PLANEADA_CHEGADA) day(9) to second));
                    