-- ============================================================
-- Dengue en Veracruz | 01 - Estructura de la base de datos
-- Motor: MariaDB / MySQL (XAMPP)
-- Ejecutar primero. Después hay que importar los CSV a mano
-- (ver instrucciones al inicio de 02_carga_y_limpieza.sql)
-- ============================================================

CREATE DATABASE IF NOT EXISTS dengue_veracruz CHARACTER SET utf8mb4;
USE dengue_veracruz;

-- ------------------------------------------------------------
-- Municipios y población (Censo 2020, INEGI - ITER de Veracruz)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_municipio (
  clave_entidad   CHAR(2)      NOT NULL,
  clave_municipio CHAR(3)      NOT NULL,
  nombre          VARCHAR(100) NOT NULL,
  poblacion_2020  INT          NOT NULL,
  clave_inegi     CHAR(5),
  PRIMARY KEY (clave_entidad, clave_municipio)
);

-- ------------------------------------------------------------
-- Staging: el CSV de dengue tal cual, todo como texto
-- (así la carga no falla por formatos raros)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS stg_dengue_raw (
  FECHA_ACTUALIZACION    VARCHAR(30),
  ID_REGISTRO            VARCHAR(30),
  SEXO                   VARCHAR(10),
  EDAD_ANOS              VARCHAR(10),
  ENTIDAD_RES            VARCHAR(10),
  MUNICIPIO_RES          VARCHAR(10),
  HABLA_LENGUA_INDIG     VARCHAR(10),
  INDIGENA               VARCHAR(10),
  ENTIDAD_UM_NOTIF       VARCHAR(10),
  MUNICIPIO_UM_NOTIF     VARCHAR(10),
  INSTITUCION_UM_NOTIF   VARCHAR(10),
  FECHA_SIGN_SINTOMAS    VARCHAR(30),
  TIPO_PACIENTE          VARCHAR(10),
  HEMORRAGICOS           VARCHAR(10),
  DIABETES               VARCHAR(10),
  HIPERTENSION           VARCHAR(10),
  ENFERMEDAD_ULC_PEPTICA VARCHAR(10),
  ENFERMEDAD_RENAL       VARCHAR(10),
  INMUNOSUPR             VARCHAR(10),
  CIRROSIS_HEPATICA      VARCHAR(10),
  EMBARAZO               VARCHAR(10),
  DEFUNCION              VARCHAR(10),
  DICTAMEN               VARCHAR(10),
  TOMA_MUESTRA           VARCHAR(10),
  RESULTADO_PCR          VARCHAR(10),
  ESTATUS_CASO           VARCHAR(10),
  ENTIDAD_ASIG           VARCHAR(10),
  MUNICIPIO_ASIG         VARCHAR(10)
);

-- ------------------------------------------------------------
-- Tabla de hechos: un registro por caso, ya limpia
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fact_casos (
  id_registro    VARCHAR(30),
  fecha_sintomas DATE,
  clave_inegi    CHAR(5),
  sexo           TINYINT,
  edad           SMALLINT,
  tipo_paciente  TINYINT,
  hemorragicos   TINYINT,
  diabetes       TINYINT,
  hipertension   TINYINT,
  embarazo       TINYINT,
  defuncion      TINYINT,
  dictamen       TINYINT,
  resultado_pcr  TINYINT,
  estatus_caso   TINYINT
);

-- ------------------------------------------------------------
-- Dimensiones con el significado de los códigos
-- (fuente: archivo "Catálogos" de la DGE)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_estatus (clave TINYINT PRIMARY KEY, descripcion VARCHAR(30));
INSERT INTO dim_estatus VALUES (1,'Probable'),(2,'Confirmado'),(3,'Descartado');

CREATE TABLE IF NOT EXISTS dim_dictamen (clave TINYINT PRIMARY KEY, descripcion VARCHAR(40));
INSERT INTO dim_dictamen VALUES
  (1,'Confirmado a dengue'),(2,'Confirmado a chikungunya'),
  (3,'Negativo'),(4,'En estudio'),(5,'No aplica');

CREATE TABLE IF NOT EXISTS dim_serotipo (clave TINYINT PRIMARY KEY, descripcion VARCHAR(30));
INSERT INTO dim_serotipo VALUES
  (1,'DENV1'),(2,'DENV2'),(3,'DENV3'),(4,'DENV4'),(5,'Sin serotipo aislado');

CREATE TABLE IF NOT EXISTS dim_tipo_paciente (clave TINYINT PRIMARY KEY, descripcion VARCHAR(20));
INSERT INTO dim_tipo_paciente VALUES (1,'Ambulatorio'),(2,'Hospitalizado');

CREATE TABLE IF NOT EXISTS dim_sexo (clave TINYINT PRIMARY KEY, descripcion VARCHAR(10));
INSERT INTO dim_sexo VALUES (1,'Mujer'),(2,'Hombre');
