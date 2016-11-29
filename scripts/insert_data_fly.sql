INSERT INTO MARCA VALUES (1, 'Boeing');
INSERT INTO MARCA VALUES (2, 'Airbus');

INSERT INTO MARCA_MODELO VALUES (1, 1, '777');
INSERT INTO MARCA_MODELO VALUES (2, 1, '787');
INSERT INTO MARCA_MODELO VALUES (3, 2, 'A330');

INSERT INTO TIPO_AVIAO VALUES (1, 1000, 1010, 10000, 1000, 10);
INSERT INTO TIPO_AVIAO VALUES (2, 1200, 1020, 100000, 1500, 6);
INSERT INTO TIPO_AVIAO VALUES (3, 900, 1400, 20000, 1200, 4);

INSERT INTO AVIAO VALUES ('F01', 1);
INSERT INTO AVIAO VALUES ('F02', 1);
INSERT INTO AVIAO VALUES ('F03', 2);
INSERT INTO AVIAO VALUES ('F04', 3);
INSERT INTO AVIAO VALUES ('F05', 1);

INSERT INTO CLASSE VALUES (1, 'ECONOMICA');
INSERT INTO CLASSE VALUES (2, 'EXECUTIVA');

INSERT INTO CLASSE_TIPO_AVIAO VALUES (1, 1);
INSERT INTO CLASSE_TIPO_AVIAO VALUES (2, 1);
INSERT INTO CLASSE_TIPO_AVIAO VALUES (3, 1);
INSERT INTO CLASSE_TIPO_AVIAO VALUES (1, 2);
INSERT INTO CLASSE_TIPO_AVIAO VALUES (2, 2);

INSERT INTO LUGAR VALUES (1, 'A', 1, 1);
INSERT INTO LUGAR VALUES (2, 'A', 1, 1);
INSERT INTO LUGAR VALUES (3, 'A', 1, 1);
INSERT INTO LUGAR VALUES (4, 'A', 1, 2);
INSERT INTO LUGAR VALUES (5, 'A', 1, 2);
INSERT INTO LUGAR VALUES (1, 'B', 1, 1);
INSERT INTO LUGAR VALUES (2, 'B', 1, 1);
INSERT INTO LUGAR VALUES (3, 'B', 1, 1);
INSERT INTO LUGAR VALUES (4, 'B', 1, 2);
INSERT INTO LUGAR VALUES (5, 'B', 1, 2);
INSERT INTO LUGAR VALUES (1, 'A', 2, 2);
INSERT INTO LUGAR VALUES (2, 'A', 2, 1);
INSERT INTO LUGAR VALUES (3, 'A', 2, 1);
INSERT INTO LUGAR VALUES (1, 'B', 2, 2);
INSERT INTO LUGAR VALUES (2, 'B', 2, 1);
INSERT INTO LUGAR VALUES (3, 'B', 2, 1);
INSERT INTO LUGAR VALUES (1, 'A', 3, 1);
INSERT INTO LUGAR VALUES (2, 'A', 3, 1);
INSERT INTO LUGAR VALUES (1, 'B', 3, 1);
INSERT INTO LUGAR VALUES (2, 'B', 3, 1);

INSERT INTO CATEGORIA_TRIP VALUES (1, 'PILOTO', 5000.0);
INSERT INTO CATEGORIA_TRIP VALUES (2, 'COMISSARIO', 3000.0);

