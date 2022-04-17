# Administración de las estructuras de memoria

Lo clasico es tener una base de datos en una instancia, pero la otra es la multitenant

Cliente: El SQLPlus es un cliente que hace conexión directa al server, otro ejemplo es el SQL Developer.

El cliente usará un User proces (Si hay un listener le manda la posición al listener, en caso contrario lo manda directo).

Una conexión es la unión entre User process y Server process. A esto se le conoce como **sesión** y esto a su ves se le conoce como la PGA.

PGA: Es una área de memoria privada.
SGA: Es el área de memoria compartida.

User process pasa por el Listener, el listener se encarga de hacer conexión con el Server process y genera una conexión directa, por lo que el listener deja de ser necesario.

Server process, es un proceso de background asignado a un usuario que atiende sus peticiones.

Mostrar la información de la instancia

```
select instance_number, instance_name, host_name, version, status, database_status,
active_state, startup_time,database_type
from v$instance;
```


El archivo para hacer el mapeo es `/etc/hosts`, permite hacer el mapeo, a partir del nombre toma el dominio, y mapea a la dirección IP configurada.

127.0.0.1 representa  la propia maquina, es decir, un localhost, es una conexión a si misma.

## Arquitectura de las estructuras de memoria

Cuando creamos la instancia se crean las instancias de memoria y procesos de background.

Todas las sesiones de los usuarios se guardan en la memoria, cada sentencia SQL (A cada una se le asigna su ID, el uso de Caché).

SGA: System Global Area
PGA: Program Global Area (Esta es privada)
UGA: User Global Area.

A cada server proces se le asigna su PGA, una vez asignada el Server Proces es asignado a una SGA para realizar diversos procesos.

## SGA System Global Area
Es un conjunto de áreas de memoria que son compartidas para su eficiencia.
Las principales estructuras son:

* Shared pool
* Database Buffer cache
* Redo Log Buffer
* Java pool
* 

El parametro para la SGA es el `memory_target` y le dirá a la SGA cuanto de memoria cuenta.

Al ejecutar el comando `startup` nos regresa el número de memoria.

MB=Bytes/(1024*1024)

### Ejercicio en clase


## Database Buffer Caché
Se le conoce también como Buffer Caché, su objetivo es almacenar el caché en loques de datos leidos de los datafiles.

para ver el valor de cada buffer podemos usar el siguiente comando:
`show parameter db_block_size`

Es empleado para optimizar operaciones I/O
    Si se quiere hacer un select va directo primero al caché y despues se va hacia el data file, esto ayuda a disminuir el tiempo.
    Los cambios generados por operaciones DML (insert, update, delete) se aplican en los bufferlogs.

Los datos en el db_buffer caché se matienen el mayor tiempo posible para minimizar operaciones.

## Lecturas lógicas y lecturas Físicas.

* Lectura Lógica: Caché Hit, va y leelos valores al caché
* Lectura Física: Caché miss, va y lee directamente al dispositivo físico

## Estados de un Buffer
* Unused: El buffer está vacio y nunca ha sido usado.
* Clean: El buffer se puede usar, pero en un tiempo pasado ya se usó y puede contener datos sin modificar o datos que fueron modificados pero ya fueron sincronizados con datafiles.
    Tras actualizar el valor en el data file, esta seccion de memoria pasa a clean y puede aceptar un nuevo valor.
* Dirty: El buffer tiene cambios pero no se han sincronizado con los datafiles.

Siempre se leen y cargan bloques completos de los buffers.

Si tenemos datos en estado Dirty y cierra la base de datos pueden ocurrir 2 cosas, perder todo o respaldar las transacciones. Transacciones no confirmadas al fallar se hace un rollback, transacciones guardadas se guardan en redologs.

Toda transacción DDL corta una transacción que no fue cerrada y genera un commit implicito. Una transacción DDL tiene un commit implicito porque puede fallar hasta cierto punto.

