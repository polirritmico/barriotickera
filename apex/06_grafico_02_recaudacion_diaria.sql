-- DASHBOARD BARRIOTICKERA: Recaudación diaria de entradas (CLP)
-- Serie (Identification > Name): Recaudación por día
-- Region > Source: Local Database / SQL Query. Pegar el SELECT de abajo.
-- Serie > Source > Location: Region Source.
-- Column Mapping: Label = DEPARTMENT; Value = SALARY; Series Name sin seleccionar.
-- Order By = None. Consulta de lectura: no crea ni modifica tablas.
-- Los graficos de dinero usan el precio actual del tipo de entrada.

SELECT TO_CHAR(TRUNC(v.timestamp_venta), 'YYYY-MM-DD') AS department,
       SUM(t.valor) AS salary
FROM ventas_entradas v
JOIN entradas e
  ON e.id_venta_entrada = v.id_venta_entrada
JOIN tipos_entradas t
  ON t.id_tipo_entrada = e.id_tipo_entrada
JOIN estados_entradas s
  ON s.id_estado_entrada = e.id_estado_entrada
WHERE s.nombre IN ('VENDIDA', 'UTILIZADA')
GROUP BY TRUNC(v.timestamp_venta)
ORDER BY TRUNC(v.timestamp_venta)
