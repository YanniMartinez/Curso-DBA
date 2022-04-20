# Tema 6 Parte 1 Administracion de las estructuras lógicas de almacenamiento



### Ejemplo

La siguiente instrucción obliga que el bloqe tenga almenos un 20% de espacio libre el cual podrá ser destinado a realizar actualizaciones a los registros existentes. 

`create table test(id number) pctfree 20;`

Si el valor no se reserva  muy probablemente existirá la posibilidad de migración de registros. Por default se registra un 10%

* OLAT: Son Bases de datos transaccionales.

* OLAP: Bases de datos que caen muy bien al ser estáticas. Normalmente son usadas para ananlítica.

Instrucciones que pueden incrementar el espacio libre:
* delete
* update (el nuevo dato es de menor longitud). Si ocurre lo contario, el registro pudiera requerir ser migrado a otro bloque
* Insert Hacen uso de compresión de datos.
    * Una instrucción insert podría hacer uso del espacio liberado por otra instrucción bajo las siguientes condiciones:
    * La instrucción que libera espacio se ejecuta primero y ambas instrucciones pertenecen a la misma transacción.
    * La instrucción que libera espacio se ejecuta primero, pertenece a una transacción diferente a la instrucción insert. En este caso la instrucción insert podrá hacer uso del espacio hasta haber realizado commit.

## Encadenamiento de registros