¿En que estatus debe estar un buffer para ser reutilizado? **Clean**

## Buffer Pools

Son diferentes versiones de pools con funcionalidad especifica

* Default pool: Es el que fue generado por default.
* Keep pool: Contiene bloques de datos accedidos frecuentemente
* Recicle pool: Contiene datos que no son accedidos frecuentemente
* nk pool: Donde n es el tamaño del bloque.
* Smart Flash Cache: Uso de memoria flash y una velocidad considerablemente mayor. 

## Reemplazo de buffers en el caché

* LRU (Last Recent used): Contiene punteros a los buffers sucios y limpios. Si tiene muchos buffers sucios decide sincronizar, pero antes de ello da un vistazo a los clean usados con menor frecuencia.

    El riesgo es que libere buffers que podrian llegar a usarse. es por ello que llega y usa la memoria flash y tranfiere los datos para que no pierda por completo y deba realizar consulta física. Sólo tranfiere el Body, pero deja el header para que guarde la referencia.

    `db_flash_cache_file`
    `db_flash_cache_size`

* Temperature-based, object-level replacement algorithm: Este algoritmo 
    Cuando queremos traer toda la información de una tabla se le considera como *Table access full*, el dba_cache no tiene los recursos suficientes a menos que tengamos memorias suficientes.

    La BD puede cargar un porcentaje en el caché. es decir selecciona los "Más populares" (Hotter tables) o más usados son los que leerá para no tener que cargar tablas completas.

    Otra tecnica es usar el Direct Path Read. Podemos saltarnos el caché y guardamos la información en la PGA del usuario.


## Proceso de escritura de buffers con statys dirty
Ente más bloques con estatus dirty cada vez tardará en sincronizar los datos.

DBWriter es el encargado de escribir y sincronizar, se lanza cuando se detectan muchos registros de buffer sucios.

## Modos de acceso (Modos de hacer lectura)
Cuando un usuario solicita un dato, la instancia

* Current mode
* Consistent mode

**ACID** = Atomicidad, consistencia, Aislamiento, Dominancia.

Niveles de aislamiento:
* Lecturas confirmadas
* Lecturas 
* Lecturas 

Si hay 2 lecturas en diferentes usuarios y se modifican valores, 1 lee el current file y el otro una consistente (es decir, uno que no ha sido empleado)
* Current mode: Es el usuario que está dentro de la transacción
* Y los consistent es por usuarios que están fuera de la transacción.

En una transacción no se permite que 2 usuarios puedan cambiar al simultaneo, esto bloquea el otro usuario para que la consistencia es muy importante.

En una transacción solo puede haber una modificación a la vez.

## Redo Log Buffer

Re do= significa rehacer
* **Redo Record**: Contiene datos necesarios para poder reconstruir un cambio realizado por sentencias DML.

Todos los cambios se guardan en el DB Buffer caché y aparte se guarda en el Redo Record para evitar incidentes frente a fallas. 

    Cuando se hace commit no se hace de forma inmediata al DataFile, sino a los RedoLogs.

A partir del Redo Record es una operación mucho más rápida a comparación del DataFile. Si escribimos en el RedoRecord podemos garantizar que tengamos un respaldo y no perdamos información.

En resumen acumula Redorecords y toma todos los RedoRecords para enviar por bonches y escrie en los Online Redo Logs. (Los Online Redo logs permiten asegurar la información para la BD)

Una vez que se realiza el commit es uno de los eventos que el LogWriter (LGWR) escriba. El commit está condicionado a que se guerden los datos en los Online Redo Logs. (Estos son los 3 que creamos y asignamos a diferentes discos, esto permite una mayor redundancia  y aseguramos que los datos sean recuperados ante una falla).

El Redo Log Buffer tarda 3 segundos, se guarda el Redo Log Buffer o el commit, segun el que ocurra primero.

El cambio se queda en el caché y hace que el usuario tenga un resultado más eficiente.

Cuando Usamos Shutdown hará que todos los dirtybuffers se sincronicen completamente.

