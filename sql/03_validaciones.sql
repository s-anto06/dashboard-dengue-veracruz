-- ============================================================
-- Dengue en Veracruz | 03 - Validaciones
-- Consultas para comprobar que la carga salió bien
-- ============================================================
USE dengue_veracruz;

-- Municipios: deben ser 212 y sumar 8,062,579 habitantes
SELECT COUNT(*) AS municipios, SUM(poblacion_2020) AS poblacion
FROM dim_municipio;

-- Casos cargados (en mi caso: 108,801, todos de Veracruz)
SELECT COUNT(*) AS registros FROM stg_dengue_raw;
SELECT ENTIDAD_RES, COUNT(*) FROM stg_dengue_raw GROUP BY ENTIDAD_RES;

-- Rango de fechas de la tabla limpia
SELECT MIN(fecha_sintomas), MAX(fecha_sintomas), COUNT(*) FROM fact_casos;

-- Casos que no cruzan con ningún municipio (debe dar 0)
SELECT COUNT(*) AS sin_municipio
FROM fact_casos f
LEFT JOIN dim_municipio m ON m.clave_inegi = f.clave_inegi
WHERE m.clave_inegi IS NULL;

-- Casos por año y estatus (para comparar con lo que muestra Power BI)
SELECT YEAR(fecha_sintomas) AS anio, estatus_caso, COUNT(*) AS casos
FROM fact_casos
GROUP BY 1, 2
ORDER BY 1, 2;