Si la table tiene demasiadas columnas usando tipos de datos `LONG ó LONG RAW`, hoy en día se usan **Clob** (Tipos de caracteres, por ejemplo, columnas donde el varchar no es suficientes, lo diferente al varchar y number es que son un apuntador) y **Blob** que permite almacenar documentos o imagenes.`

Realmente lo que se guarda en las columnas Clob o Blob es un puntero hacia el documento o imagen.

Antes de que existieran `clob y blob` existian los `LONG ó LONG RAW` no eran punteros, sino que almacenaba directamente en la columna todo este tipo de objectos.

Cuando almacenamos `blob y clob` generamos un segmento.

Lo que pasa es que el registro no se parte, sino que se lleva a un bloque nuevo donde quepa:

Una vez asignado el `rowid` ya no se mueve. El encadenamiento va a ocurrir cuando el registro tiene que partirse para que quepa.

Lo más común es que exista una migración sobre todo si tenemos un `pctfree` muy pequeño. si tenemos tablas muy pequeños podriamos tener el pctfree cercano a 0, en caso de que crezcan deberiamos aumentarlo para que no existan un gran numero de migraciones (mucha migracion puede afectar el performance).

## INDEX BLOCKS

Un indice requiere de almacenamiento. La unica diferencia es el contenido. Cada uno de los nodos que puede tener un indice ocupan un bloque. En un indice real el número de etiquetas puede ser considerablemente mayor. 
El indice de una llave primaria artificial podria ser el siguiente:

<div><img src ="profundidadIndice.png"/></div>

A diferencia de los datos de una tabla, los datos o “keys” de los índices se almacenan de forma ordenada en los Index blocks.
* La defragmentación de este tipo de bloques no es automática, se debe ejecutar `alter index <nombre_indice> rebuild o coalesce`.
* Esta operación permite que las hojas del árbol B se reduzcan.

Si son tablas muy grandes podemos tener el siguiente diseño:

<div><img src ="diseñoIndices.png"/></div>

Es decir, separar por completo el almacenamiento del contenido y del indice.

Nota: Aquí se termina el concepto de bloques. (examen P2 llega hasta segmentos)

## EXTENSIONES

Es un conjunto de bloques continuos.

Imaginemos 2 datafiles (el datafile contiene muchos bloques) y se agrupan en extensiones. Cada conjunto de bloques forman una extensión y estas a su vez se asocian a un segmento (dicho de otra forma a una tabla).

Podemos imaginar que las extensiones de color morado se refieren al `cliente` y las de color azul es `orden de cliente`

<div><img src ="extensiones.png"/></div>

Cuando se crea una tabla unicamente se crea su segmento (el cual tendrá el mismo nombre) el segmento está asociado a un Tablespace. Hasta este momento sólo se crean los metadatos.

<div><img src ="creacionPrimeratabla.png"/></div>

El primer insert es tardado porque aun no se reserva el espacio. Se solicita que se cree una nueva extensión. "Oye data file, necesito una nueva extension porque me están solicitando un insert". "El datafile reserva los bloques, genera la extension y le responde a la tabla, normalmente al crear una extensión tome tiempo porque reserva espacio"
Los futuros insert son más rápidos porque las extensiones van detectando cuando se está acabando el espacio y permite que sea más rápido. Cuando se acaba el espacio crea otra extensión en otro datafile.

Normalmente la base de datos genera extensiones conforme se van insertando datos, normalmente estas extensiones pueden tener extensiones de longitud variable en función del numero de inserciones que se haga en el sistema.

Si el tablespace que contiene al segmento está configurado como `locally managed` la BD realiza una consulta en el bitmap de algún data file para determinar si existen suficientes bloques contiguos para generar una nueva extensión. En caso de no existir, se revisa en otros data files. **En resumen** genera de forma automática la creación de extensiones.

El datafile está dividido en extensiones. Al liberarse una extensión el datafile también puede tener huecos por lo que podemos hacer un proceso de defragmentación para utilizar espacio libre y optimizar el valor en el datafile.

## Liberación de extensiones
Las extensiones se liberan para ser reutilizadas cuando ocurren eventos como los siguientes:
* Al ejecutar la sentencia drop sobre el objeto
* Al ejecutar la sentencia truncate sobre la tabla.
    La diferencia al drop es que sólo elimina registros, no la definición.

    * `truncate table cliente` (Vacia la tabla) es cuando estamos 100% seguros que no queremos esa tabla, es decir, que no podemos arrepentirnos, es **100% permanente.**
    * `delete from cliente;` También vacia la tabla, pero las extensiones se liberan con truncate para ser reutilizadas. Pero con **delete NO se liberan las extensiones**.

    * Una vez que las extensiones se liberan no hay vuelta atras, perdemos completamente los datos. El **Delete** es más lenta porque hace `redo` o `redo records` para poder hacer **rollback** y restaurar. En resumen, delete no libera espacio.

* Notar que al eliminar todos los registros de una tabla con la instrucción delete, las extensiones no son liberadas.

* Es posible liberar extensiones de forma manual. Existe un advisor (segment advisor) que permite conocer o detectar los objetos que tienen espacio suficiente para ser recuperado basado entre otras cosas, en el nivel de fragmentación.

* Es posible invocar una operación de defragmentación de un segmento. Esto permite adicional a la recuperación de espacio, contar con tablas con datos contiguos, mejorando así las lecturas en especial para operaciones de escaneo completo: table Access full.

## Segmentos
Conjunto de extensiones que contienen todos los datos de un objeto ubicado dentro de un tablespace. Dependiendo el tipo de objeto, los segmentos se
clasifican en:
* User segments
* Temporary segments
* Undo segments.

Los objetos que normalmente usan segmentos son:
* Tablas, tablas particionadas, cluster de tablas.
* Particiones LOB
* Índices, índices particionados.


**Ejemplo1:**
¿Cuantos segmentos se crean en la siguiente table?

<div><img src="ejemploSegmento1.png"/></div>

Se crearan en total 2 segmentos, 1 para los datos de la tabla donde se involucra la tabla.
El segundo segmento se asocia al indice del id de la tabla.

**Ejemplo2:**

```
create table empleado_foto(
empleado_id number constraint empleado_foto_fk primary key,
foto blob
);
```

<div><img src="ejemploSegmento2.png"/></div>

Sólo para las columnas `clob y blob` generan un propio segmento por columna y aparte su propio indice.


---------------
**Tablas particionadas**

Tablas particionadas:
<div><img src="tablasParticionadas.png"/></div>

Se pueden generar más segmentos si existe una tabla particionada.

<div><img src="segmentosSeparados.png"/></div>

El tener particionado los segmentos es tener lecturas o escrituras paralelas.

---------------

Forma de recordar que es un segmento:

Cuando tenemos n productos en el carrito normalmente separamos cada cosa en bolsa, por ejemplo:

* Cocina
* Jabon
* Carne
* Botanas

Cada uno tiene su espacio independiente, imaginemos que cada bolsa es un tablespace o discos.

<div><img src="ejemploSegmentoDibujo.png"/></div>

Permite un paralelismo al tener separado por bloques, busquedas eficientes, etc.

Preferentemente usar un este tipo de organización en el proyecto.

**Que genera un segmento?**
La tabla en si, ella generará n segmentos dependiendo de lo que almacene.

El nombre del segmento coincide con el nombre del objeto.

Este tipo de segmentos se conocen como **Permanentes**

## Segmentos temporales.

Es como el **SWAP** de un SO Linux.

El SWAP actua como una memoria RAM, interviene cuando la RAM del dispositivo está ocupada completamente.Cuando ocurre este caso los datos de la RAM los baja temporalmnete a disco para que una nueva tarea ocupe el espacio en RAM y sea eficiente.

* Cuando una sentencia SQL se ejecuta, la BD puede requerir de cierto espacio para `almacenar temporalmente el resultado` de cada una de las fases o etapas del procesamiento.

* Operaciones típicas que requieren de este espacio son ordenamiento, construcción de tablas hash, etc. Cuando un índice se crea, sus segmentos se almacenan como temporales durante el proceso de creación y al concluir se vuelven permanentes.

* Si una operación se puede realizar en memoria, no se hace uso de segmentos temporales. Solo las operaciones que no pueden realizarse en memoria hacen uso de este tipo de segmentos.

* A traves de tablas temporales. Otro uso de este tipo de segmentos son las tablas temporales y sus índices. Debido a que estos datos desaparecen al terminar la sesión, se prefiere utilizar segmentos temporales. Las extensiones de estos segmentos solo pueden ser accedidas por la sesión (usuario) que los genera.

* Debido a su frecuente uso, se considera buena práctica crear un tablespace dedicado para almacenar segmentos temporales al momento de crear la base de datos (tal cual como se realizó en el tema 2).

* A cada usuario se le asocia un tablespace temporal, el mismo tablespace puede ser empleado por múltiples usuarios.

## Segmentod UNDO
