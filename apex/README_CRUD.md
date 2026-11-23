# CRUD y bitácora de entradas — BarrioTickera

Guía de lo configurado y probado durante esta conversación. Aplicación APEX 140232, esquema WKSP_BARRIOTICKETERA.
Esta carpeta contiene las adaptaciones para APEX; los archivos originales de Eduardo permanecen en ../sql.

## 1. Qué hace cada página

- Página 2: Dashboard BarrioTickera. Contiene los cuatro gráficos; ver README.md y las consultas 05 a 08.
- Página 3 — Entradas: Interactive Report, modo Normal. Lista y permite buscar entradas. Tiene el enlace Editar por fila y el botón Crear entrada.
- Página 5 — Entrada: Form, modo Modal Dialog. Se abre desde el listado para crear, actualizar o eliminar una entrada.
- Página 6 — Bitácora / Auditoría de entradas: Interactive Report, modo Normal, sobre BITACORA_ENTRADAS; sin formulario para editarla.

El formulario terminó en la página 5, no en la 4. Por eso sus campos empiezan con P5_. No hay que renumerar la página ni sustituirlos por P4_.

## 2. Base y archivos utilizados

1. 01_creacion_esquema_barrioticketera.sql: crea las tablas y sus estados iniciales.
2. 02_poblado_datos_barrioticketera.sql: carga el ejemplo de la completada.
3. 03_pkg_entradas.sql: paquete CRUD de Eduardo, adaptado quitando los cambios de contenedor/esquema del Docker.
4. 04_bitacora_auditoria_basado_en_08_eduardo.sql: versión APEX del archivo 08 original. Conserva BITACORA_ENTRADAS y TRG_BITACORA_ENTRADAS.
5. 09_proceso_formulario_pagina_5.sql: código del proceso de la página 5. Se pega en Page Designer, no se ejecuta en SQL Workshop.

No hay que volver a ejecutar el poblado ni crear las tablas para cambiar páginas, botones o títulos. Los SELECT de los gráficos son fuentes de consulta y no se cargan como nuevos objetos.

## 3. Cómo quedó el reporte de la página 3

Se creó con Create Page > Interactive Report:
- Nombre: Entradas.
- Page Mode: Normal (se corrigió porque inicialmente quedó Modal Dialog).
- Data Source: Local Database.
- Source Type: Table.
- Owner: WKSP_BARRIOTICKETERA.
- Table: ENTRADAS.
- Use Navigation: activado, con una entrada nueva en el menú.

Al crear el reporte no quedó incluido el formulario. Se agregó después como una página independiente. El resultado es la misma combinación reporte + formulario modal que enseña la guía.

### Enlace Editar por cada fila

Seleccionar la región Entradas en el árbol izquierdo, no el nodo Page 3. En Attributes > Link:
- Link Column: Link to Custom Target.
- Target > Type: Page in this application.
- Page: 5.
- Set Items > Name: P5_ID_ENTRADA.
- Set Items > Value: #ID_ENTRADA#.
- Clear Cache: 5.
- Action: None.
- Link Icon: Editar (texto sencillo, como quedó visible en las capturas).

#ID_ENTRADA# es la sustitución de APEX para obtener el ID de la fila pulsada. Se pasa al campo oculto P5_ID_ENTRADA para cargarla en el formulario.
Clear Cache = 5 limpia el estado anterior de los campos de la página 5; no borra filas de la base de datos.

### Botón Crear entrada

En el árbol izquierdo, clic derecho sobre la región Entradas > Create Button:
- Button Name: CREATE.
- Label: Crear entrada (en la captura aparece crear entrada).
- Region: Entradas.
- Slot: Right of Interactive Report Search Bar.
- Behavior > Action: Redirect to Page in this Application.
- Target > Page: 5.
- Target > Clear Cache: 5.
- Target > Set Items: Name y Value vacíos.
- Target > Action: None.

Crear abre el formulario sin ID; Editar lo abre con el ID de la fila. Ninguno de esos enlaces modifica datos por el solo hecho de abrirlo.

## 4. Cómo quedó el formulario de la página 5