INSERT INTO TRIPULANTE VALUES (1, 'TIAGO', 2);
INSERT INTO TRIPULANTE VALUES (2, 'RENATO', 2);
INSERT INTO TRIPULANTE VALUES (3, 'ERIC', 2);
INSERT INTO TRIPULANTE VALUES (4, 'FLAVIO', 2);
INSERT INTO TRIPULANTE VALUES (5, 'ANA', 2);
INSERT INTO TRIPULANTE VALUES (6, 'ISABEL', 2);
INSERT INTO TRIPULANTE VALUES (7, 'ELSA', 2);
INSERT INTO TRIPULANTE VALUES (8, 'RUI', 2);
INSERT INTO TRIPULANTE VALUES (9, 'JOANA', 2);
INSERT INTO TRIPULANTE VALUES (10, 'ANDRE', 2);
INSERT INTO TRIPULANTE VALUES (11, 'JOSE', 2);
INSERT INTO TRIPULANTE VALUES (12, 'LARA', 2);
INSERT INTO TRIPULANTE VALUES (13, 'IVO', 1);
INSERT INTO TRIPULANTE VALUES (14, 'DANIEL', 1);
INSERT INTO TRIPULANTE VALUES (15, 'BERNARDO', 1);
INSERT INTO TRIPULANTE VALUES (16, 'DINIS', 1);

INSERT INTO HORAS_VOO VALUES (13, 1, 1);
INSERT INTO HORAS_VOO VALUES (13, 2, 10000);
INSERT INTO HORAS_VOO VALUES (14, 3, 2);
INSERT INTO HORAS_VOO VALUES (14, 1, 5000);
INSERT INTO HORAS_VOO VALUES (14, 2, 1);
INSERT INTO HORAS_VOO VALUES (13, 3, 7000);

INSERT INTO HORAS_VOO VALUES (15, 1, 130);
INSERT INTO HORAS_VOO VALUES (15, 2, 1000);
INSERT INTO HORAS_VOO VALUES (15, 3, 2);
INSERT INTO HORAS_VOO VALUES (16, 1, 8000);
INSERT INTO HORAS_VOO VALUES (16, 2, 120);
INSERT INTO HORAS_VOO VALUES (16, 3, 3500);

INSERT INTO LATITUDE VALUES (1, 70, 30, 20, 'S');
INSERT INTO LATITUDE VALUES (2, 180, 20, 10, 'N');
INSERT INTO LATITUDE VALUES (3, 340, 15, 20, 'N');
INSERT INTO LATITUDE VALUES (4, 230, 34, 56, 'S');
INSERT INTO LATITUDE VALUES (5, 120, 12, 45, 'S');
INSERT INTO LATITUDE VALUES (6, 65, 20, 34, 'N');

INSERT INTO LONGITUDE VALUES (1, 70, 30, 20, 'E');
INSERT INTO LONGITUDE VALUES (2, 180, 20, 10, 'O');
INSERT INTO LONGITUDE VALUES (3, 340, 15, 20, 'E');
INSERT INTO LONGITUDE VALUES (4, 230, 34, 56, 'E');
INSERT INTO LONGITUDE VALUES (5, 120, 12, 45, 'E');
INSERT INTO LONGITUDE VALUES (6, 65, 20, 34, 'O');


INSERT INTO PAIS VALUES (1, 'PORTUGAL');
INSERT INTO PAIS VALUES (2, 'ESPANHA');
INSERT INTO PAIS VALUES (3, 'ALEMANHA');
INSERT INTO PAIS VALUES (4, 'POLONIA');

INSERT INTO CIDADE VALUES (1, 1, 'PORTO');
INSERT INTO CIDADE VALUES (2, 1, 'LISBOA');
INSERT INTO CIDADE VALUES (3, 1, 'FARO');
INSERT INTO CIDADE VALUES (4, 2, 'MADRID');
INSERT INTO CIDADE VALUES (5, 3, 'FRANKFURT');
INSERT INTO CIDADE VALUES (6, 4, 'VARSOVIA');
INSERT INTO CIDADE VALUES (7, 4, 'LODZ');

INSERT INTO AEROPORTO VALUES ('OPO', 'AEROPORTO PORTO', 1, 1, 1);
INSERT INTO AEROPORTO VALUES ('LIS', 'AEROPORTO LISBOA', 2, 2, 2);
INSERT INTO AEROPORTO VALUES ('FAR', 'AEROPORTO FARO', 3, 3, 3);
INSERT INTO AEROPORTO VALUES ('MAD', 'AEROPORTO MADRID', 4, 4, 4);
INSERT INTO AEROPORTO VALUES ('FRA', 'AEROPORTO FRANKFURT', 5, 5, 5);
INSERT INTO AEROPORTO VALUES ('VAR', 'AEROPORTO VARSOVIA', 6, 6, 6);