Una vez que los Redo Records son copiados al **redo log buffer** ...

Cuando un usuario manda una sentencia se guarda en su PGA

* **Sentencia preparada**: son sentencias que son preparadas y permiten reutilizar. 
    ```Query = "insert into orden_compra (order_compra_id, fecha, cliente_id, importe)";
    query+"values("+v_id+"v_fecha+","+v_cliente_id+","+v_importe+")"```

    Esto genera muchos problemas son generados como la velocidad y eficiencia. Sin embargo al final también es un problema fuerte de seguridad.

La ventaja es usar SQL paramatrizadas o preparadas:
Java
```
query "insert into orden_compra(orden_compra_id, fecha, cliente_id, importe) values(?,?,?,?)";
```
Con esta manera podemos evitar las vulnerabilidades, por ejemplo en SQL puede ser así:

```
query "insert into orden_compra(orden_compra_id, fecha, cliente_id, importe) values(:ph1,:ph2,:ph3,:ph4)";
```

## Server Result Cache
Aqui se guarda un resultado en forma tabular el resultado.

## Reserved pool
Area de memoria empleada para asignar cantidades grandes que no son contiguas.


## Large Pool
Es para programas en los que se necesitan cantidades de memoria contiguas, aparte el large pool es como el que ayuda para aumentar capacidad de memoria y auxilia al shared pool

## Java pool
Es la cantidad de memoria para ejecutar programas en Java, es decir, lo que permite es tener programas dentro de la misma base de datos para poder emplear clases. Por default tiene poquitas memorias.

## Streams Pool
Su uso es para compartir información entre base de datos, a esto se le conoce como flujo de datos.

Hasta este punto todas estas memorias han sido dinámicas.

## Fixed area
Tiene un valor fijo de memoria.

## In-Memory Area
Lo que hace es hacer consultas en forma de columnas y no de forma común como lo es por renglón.

# PGA (Program Global Area) es privada

* Region de memoria que contiene datos e informacion de control de un solo server process. Es decir, por cada usuario se genera un PGA.

Procesos de Background: Logwriter (Escribe redologs) y dbwriter (sincroniza dirtynodes en los redoonline)

El area total es la suma de todas las PGAs más la suma de las SGA.

Areas que la componen:

* SQL Work Areas: Se encarga del ordenamiento, también el uso de Hash por ejemplo Hash para tablas que son grandes que manejan n recursos.
* User Global Area(UGA): Es el área de memoria donde se guardan las sesiones de los usuarios. Es como una mini SGA pero a nivel usuario.
* Private SQL Area: Guarda en caché las instrucciones que ejecuta el usuario en especifico

Los indices son los que se encargan de hacer más efectivas las busquedas y los ordenamientos.


## Vistas del diccionario de datos asociadas con las áreas de memoria

### v$sga

### v$

### v$sgastat

### v$sgainfo

### v$pgastat
Aquí podria ser un valor muy interesante el uso de los parametros: `maximum PGA allocated`, `aggregate PGA target parameter`, `Process count`, `cache hit percentage`

Para la cantidad de usuarios es tan grande no es posible asignar PGA a cada usuario.

`cache hit percentage` si diera un 100% significaria que las sentencias están bien hechas y no son hardcordeada.

## Administración de las áreas de memoria

Las PGA y la SGA pueden ser organizadas de forma automática o manual.

### Organización automática de la memoria

Para saber que una base de datos se administra sola debemos identificar los comandos `memory_target` y adicionalmente tenemos `memory_max_target` pero no es mandatorio. Con esto podemos darnos cuenta que la administración de la BD es automática.

Tipicamente en una base productiva se tiene 80% a 20% siendo 20% la PGA y 80 la SGA.

## Habilitar la administración automática

Con el memory target tenemos más que suficiente, basta con poner mayor que cero y todos los demás parametros en 0

## Habilitar administración semi-manual
Se requiere configurar más parametros.