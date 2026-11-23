# BarrioTickera en Oracle APEX

Carpeta de trabajo para APEX. Los scripts originales de Eduardo están en ../sql.
Aplicación: BarrioTickera, ID 140232. Dashboard: página 2.
Esquema observado: WKSP_BARRIOTICKETERA.

## CRUD y bitácora

Ver [README_CRUD.md](README_CRUD.md) para el recorrido completo del CRUD y la auditoría:
- Página 3: reporte Entradas, enlace Editar y botón Crear entrada.
- Página 5: formulario modal Entrada conectado a pkg_entrada mediante el archivo 09.
- Página 6: reporte Bitácora / Auditoría de entradas, con fecha y hora.
- Creación, actualización y eliminación de una entrada de prueba confirmadas por el usuario; el historial mostró las tres operaciones.

Las secciones siguientes documentan los cuatro gráficos.

## 1. Orden de los archivos

1. 01_creacion_esquema_barrioticketera.sql: tablas y estados iniciales.
2. 02_poblado_datos_barrioticketera.sql: datos de ejemplo de la completada.
3. 03_pkg_entradas.sql: paquete PKG_ENTRADA que utiliza el CRUD de Python.
4. 04_bitacora_auditoria_basado_en_08_eduardo.sql: bitácora simple; corresponde al archivo 08 original de Eduardo, adaptado para reconocer al usuario APEX.
5. 05_grafico_01_entradas_por_estado.sql: consulta del gráfico 1.
6. 06_grafico_02_recaudacion_diaria.sql: consulta del gráfico 2.
7. 07_grafico_03_asistencia_por_tipo.sql: consulta del gráfico 3.
8. 08_grafico_04_top_20_compradores.sql: consulta del gráfico 4.
9. 09_proceso_formulario_pagina_5.sql: bloque PL/SQL del proceso del formulario; pegar en Page Designer, no ejecutar en SQL Workshop.

Las tablas, los datos, PKG_ENTRADA y la bitácora ya fueron cargados por el usuario. No hay que volver a ejecutar 01 y 02 para editar los gráficos.
Los archivos 05 a 08 contienen SELECT: se usan como fuente de los gráficos, no crean nuevos objetos. Su numeración es propia de esta carpeta; no corresponde a los archivos 05 a 08 del directorio original sql.
La consulta mensual provisional fue sustituida por la diaria, que es la que terminó mostrando las fechas de venta.

## 2. La diferencia entre región y serie

En Page Designer, el árbol izquierdo tiene esta estructura:

    Gráfico 2                 <- región: título, consulta y tipo de gráfico
      Series
        Series 1              <- serie: origen de datos y columnas a representar

La forma de configuración que resolvió el problema del gráfico 2 fue:

1. Seleccionar el nombre del gráfico (la región) en el árbol izquierdo.
2. En el panel derecho, pestaña Region > Source:
   - Location: Local Database.
   - Type: SQL Query.
   - SQL Query: pegar el SELECT del archivo correspondiente, sin agregar punto y coma.
   - Order By: None, si aparece, porque las consultas ya tienen ORDER BY.
3. Seleccionar Series 1 debajo de ese mismo gráfico.
4. En Source > Location elegir Region Source. Esto indica que la serie usa la consulta de la región.
5. En Column Mapping seleccionar las columnas indicadas más abajo.
6. En la serie, dejar Order By = None, si aparece.
7. Save > Run.

Importante: el gráfico 1 también puede funcionar con su SQL directamente en Source de la serie (Local Database > SQL Query), como se configuró al comienzo. Si ya muestra los estados correctamente, no necesita cambiarse. Para reproducir todos con un mismo criterio, usar la configuración de región y Region Source descrita arriba.

Si la lista muestra NAME, EMAIL, JOB, DEPARTMENT y SALARY provenientes de Employees, la serie sigue en Sample Data. Cambiarla a Region Source para usar la consulta guardada en la región.
En el gráfico 2 DEPARTMENT y SALARY sí son válidos: los conservamos como alias de la consulta real; DEPARTMENT contiene la fecha y SALARY contiene la recaudación. El contenido es del negocio, aunque se hayan conservado esos nombres internos.

## 3. Títulos y nombres de serie

Los nombres siguientes son los acordados durante la configuración. Puede anteponerse 1., 2., 3. o 4. al título para numerarlos.

- Gráfico 1, título: Entradas por estado. Serie: Cantidad de entradas.
- Gráfico 2, título: Recaudación diaria de entradas (CLP). Serie: Recaudación por día.
- Gráfico 3, título: Asistencia por tipo de entrada. Serie: Entradas utilizadas.
- Gráfico 4, título: Top 20 compradores por importe en entradas (CLP). Serie: Importe por comprador.

Título visible: seleccionar la región > Region > Identification > Title.
Nombre interno de región: Region > Identification > Name; puede mantenerse Gráfico 1, Gráfico 2, etc.
Nombre fijo de la serie: seleccionar Series 1 > Identification > Name.
Column Mapping > Series Name se deja sin seleccionar: no es el campo para escribir el nombre fijo.

En la última captura general, el cuarto todavía tenía el título Top 5, aunque luego se pidió Top 20. El SQL guardado aquí usa FETCH FIRST 20 ROWS ONLY; actualizar también el título en APEX si aún dice Top 5. Para volver a cinco, cambiar 20 por 5 en la última línea.

## 4. Gráfico 1: entradas por estado

SQL: 05_grafico_01_entradas_por_estado.sql.

