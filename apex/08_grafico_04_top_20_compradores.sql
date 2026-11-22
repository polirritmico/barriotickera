-- DASHBOARD BARRIOTICKERA: Top 20 compradores por importe en entradas (CLP)
-- Serie (Identification > Name): Importe por comprador
-- Region > Source: Local Database / SQL Query. Pegar el SELECT de abajo.
-- Serie > Source > Location: Region Source.
-- Column Mapping: Label = LABEL; Value = VALUE; Series Name sin seleccionar.
-- Order By = None. Consulta de lectura: no crea ni modifica tablas.
-- Los graficos de dinero usan el precio actual del tipo de entrada.

SELECT c.correo AS label,
       SUM(t.valor) AS value
FROM compradores c
JOIN ventas_entradas v
  ON v.id_comprador = c.id_comprador
JOIN entradas e
  ON e.id_venta_entrada = v.id_venta_entrada
JOIN tipos_entradas t
  ON t.id_tipo_entrada = e.id_tipo_entrada
JOIN estados_entradas s
  ON s.id_estado_entrada = e.id_estado_entrada
WHERE s.nombre IN ('VENDIDA', 'UTILIZADA')
GROUP BY c.correo
ORDER BY value DESC, c.correo
FETCH FIRST 20 ROWS ONLY
