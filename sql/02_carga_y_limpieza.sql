-- ============================================================
-- Dengue en Veracruz | 02 - Carga y limpieza
-- Ejecutar después de 01_estructura.sql
-- ============================================================
USE dengue_veracruz;

-- ------------------------------------------------------------
-- PASO MANUAL 1: municipios
-- Del ITER del Censo 2020 (INEGI) dejé solo las filas de
-- "Total del Municipio" (LOC = 0000), sin el total estatal.
-- Quedan 212 filas. Guardé 4 columnas en este orden:
--   ENTIDAD, MUN, NOM_MUN, POBTOT
-- ENTIDAD y MUN en formato texto para no perder los ceros.
-- Importar el CSV (UTF-8) en phpMyAdmin -> tabla dim_municipio
-- -> pestaña Importar, con estas columnas:
--   clave_entidad,clave_municipio,nombre,poblacion_2020
--
-- PASO MANUAL 2: casos de dengue
-- Del CSV de la DGE me quedé solo con ENTIDAD_RES = 30 (Veracruz).
-- Importar el CSV en phpMyAdmin -> tabla stg_dengue_raw.
-- ------------------------------------------------------------

-- Arreglar claves de municipios (se importó el nombre del estado
-- en vez de "30") y armar la clave que cruza con los casos
UPDATE dim_municipio SET clave_entidad = '30';
UPDATE dim_municipio SET clave_inegi = CONCAT(clave_entidad, clave_municipio);

-- ------------------------------------------------------------
-- Limpieza: de staging (todo texto) a la tabla de hechos
-- - Las fechas vienen como número de serie de Excel (43831 = 2020-01-01)
-- - MUNICIPIO_RES viene sin ceros, se rellena a 3 dígitos
-- ------------------------------------------------------------
TRUNCATE TABLE fact_casos;

INSERT INTO fact_casos
SELECT
  ID_REGISTRO,
  DATE_ADD('1899-12-30', INTERVAL CAST(NULLIF(FECHA_SIGN_SINTOMAS,'') AS UNSIGNED) DAY),
  CONCAT('30', LPAD(MUNICIPIO_RES, 3, '0')),
  CAST(NULLIF(SEXO,'') AS UNSIGNED),
  CAST(NULLIF(EDAD_ANOS,'') AS UNSIGNED),
  CAST(NULLIF(TIPO_PACIENTE,'') AS UNSIGNED),
  CAST(NULLIF(HEMORRAGICOS,'') AS UNSIGNED),
  CAST(NULLIF(DIABETES,'') AS UNSIGNED),
  CAST(NULLIF(HIPERTENSION,'') AS UNSIGNED),
  CAST(NULLIF(EMBARAZO,'') AS UNSIGNED),
  CAST(NULLIF(DEFUNCION,'') AS UNSIGNED),
  CAST(NULLIF(DICTAMEN,'') AS UNSIGNED),
  CAST(NULLIF(RESULTADO_PCR,'') AS UNSIGNED),
  CAST(NULLIF(ESTATUS_CASO,'') AS UNSIGNED)
FROM stg_dengue_raw;

-- Índices para que Power BI cargue más rápido
CREATE INDEX ix_fact_municipio ON fact_casos (clave_inegi);
CREATE INDEX ix_fact_fecha     ON fact_casos (fecha_sintomas);
ALTER TABLE dim_municipio ADD INDEX ix_dim_inegi (clave_inegi);

-- ------------------------------------------------------------
-- Usuario de solo lectura para conectar Power BI
-- Cambia 'TU_CONTRASEÑA' antes de ejecutarlo
-- ------------------------------------------------------------
-- CREATE USER 'powerbi'@'localhost' IDENTIFIED BY 'TU_CONTRASEÑA';
-- GRANT SELECT ON dengue_veracruz.* TO 'powerbi'@'localhost';
-- FLUSH PRIVILEGES;
