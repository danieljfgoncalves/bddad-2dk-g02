CREATE TABLE MARCA (
	MARCA_ID INTEGER PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE MARCA_MODELO (
	MARCA_MODELO_ID INTEGER PRIMARY KEY,
	MARCA_ID INTEGER REFERENCES MARCA(MARCA_ID),
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE TIPO_AVIAO (
	MARCA_MODELO INTEGER PRIMARY KEY REFERENCES MARCA_MODELO(MARCA_MODELO_ID),
	VELOCIDADE_MAX INTEGER NOT NULL,
	CAPACIDADE_DEPOSITO INTEGER NOT NULL,
	CARGA_MAX INTEGER NOT NULL,
	HORAS_VOO_MIN INTEGER NOT NULL,
	TOTAL_LUGARES INTEGER NOT NULL
);

CREATE TABLE AVIAO (
	NUM_SERIE VARCHAR(3) PRIMARY KEY,
	MARCA_MODELO INTEGER REFERENCES MARCA_MODELO(MARCA_MODELO_ID)
);

CREATE TABLE CLASSE (
	CLASSE_ID INTEGER PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
  CONSTRAINT CK_QUANTIDADE_CLASSES CHECK (CLASSE_ID BETWEEN 1 AND 2)
);

CREATE TABLE CLASSE_TIPO_AVIAO (
	MARCA_MODELO INTEGER REFERENCES TIPO_AVIAO(MARCA_MODELO),
	CLASSE INTEGER REFERENCES CLASSE(CLASSE_ID),
	CONSTRAINT PK_CLASSE_TIPO_AVIAO PRIMARY KEY (MARCA_MODELO, CLASSE),
);

CREATE TABLE LUGAR (
	NUM_FILA INTEGER,
	LETRA CHAR(1),
	MARCA_MODELO INTEGER,
	CLASSE INTEGER,
  CONSTRAINT FK_LUGAR FOREIGN KEY (MARCA_MODELO, CLASSE) REFERENCES CLASSE_TIPO_AVIAO(MARCA_MODELO, CLASSE),
	CONSTRAINT PK_LUGAR PRIMARY KEY (NUM_FILA, LETRA, MARCA_MODELO, CLASSE)
);

CREATE TABLE CATEGORIA_TRIP (
	CATEGORIA_TRIP_ID INTEGER PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	SALARIO_MENSAL FLOAT(10) NOT NULL
);

CREATE TABLE TRIPULANTE (
	TRIPULANTE_ID INTEGER PRIMARY KEY,
	CATEGORIA INTEGER REFERENCES CATEGORIA_TRIP(CATEGORIA_TRIP_ID)
);


CREATE TABLE HORAS_VOO (
	PILOTO_ID INTEGER REFERENCES TRIPULANTE(TRIPULANTE_ID),
	MARCA_MODELO INTEGER,
	HORAS_VOO INTEGER NOT NULL,
	CONSTRAINT PK_HORAS_VOO PRIMARY KEY (PILOTO_ID, MARCA_MODELO),
  CONSTRAINT FK_HORAS_VOO FOREIGN KEY (MARCA_MODELO) REFERENCES TIPO_AVIAO(MARCA_MODELO)
);

CREATE TABLE LATITUDE (
	LATITUDE_ID INTEGER PRIMARY KEY,
	GRAUS NUMBER(3, 0) NOT NULL,
	MINUTOS NUMBER(2, 0) NOT NULL,
	SEGUNDOS NUMBER(2, 0) NOT NULL,
	ORIENTACAO CHAR(1) NOT NULL
);

CREATE TABLE LONGITUDE (
	LONGITUDE_ID INTEGER PRIMARY KEY,
	GRAUS NUMBER(3, 0) NOT NULL,
	MINUTOS NUMBER(2, 0) NOT NULL,
	SEGUNDOS NUMBER(2, 0) NOT NULL,
	ORIENTACAO CHAR(1) NOT NULL
);

CREATE TABLE PAIS (
	PAIS_ID NUMBER(3, 0) PRIMARY KEY,
	NOME VARCHAR(50)
);

CREATE TABLE CIDADE (
	CIDADE_ID INTEGER PRIMARY KEY,
	PAIS_ID NUMBER(3, 0) REFERENCES PAIS(PAIS_ID),
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE AEROPORTO (
	IATA_ID CHAR(3) PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL,
	CIDADE_ID INTEGER REFERENCES CIDADE(CIDADE_ID),
	LONGITUDE_ID INTEGER REFERENCES LONGITUDE(LONGITUDE_ID),
	LATITUDE_ID INTEGER REFERENCES LATITUDE(LATITUDE_ID)
);

CREATE TABLE ROTA (
	ROTA_ID INTEGER PRIMARY KEY,
	DESCRICAO VARCHAR(50) NOT NULL
);

CREATE TABLE CATEGORIA_VOO (
	CAT_VOO_ID INTEGER PRIMARY KEY,
	NOME VARCHAR(50) NOT NULL
);

CREATE TABLE VOO (
	VOO_ID INTEGER PRIMARY KEY,
	DISTANCIA INTEGER NOT NULL,
	DURACAO_MINUTOS INTEGER NOT NULL,
	AEROPORTO_ORIGEM CHAR(3) REFERENCES AEROPORTO(IATA_ID),
	AEROPORTO_DESTINO CHAR(3) REFERENCES AEROPORTO(IATA_ID),
	CAT_VOO_ID INTEGER REFERENCES CATEGORIA_VOO(CAT_VOO_ID)
);

CREATE TABLE VOO_ROTA(
	ROTA_ID INTEGER REFERENCES ROTA(ROTA_ID),
	VOO_ID INTEGER REFERENCES VOO(VOO_ID),
	CONSTRAINT PK_VOO_ROTA PRIMARY KEY (ROTA_ID, VOO_ID)
);

CREATE TABLE PLANO(
	PLANO_ID INTEGER PRIMARY KEY,
	DESCRICAO VARCHAR(50) NOT NULL,
	DATA_INICIO DATE NOT NULL,
	DATA_FIM DATE NOT NULL
);

CREATE TABLE VOO_REGULAR(
	VOO_REGULAR_ID INTEGER PRIMARY KEY,
	PLANO_ID INTEGER REFERENCES PLANO(PLANO_ID),
	VOO_ID INTEGER REFERENCES VOO(VOO_ID),
	AVIAO VARCHAR(3) REFERENCES AVIAO(NUM_SERIE),
	DIA_DA_SEMANA NUMERIC(1, 0) NOT NULL,
	HORARIO_PARTIDA CHAR(5) NOT NULL
);

CREATE TABLE PRECO(
	VOO_REGULAR_ID INTEGER REFERENCES VOO_REGULAR(VOO_REGULAR_ID),
	CLASSE_ID INTEGER REFERENCES CLASSE(CLASSE_ID),
	PRECO FLOAT(10) NOT NULL,
	CONSTRAINT PK_PRECO PRIMARY KEY (VOO_REGULAR_ID, CLASSE_ID)
);

CREATE TABLE VIAGEM_PLANEADA (
	VIAGEM_PLANEADA_ID INTEGER PRIMARY KEY,
	VOO_REGULAR INTEGER REFERENCES VOO_REGULAR(VOO_REGULAR_ID),
	DATA_PLANEADA_PARTIDA DATE NOT NULL,
	DATA_PLANEADA_CHEGADA DATE NOT NULL
);

CREATE TABLE VIAGEM_REALIZADA (
	VIAGEM_REALIZADA_ID INTEGER PRIMARY KEY REFERENCES VIAGEM_PLANEADA(VIAGEM_PLANEADA_ID),
	DATA_REALIZADA_PARTIDA DATE NOT NULL,
	DATA_REALIZADA_CHEGADA DATE NOT NULL
);

CREATE TABLE TRIPULANTE_CABINE (
	VIAGEM_REALIZADA INTEGER REFERENCES VIAGEM_REALIZADA(VIAGEM_REALIZADA_ID),
	TRIPULANTE INTEGER REFERENCES TRIPULANTE(TRIPULANTE_ID),
	FUNCAO VARCHAR(50) NOT NULL,
	CONSTRAINT PK_TRIP_CABINE PRIMARY KEY (VIAGEM_REALIZADA, TRIPULANTE)
);

CREATE TABLE TRIPULANTE_TECNICO (
	VIAGEM_REALIZADA INTEGER REFERENCES VIAGEM_REALIZADA(VIAGEM_REALIZADA_ID),
	TRIPULANTE INTEGER REFERENCES TRIPULANTE(TRIPULANTE_ID),
	FUNCAO VARCHAR(50) NOT NULL,
	CONSTRAINT PK_TRIP_TECNICO PRIMARY KEY (VIAGEM_REALIZADA, TRIPULANTE)
);

CREATE TABLE PASSAGEIRO (
	PASSAGEIRO_ID INTEGER PRIMARY KEY,
	PRIMEIRO_NOME VARCHAR(50) NOT NULL,
	ULTIMO_NOME VARCHAR(50) NOT NULL,
	TIPO_DOCUMENTO VARCHAR(50) NOT NULL,
	NUM_DOCUMENTO INTEGER NOT NULL
);

CREATE TABLE RESERVA (
	RESERVA_ID INTEGER PRIMARY KEY,
	PASSAGEIRO INTEGER REFERENCES PASSAGEIRO(PASSAGEIRO_ID),
	VOO_REGULAR INTEGER,
	CLASSE INTEGER,
	NUM_FILA_LUGAR INTEGER,
	LETRA_LUGAR CHAR(1),
  CONSTRAINT FK_RESERVA FOREIGN KEY (VOO_REGULAR, CLASSE) REFERENCES PRECO(VOO_REGULAR_ID, CLASSE_ID)
);

CREATE TABLE BONUS(
	CAT_VOO_ID INTEGER REFERENCES CATEGORIA_VOO(CAT_VOO_ID),
	CATEGORIA_TRIP_ID INTEGER REFERENCES CATEGORIA_TRIP(CATEGORIA_TRIP_ID),
	BONUS FLOAT(10) NOT NULL,
	CONSTRAINT PK_BONUS PRIMARY KEY (CAT_VOO_ID, CATEGORIA_TRIP_ID)
);