-- DASHBOARD BARRIOTICKERA: Entradas por estado
-- Serie (Identification > Name): Cantidad de entradas
-- Region > Source: Local Database / SQL Query. Pegar el SELECT de abajo.
-- Serie > Source > Location: Region Source.
-- Column Mapping: Label = LABEL; Value = VALUE; Series Name sin seleccionar.
-- Order By = None. Consulta de lectura: no crea ni modifica tablas.
-- Los graficos de dinero usan el precio actual del tipo de entrada.

SELECT s.nombre AS label,
       COUNT(*) AS value
FROM entradas e
JOIN estados_entradas s
  ON s.id_estado_entrada = e.id_estado_entrada
GROUP BY s.nombre
ORDER BY s.nombre