INSERT INTO ROTA VALUES (1, 'ROTA OPO-MAD');
INSERT INTO ROTA VALUES (2, 'ROTA OPO-VAR');
INSERT INTO ROTA VALUES (3, 'ROTA OPO-VAR (C/ ESCALA)');
INSERT INTO ROTA VALUES (4, 'ROTA OPO-MAD (C/ ESCALA)');
INSERT INTO ROTA VALUES (5, 'ROTA OPO-LIS');
INSERT INTO ROTA VALUES (6, 'ROTA OPO-FAR (C/ ESCALA)');

INSERT INTO CATEGORIA_VOO VALUES (1, 'DOMESTICO');
INSERT INTO CATEGORIA_VOO VALUES (2, 'EUROPA');

INSERT INTO VOO VALUES (1, 300, 60, 'OPO', 'LIS', 1);
INSERT INTO VOO VALUES (2, 500, 90, 'OPO', 'MAD', 2);
INSERT INTO VOO VALUES (3, 1000, 210, 'OPO', 'VAR', 2);
INSERT INTO VOO VALUES (4, 300, 60, 'OPO', 'LIS', 1);
INSERT INTO VOO VALUES (5, 600, 120, 'OPO', 'FRA', 2);
INSERT INTO VOO VALUES (6, 300, 90, 'FRA', 'VAR', 2);
INSERT INTO VOO VALUES (7, 450, 90, 'LIS', 'MAD', 2);
INSERT INTO VOO VALUES (8, 300, 60, 'LIS', 'FAR', 1);

INSERT INTO VOO_ROTA VALUES (1, 2);
INSERT INTO VOO_ROTA VALUES (2, 3);
INSERT INTO VOO_ROTA VALUES (3, 5);
INSERT INTO VOO_ROTA VALUES (3, 6);
INSERT INTO VOO_ROTA VALUES (4, 1);
INSERT INTO VOO_ROTA VALUES (4, 7);
INSERT INTO VOO_ROTA VALUES (5, 1);
INSERT INTO VOO_ROTA VALUES (6, 1);
INSERT INTO VOO_ROTA VALUES (6, 8);

INSERT INTO PLANO VALUES (1, 'PLANO DEZEMBRO', TO_DATE('01-DEZ-16','DD-MON-YY'), TO_DATE('31-DEZ-16','DD-MON-YY'));
INSERT INTO PLANO VALUES (2, 'PLANO PRIMAVERA', TO_DATE('21-MAR-17','DD-MON-YY'), TO_DATE('20-JUN-17','DD-MON-YY'));

INSERT INTO VOO_REGULAR VALUES (1, 1, 1, 'F04', 1, '09:00');
INSERT INTO VOO_REGULAR VALUES (2, 1, 8, 'F02', 1, '12:00');
INSERT INTO VOO_REGULAR VALUES (3, 1, 2, 'F03', 4, '10:30');
INSERT INTO VOO_REGULAR VALUES (4, 2, 3, 'F01', 3, '09:00');
INSERT INTO VOO_REGULAR VALUES (5, 2, 5, 'F02', 6, '08:00');
INSERT INTO VOO_REGULAR VALUES (6, 2, 6, 'F03', 6, '15:00');
INSERT INTO VOO_REGULAR VALUES (7, 1, 1, 'F04', 2, '09:00');
INSERT INTO VOO_REGULAR VALUES (8, 1, 1, 'F04', 3, '09:00');
INSERT INTO VOO_REGULAR VALUES (9, 1, 1, 'F04', 4, '09:00');
INSERT INTO VOO_REGULAR VALUES (10, 1, 1, 'F04', 5, '09:00');
INSERT INTO VOO_REGULAR VALUES (11, 1, 1, 'F04', 6, '09:00');
INSERT INTO VOO_REGULAR VALUES (12, 1, 1, 'F04', 7, '09:00');