Column Mapping:
- Label: LABEL.
- Value: VALUE.
- Series Name: sin seleccionar.
- Value Aggregation: Sum, si aparece.

Tipo: Bar. Eje X: Estado de la entrada. Eje Y: Cantidad de entradas.
Formato: Decimal, 0 decimales; no usar moneda.

Cuenta el estado actual de cada ticket. En la captura había 50 UTILIZADAS, 1 VENDIDA, 1 DISPONIBLE y 1 ANULADA.
UTILIZADA significa que se compró y se usó para ingresar. VENDIDA significa que se compró y aún no se utilizó. Por tanto, había 51 compradas entre esos dos estados; no solamente una venta.

## 5. Gráfico 2: recaudación diaria

SQL: 06_grafico_02_recaudacion_diaria.sql.

Column Mapping:
- Label: DEPARTMENT (fecha de venta).
- Value: SALARY (importe en pesos).
- Series Name: sin seleccionar.
- Value Aggregation: Sum.

Suma TIPOS_ENTRADAS.valor para tickets VENDIDA o UTILIZADA y los agrupa por día de VENTAS_ENTRADAS.timestamp_venta.
La fecha corresponde a la compra, no al día del evento ni al momento de ingreso.
Se eligió agrupación diaria porque los datos de ejemplo se concentran en septiembre de 2026. Por mes aparecía solo 2026-09.

En las capturas quedó como Pie (torta); puede mantenerse para ver la participación de cada día en el total. Un círculo completo con un único mes no era un error: ese mes representaba el 100 % de los datos.
Para mostrar evolución temporal se recomendó Line. Esta modificación se hace en la región > Attributes > Chart > Type, cambiando Pie por Line.

Si queda Pie: no hay ejes X ni Y. En Attributes > Value:
- Format: Currency.
- Currency: CLP, no escribir Pesos Chilenos.
- Decimal Places: 0.
- Pattern: vacío.
- Format Scaling: None.
Los valores monetarios se pueden consultar al pasar el cursor por las porciones. Las proporciones siguen siendo parte de un total.

Si se cambia a Line: eje X = Fecha de venta; eje Y = Recaudación (CLP). Mostrar moneda CLP y 0 decimales en el formato de valores correspondiente.

## 6. Gráfico 3: asistencia por tipo de entrada

SQL: 07_grafico_03_asistencia_por_tipo.sql.

Column Mapping:
- Label: LABEL.
- Value: VALUE.
- Series Name: sin seleccionar.
- Value Aggregation: Sum, si aparece.

Tipo: Bar. Eje X: Tipo de entrada. Eje Y: Entradas utilizadas.
Formato: Decimal, 0 decimales; no usar moneda.
Solo cuenta tickets cuyo estado es UTILIZADA. En la captura: 38 generales y 12 solidarias, 50 utilizadas en total.

## 7. Gráfico 4: compradores por importe en entradas

SQL: 08_grafico_04_top_20_compradores.sql.

Column Mapping:
- Label: LABEL (correo del comprador).
- Value: VALUE (importe de sus entradas).
- Series Name: sin seleccionar.
- Value Aggregation: Sum, si aparece.

Suma el valor de las entradas VENDIDA o UTILIZADA de cada comprador. Ordena por importe descendente y correo para desempatar; devuelve como máximo 20 compradores.

En la captura estaba como Line. Para comparar compradores es más apropiado Bar: seleccionar región > Attributes > Chart > Type > Bar. Si existe Orientation, elegir Horizontal. Una altura de aproximadamente 650 píxeles ayuda a leer 20 correos.

Barras verticales: X = Comprador (correo); Y = Importe en entradas (CLP).
Barras horizontales: X = Importe en entradas (CLP); Y = Comprador (correo).
Formato monetario: Currency, CLP, 0 decimales, sin escalado si se desean importes completos.

## 8. Dónde están Attributes y Axes

Attributes: seleccionar la región del gráfico; arriba del panel derecho aparecen Region y Attributes. Si el encabezado dice Series, está seleccionada una serie, no la región.

Axes: en el árbol izquierdo, desplegar el gráfico > Axes > x o y. Los gráficos de barras o línea tienen ejes; Pie y Donut no los tienen.
Para nombrar un eje: seleccionar x o y y configurar su título (Title). En un gráfico de dinero, indicar CLP en el título del eje de importes.
Después de cambiar Pie a Line o Bar, guardar y revisar si aparecen los nodos de ejes. No buscar Axes mientras el gráfico siga siendo Pie.

## 9. Alcance de los datos y respaldo

Las consultas actuales reúnen todos los eventos: no tienen un filtro por ID_EVENTO. Los datos de ejemplo corresponden principalmente a la completada.
Los importes se calculan con el precio actual de TIPOS_ENTRADAS.valor: el modelo no conserva un precio histórico por ticket. No incluyen un ingreso adicional independiente por servicios.
Los SELECT de gráficos consultan datos existentes; no ejecutan el CRUD ni generan cambios de bitácora.

Esta carpeta guarda consultas e instrucciones, no es una exportación instalable de la aplicación APEX. Para respaldar también las páginas y su configuración, exportar la aplicación desde App Builder > Export / Import > Export.
El paquete y la bitácora fueron confirmados VALID por el usuario. Las capturas mostraron el dashboard y la bitácora funcionando. Después se conectó el formulario de la página 5 al paquete y el usuario confirmó crear, editar y eliminar la entrada de prueba. La bitácora mostró CREAR, ACTUALIZAR y BORRAR. Ver README_CRUD.md para configuración, límites y respaldo pendiente.