Create Page > Form:
- Name: Entrada.
- Page Mode: Modal Dialog.
- Data Source: Local Database > Table > ENTRADAS.
- Primary Key Column 1: ID_ENTRADA.
- Primary Key Column 2: sin seleccionar.
- Use Navigation: desactivado; se abre desde la página 3.

Campos generados:
- P5_ID_ENTRADA: oculto, clave primaria.
- P5_UBICACION.
- P5_QR.
- P5_TIMESTAMP_CANJE.
- P5_ID_TIPO_ENTRADA.
- P5_ID_EVENTO.
- P5_ID_VENTA_ENTRADA.
- P5_ID_ESTADO_ENTRADA.

APEX generó listas para las relaciones. En las capturas se eligieron ENTRADA GENERAL, la completada y DISPONIBLE por su nombre. Los rótulos iniciales como Id Tipo Entrada son los generados por APEX.
El ID de la entrada se genera automáticamente. Id Venta Entrada es una referencia a una venta existente, no un número a elegir para la nueva entrada. Para crear una entrada disponible sin venta, esa lista debe quedar vacía.
Timestamp Canje corresponde al uso de la entrada al ingresar. Se dejó vacío durante la prueba de creación.

## 5. Conexión con el paquete de Eduardo

Inicialmente el asistente generó guardado automático contra la tabla. Se adaptó el proceso para llamar al paquete original, manteniendo la región de formulario y su carga de datos.

Ruta en la página 5:
1. Abrir Processing: tercer icono del árbol izquierdo, las dos flechas junto al rayo.
2. Processing > Processes > Process form Entrada.
3. Type: Form - Automatic Row Processing (DML).
4. Form Region: Entrada.
5. Target > Target Type: PL/SQL Code.
6. Pegar el bloque BEGIN ... END; del archivo 09_proceso_formulario_pagina_5.sql.
7. Save.

No crear un segundo proceso de guardado que duplique las operaciones. El archivo 09 pertenece a ese proceso, no a SQL Commands.

El bloque usa :APEX$ROW_STATUS para elegir la operación:
- C: pkg_entrada.crear_entrada; devuelve el nuevo ID a P5_ID_ENTRADA.
- U: pkg_entrada.actualizar_entrada.
- D: pkg_entrada.eliminar_entrada, con el ID de la entrada abierta.

Mantener Close Dialog después del proceso. Ese proceso cierra el modal cuando termina correctamente. El bloque no agrega COMMIT manual.
Guardar código en Page Designer guarda la configuración. Las operaciones sobre datos suceden al enviar el formulario con Create, Apply Changes o Delete.

La lectura del reporte y la inicialización del formulario siguen a cargo de APEX. En esta configuración no se llaman listar_entradas ni obtener_entrada; se reutilizan los procedimientos de escritura del paquete.

### Alcance del paquete original

El paquete valida QR obligatorio, QR único, referencias existentes y restricciones al eliminar entradas con registros asociados.
El paquete original no recibe TIMESTAMP_CANJE ni lo actualiza. Por tanto, ese campo no debe presentarse como una modificación soportada por este CRUD. Queda documentado que debe dejarse de solo consulta; no se confirmó ese ajuste visual en la sesión.
Las listas no sustituyen una validación que garantice que el tipo de entrada pertenece al evento elegido. Esa validación adicional no se implementó durante los pasos registrados.

## 6. Qué pruebas se hicieron

Se creó una entrada nueva sin tocar las originales:
- Ubicación: PRUEBA APEX.
- QR: QR-PRUEBA-APEX-001.
- Tipo: ENTRADA GENERAL.
- Evento: COMPLETADA PRO GATOS CALLEJEROS.
- Estado: DISPONIBLE.
- Canje y venta: vacíos.

La captura confirmó que apareció en el listado. El usuario confirmó la edición y posteriormente la eliminación de esa entrada de prueba con el botón Delete del formulario. No hizo falta crear otro botón de eliminación.
En la página de bitácora aparecieron tres operaciones: CREAR, ACTUALIZAR y BORRAR, con el usuario APEX.

El campo ID_ENTRADA no se veía en el listado porque estaba oculto; una columna de venta vacía no significaba que faltara la clave primaria de la entrada.

Para consultar una futura prueba, sin modificar datos:

~~~sql
SELECT id_entrada, ubicacion, qr, id_venta_entrada
FROM entradas
WHERE qr = 'QR-PRUEBA-APEX-001';
~~~

Como la entrada de prueba fue eliminada, esa consulta ya no debería devolverla. En nuevas pruebas usar un QR distinto si existe uno con ese código.

## 7. Bitácora / Auditoría de entradas, página 6

El archivo 04 conserva la idea simple de Eduardo:
- Tabla BITACORA_ENTRADAS: ID_BITACORA, OPERACION, USUARIO y FECHA.
- Trigger TRG_BITACORA_ENTRADAS: AFTER INSERT OR UPDATE OR DELETE ON ENTRADAS, a nivel de sentencia.
- Operaciones: CREAR, ACTUALIZAR, BORRAR.
- Usuario: COALESCE(SYS_CONTEXT('APEX$SESSION', 'APP_USER'), USER).
- Fecha: SYSTIMESTAMP.

El trigger inserta automáticamente en la misma transacción que el cambio. No hay que rellenar la bitácora a mano. Una operación que se revierte no conserva su anotación.
Al ser un trigger de sentencia, genera una anotación por instrucción SQL, no una por cada entrada afectada. No almacena el ID de la entrada ni sus valores anteriores/nuevos. Es la versión simple elegida por el usuario, con menos detalle que la auditoría de fila ilustrada en la guía del profesor.
No se instaló la tabla AUD_ENTRADAS provisional; ese archivo fue descartado y eliminado de esta carpeta.

### Crear la página del historial

Create Page > Interactive Report:
- Nombre: Bitácora / Auditoría de entradas.
- Número que quedó asignado: 6.
- Page Mode: Normal.
- Include Form Page: desactivado.
- Data Source: Local Database > Table > BITACORA_ENTRADAS.
- Use Navigation: activado > Create a new entry.
- Parent Navigation Menu Entry: sin padre.
- Icon: fa-table.
- Use Breadcrumb: activado en la configuración mostrada.

Es un reporte para consultar, no un formulario para editar el historial.

### Mostrar fecha y hora

1. En el árbol izquierdo de la página 6, desplegar la región Bitácora / Auditoría de entradas.
2. Pulsar la flechita de Columns para desplegar sus campos. Seleccionar solo la palabra Columns no abre las propiedades de una columna.
3. Seleccionar FECHA.
4. En el panel derecho buscar Format Mask y escribir directamente:

~~~text
DD/MM/YYYY HH24:MI:SS
~~~

5. Save > Run.

Si se abre Pick Format Mask, se puede cerrar y escribir el formato en el campo original. El buscador de esa ventana filtra ejemplos; no es el lugar donde guardar el formato personalizado.
La máscara cambia la presentación, no convierte la zona horaria. FECHA es TIMESTAMP, sin información de zona horaria almacenada.

## 8. Uso para la presentación

1. Mostrar los cuatro gráficos y explicar sus preguntas de negocio.
2. Abrir Entradas y buscar un registro.
3. Crear una entrada de demostración con QR único.
4. Editar solo esa entrada y guardar con Apply Changes.
5. Eliminar solo esa entrada con Delete.
6. Abrir Bitácora / Auditoría de entradas y mostrar las nuevas anotaciones con el usuario, fecha y hora.

Si el listado no refleja de inmediato un cambio al cerrar el modal, actualizar la página. El refresco automático mediante Dynamic Action Dialog Closed > Refresh de la región es el ajuste que propone la guía Tienda; no se confirmó su configuración durante esta sesión.

## 9. Respaldar la aplicación

App Builder > Application 140232 > Export / Import > Export.
Guardar el SQL exportado dentro de una carpeta de respaldo junto con estos scripts. La exportación de la aplicación guarda páginas, enlaces, procesos y configuración; los scripts de tablas/datos/paquete/trigger se conservan aparte para reconstruir la base.
No se observó todavía la descarga del export de la aplicación. Los archivos 01 a 09 y este README no sustituyen ese export.
Los gráficos tienen imágenes guardadas como grafico1.jpg, grafico2.jpg, grafico3.jpg y grafico4.jpg.
