-- DASHBOARD BARRIOTICKERA: Asistencia por tipo de entrada
-- Serie (Identification > Name): Entradas utilizadas
-- Region > Source: Local Database / SQL Query. Pegar el SELECT de abajo.
-- Serie > Source > Location: Region Source.
-- Column Mapping: Label = LABEL; Value = VALUE; Series Name sin seleccionar.
-- Order By = None. Consulta de lectura: no crea ni modifica tablas.
-- Los graficos de dinero usan el precio actual del tipo de entrada.

SELECT t.nombre AS label,
       COUNT(*) AS value
FROM entradas e
JOIN tipos_entradas t
  ON t.id_tipo_entrada = e.id_tipo_entrada
JOIN estados_entradas s
  ON s.id_estado_entrada = e.id_estado_entrada
WHERE s.nombre = 'UTILIZADA'
GROUP BY t.nombre
ORDER BY value DESC