INSERT INTO VIAGEM_PLANEADA VALUES (1, 1, TO_DATE('2016/12/04 09:00','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/04 10:00','YYYY/MM/DD HH24:MI'));
INSERT INTO VIAGEM_PLANEADA VALUES (2, 2, TO_DATE('2016/12/04 12:00','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/04 13:00','YYYY/MM/DD HH24:MI'));
INSERT INTO VIAGEM_PLANEADA VALUES (3, 4, TO_DATE('2016/12/06 09:00','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/06 12:30','YYYY/MM/DD HH24:MI'));

INSERT INTO PRECO VALUES (1, 1, 300.00);
INSERT INTO PRECO VALUES (2, 1, 350.00);
INSERT INTO PRECO VALUES (2, 2, 500.00);
INSERT INTO PRECO VALUES (3, 1, 400.00);
INSERT INTO PRECO VALUES (3, 2, 650.00);

INSERT INTO VIAGEM_REALIZADA VALUES (1, TO_DATE('2016/12/04 09:10','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/04 10:20','YYYY/MM/DD HH24:MI'));
INSERT INTO VIAGEM_REALIZADA VALUES (2, TO_DATE('2016/12/04 12:05','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/04 13:10','YYYY/MM/DD HH24:MI'));
INSERT INTO VIAGEM_REALIZADA VALUES (3, TO_DATE('2016/12/06 09:10','YYYY/MM/DD HH24:MI'), TO_DATE('2016/12/06 14:40','YYYY/MM/DD HH24:MI'));

INSERT INTO TRIPULANTE_CABINE VALUES (1, 1, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (1, 6, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (1, 2, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (1, 4, 'COMISSARIO CHEFE');
INSERT INTO TRIPULANTE_CABINE VALUES (2, 2, 'COMISSARIO CHEFE');
INSERT INTO TRIPULANTE_CABINE VALUES (2, 3, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (2, 5, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (2, 7, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 7, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 8, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 9, 'COMISSARIO CHEFE');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 10, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 11, 'COMISSARIO');
INSERT INTO TRIPULANTE_CABINE VALUES (3, 12, 'COMISSARIO');

INSERT INTO TRIPULANTE_TECNICO VALUES (1, 13, 'PILOTO');
INSERT INTO TRIPULANTE_TECNICO VALUES (1, 14, 'CO-PILOTO');
INSERT INTO TRIPULANTE_TECNICO VALUES (2, 16, 'PILOTO');
INSERT INTO TRIPULANTE_TECNICO VALUES (2, 15, 'CO-PILOTO');
INSERT INTO TRIPULANTE_TECNICO VALUES (3, 13, 'PILOTO');
INSERT INTO TRIPULANTE_TECNICO VALUES (3, 14, 'CO-PILOTO');

INSERT INTO PASSAGEIRO VALUES (1, 'FABIO', 'MORIM', 'PASSAPORTE', 1502345);
INSERT INTO PASSAGEIRO VALUES (2, 'PEDRO', 'SILVA', 'PASSAPORTE', 1402246);
INSERT INTO PASSAGEIRO VALUES (3, 'RUBEN', 'DIAS', 'CARTAO CIDADAO', 95002334);
INSERT INTO PASSAGEIRO VALUES (4, 'ANA', 'DIAS', 'CARTAO CIDADAO', 96012674);

INSERT INTO RESERVA VALUES (1, 1, 1, 1, 1, 'A');
INSERT INTO RESERVA VALUES (2, 2, 1, 1, 1, 'B');
INSERT INTO RESERVA VALUES (3, 3, 2, 1, 2, 'A');
INSERT INTO RESERVA VALUES (4, 4, 2, 2, 5, 'A');

INSERT INTO BONUS VALUES (1, 1, 300.0);
INSERT INTO BONUS VALUES (1, 2, 100.0);
INSERT INTO BONUS VALUES (2, 1, 400.0);
INSERT INTO BONUS VALUES (2, 2, 200.0);











