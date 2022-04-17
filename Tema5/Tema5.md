

A linea de comandos podemos consultar los procesos que están siendo ejecutados con los comandos:

* `top`

* `ps -ef | grep oracle`: Mostrará sólo los procesos que estan siendo ejecutados con oracle. (Normalmente en este caso veremos los procesos de la instancia que inciamos)
        dbw0 Es el famoso DBwriter. Es el que se encarga de sincronizar los datafiles a los registros.

        lgwr Famoso logger writes. Se encarga del redo buffer a los redologs.

En la lista de resultados podemos encontrar que el segundo valor es el **ID del padre**.

## Matando un proceso
Para matar un proceso usamos el comando `kill -9 32086`. (-9 es la prioridad más alta) en este caso fue el id del proceso del SQLDeveloper.
Cuando ejecutamos `kill -9 31157` es decir el dbwriter de la instancia vemos que la matamos totalmente (Como es un proceso obligatorio si se muere, entonces se muere la instancia).

## Arquitectura de procesos

Procesos de base de datos:
    Un **server process** es llamado por el cliente (Nace en la peticion del usuario)
        Dedicated Server Process: Son procesos dedicados para el usuario.

        Shared server process: Se comparten con el usuario.

    Un proceso de background es llamado por el servidor (Se crean junto con la instancia)

Demonios (Daemons)/Application processes: Estos procesos no se asocian a una unica instancia, sino que pueden ser compartidas por varias instancias dentro de un servidor. Un ejemplo puede ser el **Listener**. 
    Si ambas instancias se levantan entonces apuntarán al mismo listener.

## Procesos compartidos y dedicados

Los **Dedicated server process** son dedicados a cada usuario. Cuando un usuario quiere conectarse a un proceso remoto entonces le dice al listener y este solicita un server process para que se genere la conexión directa. Una vez que se le asigna el server process el listener ya no importa. `Si el listener muere despues de una conexión directa entonces no afecta en nada la comunicación porque ya se estableció`.

    La PGA (Pedacitos de RAM) se le asigna al crear un Server Process, esto implica gastar muchos recursos RAM y generar más gastos.

    Si no tenemos problemas de recursos es la mejor opción.

Los **Shared Server Process** puede ser representado por un restaurante, donde cada mesero puede atender n mesas. Si nuestra RAM no es suficiente o tenemos muchos usuarios es cuando se opta por esta arquitectura para reutilizar procesos. Todas las peticiones llegan a un componente llamado **Dispacher Processes**, es el que atiende y asigna la mesa. Su unico objetivo es recibir todas las peticiones aun cuando sean muchas y las pone en cola en caso de ser necesario.

Un server process atiende otras peticiones cuando una acción no lo requiera.

La ventaja de esta arquitectura es la capacidad de atender muchas peticiones aun cuando se tiene un espacio relativamente pequeño.

La desventaja es el tiempo de espera para ser atendido. sin embargo no recibimos un error de que no hay recursos para atender.

A cada petición se le asigna parte de la memoria compartida llamada **virtual Circuit** (pequeñisima area de memoria asignada a las peticiones es como nuestra comanda en los restaurantes).

## ¿Cuando seria conveniente cambiar la arquitectura entre el dedicado y el compartido?

En función del número de usuarios o peticiones.

La ventaja de esta base de datos es que permite habilitar un modo compartido sin tener que reiniciar la instancia.

Para decir que nos conviene el modo dedicado deberia cumplir algo como esto: 
    Que todo el tiempo esten activas o trabajando.

    Si tenemos problemas de recursos.

    Cuando requerimos una escalabilidad aun cuando cueste un poco de tiempo de respuesta.

Listado de actividades Dedicadas y compartidas:


## Configuración del modo compartido




## Configuracion del listener y tnsnames.ora en modo compartido

`alter system register` Hace que un proceso de background despierte y este proceso se llama LREG. Y le dice al listener "Quiero avisarte que esta instancia habilitó el modo compartido, porfavor activalo en tu lista de servicios".

`lsnrctl services`: Nos mostrará la lista de servicios a los que nos podemos conectar. (Aquí veremos cuando esté en modo compartido, tras configurar ciertos parametros).

Otra manera de verificar que el modo compartido está habilitado, es hacer la siguiente consulta:

```
select program, pid, pname
from v$process
where pname like'S0%'
or pname like 'D0%'
order by program;
```

Todos los que comienzan con D son dispachers y los que empiezan con S son los share servers. 
s=meseros
D=Señor de la entrada

Para el caso del archivo tnsnames.ora, existe un parámetro `(SERVER=DEDICATED)` y `(SERVER=SHARED)`


Resumen sobre pasos del modo compartido.
1. Modificar parametros
2. Agregar alias de servicio por ejemplo `JRCBDA2_DE`
3. En el alias agregar un parametro agregar un parametro `Shared`

v$dispacher: Nos dice cuantos mensajes se han atendido, nos puede dar la idea de cuantas peticiones se están aceptando y la memoria.

`v$dispacher_config`:Muestra que configuración tienen. El nombre del servicio al que apunta, su listener y más.

`$queue`:Cuando llegan las peticiones llegan a una cola, esta vista nos dice cuanto tiempo han estado en la cola. (Si wait tiene un valor mayor a 0 significa que han estado mucho tiempo en espera). Si detectaramos esto, tendriamos que agilizar le servicio habilitando más share servers (incrementarlos un poco).

`v$shared_server`: Si vemos que todo el tiempo los shared server están siempre ocupados significa que tenemos muchas peticiones y muy poquitos shared servers. La columna **messages** si vemos que sólo uno tiene valores y los demás están en 0s. Lo ideal es que veamos que la carga está distribuida. (Es el número de peticiones que ha antendio desde que se inició). por lo tanto si hay muchos ceros significa que estan sobrando algunos shared servers.

`v$circuit`: Son las comandas, esto significa que hay n usuarios que actualmente están conectados en modo compartido.

**FIN MODO DEDICADO**

## Procesos Background
* Los procesos de background inician junto con la instancia de base de datos.

Los procesos obligatorios son:
* Process Monitor (PMON)
* Process Manager (PMAN)
* System Monitor (SMON)
* Listener Registration (LREG)
* Database Writer (DBWn)
* Log Writer (LGWR)
* Checkpoint (CKPT)
* Manageability Monitor (MMON)
* Manageability Monitor Lite (MMNL)
* Recoverer (RECO)

Dentro de los procesos de background opcionales más comunes se encuentran:

* Archiver Processes (ARCn)
* Job Queue Processes (CJQ0 y Jnnn)
* Flashback Data Archive (FBDA)
* Space Management Coordinator (SMCO)
* dispatcher process (Dnnn)

## PMON: Process Monitor
PMON se apoya de procesos adicionales. 

Acciones importantes:
* Se encarga de la recuperación cuando falla un user process.
    Limpia el database buffer cache
    Libera recursos que fueron utilizados por el proceso de usuario que falló o terminó.
        Libera bloqueos que no son necesarios
        Elimina el id del proceso de la lista de procesos activos
    Basicamente se encarga de hacer la recolección de todo lo que no se está utilizando.

    Si un dispacher y server process ha detenido su ejecución , PMON los reinicia (Salvo los procesos fundamentales).

Realiza de forma periodica la limpieza de:
* Procesos terminados
* Sesiones terminadas
* Transacciones
* Conexiones de red
* Sesiones inactivas
* Transacciones desconectadas
* Conexiones de red desconectadas que ha excedido su tiempo inactivo

## CLnn Cleanup Helper Processes

CLMM delega algunos procesos.

`v$cleanup_process`: proporciona información de los procesos PMON.

```
select name,state,dead_in_cleanup, cleanup_time,time_since_last_cleanup, num_cleaned
from v$cleanup_process
```

* Para sacar un usuario de la base de datos se usa `alter system kill session '74,18605,@1' ` @1 es el id de la instancia. Resumen del comando `<sid>,<serial#>,@<inst_id>`


## PMAN Process Manager
Supervisa, genera y detiene los siguientes tipos de procesos:

* Dispacher y Shared Server
* Connection broker y server process agrupados en pools de conexiones residentes de la base de datos

En resumen se enfoca más en los procesos compartidos.
Los `job queue processes` son tareas programadas que realizarán tareas constantes, cada que se dispare la tarea entonces comienza a realizar acciones.


## SMON System Monitor

Es un proceso encargado de hacer monitoreo en el sistema basado en:

* Es el sistema encargado de hacer el recovery. realizar la recuperacion de la instancia durante el arranque. Esta tarea se realiza utilizando los archivos `redo logs`.
* Recupera datos de transacciones incompletas (uncommited)
* Limpiar segmentos temporales que no se utilizan.
* Juntar extensiones (extents) libres contiguas dentro del tablespace manejado por el diccionario
* SMON se despierta de forma periodica para verificar si es necesario. Tambien puede ser invocado por otros procesos que lo requieran.

En resumen recicla las estructuras de almacenamiento.

## LREG Listener registration
Es un proceso que le indicará al listener en que estatus está la instancia o también le indica que servicios ofrece la instancia.

El listener recibe la lista de servicios de parte del LREG.

¿Porque el listener es un aplication process? Un mismo proceso puede atender a multiples instancias. Normalmente cuando se levantan diversos listeners es porque se utilizarán varios puertos. el primer Listener que configuramos fue en el 1521.

Cuando la instancia se inicia y no hay un listener entonces LREG buscará nuevos listeners cada ciertos segundos. Por ejemplo si levantamos y consultamos inmediatamente el Listener no notaremos los resultados de inmediato.

Le dice "Hola Listener te comunico que se inicio esta instancia que ofrece los siguientes servicios".

* Le indica al listener si la instancia se encuentra arriba y lista para atender solicitudes de conexiones.
* Le proporciona al listener la siguiente información:



## DBWn Database Write 
Es uno de los más importantes y hace referencia al DBWriter.

Una base de datos con muchos inserts, updates y deletes tendrá muchos dirty nodes.
Entre menos trabaja DBWriter es mejor.

* DBW escribe el contenido de los buffers modificados (dirty buffers) de la database buffer cache en los data files, es decir, en disco.
* Escribir a los data files se considera como una operación costosa. Por lo tanto DBW tratará de realizar esta operación con la menor frecuencia posible.
* Este proceso inicia junto con la instancia.
* DBW escribe lotes de bloques cuando es posible parar reducir los tiempos de escritura. El número de bloques escritos en un lote varía de acuerdo al sistema operativo.

Sólo despierta bajo los siguientes 3 procesos:

1. Cuando un server process no encuentra un buffer limpio que pueda utilizar tras un escaneo de un número determinado de buffers, o cuando el server process tarda demasiado en encontrar buffers limpios, le indica a DBW que escriba.
    * Se escriben los buffers que no son utilizados con alta frecuencia.
    * El DB buffer cache pudiera tener miles de buffers sucios, pero DBW solo escribirá unos cuantos cientos de buffers, solo aquellos que no han sido accedidos frecuentemente.
2. Existen demasiados buffers sucios. Existe un umbral interno para determinar esta condición.
3. Ocurre un checkpoint (se explica este concepto más adelante).














Almenos cada 3 segundos el LogWriter despierta para sincronizar en redologs.

Los redologs se guardan en: unam-bda/d01/app/oracle/oradata/YMMBDA2  y en cada punto de montaje encontramos los redologs.

Los redologs tienen una frecuencia muy alta de modificación con respecto a los datafiles, estos se encuentran en: `$ORACLE_BASE/oradata/YMMBDA2/*.dbf` son todos con terminación **.bdf**.

Sí el LogWriter tiene mucha carga entonces se puede auxiliar de `Log writer Slave(LGn)`

## ARCn: Archiver processes,log switch

**¿Qué es un log switch?**

Cuando la base de datos comienza a escribir en los redologs, pero para una base de datos con actividade DML (Muchos updates,inserts) esto hará que acabe el espacio de los redologs. Cuando se acaba de llenar hacemos un switch y llenamos en otro redolog. Pero cuando se llena el tercer grupo notamos que no hay un cuarto, lo que hace es regresar al primero (significando que reescribiría). La condición a cumplirse para hacer esto es: `Que exista un checkpoint` para que esto funcione el **dbwriter** debio hacer su chamba haciendo la sincronización a modo que los cambios de los redologs ya los tenga en los datafiles.

**Archiver** significa archivar. Si los cambios del grupo 1 están sincronizados podemos sobrescribir, es decir, confiamos en el datafile (pero no son infalibles). A pesar de tener el switch el datafile es responsable de guardar cambios, si falla podemos perder todos los cambios. 
La solución es garantizar que haya una copia del RedoLog por si un datafile llegase a fallar, es decir, los archivará. Por lo que un Archive es un archivado de los redologs. **(Esta función por default no está activada)**.

Casi al instante cuando se llene el grupo deberia hacerse el archivado y sincronización.

## CKPT: Checkpoint

En versiones anteriores el dbwriter hacia `full checkpoints` por lo que se veia reflejado en el desempeño. Por lo que para poder mejorar eso es mediante `incremental checkpoint`, a algunos cambios dentro del `db buffer caché` se seleccionan algunos elementos para saber cuales entran en un checkpoint y cuales no, de este modo tenemos un registro y saber hasta donde nos quedamos.

En resumen se sincroniza con DBWriter y realiza la sincronización de una fracción y tener el control mediante sincronizaciones parciales y no completas. Esto permite mejorar el performance de la base.

Un `shutdown o shutdown ordenado` es cuando genera una sincronización total.

## MMON: Manageability Monitor
El AWR es un repositorio donde se almacenan las estadisticas, el hacer diagnosticos, esto genera snapshot (es como un screen shot), es como una captura instantanea en el momento, cada vez que MMON despierta genera un SnapShot. Todos estos Snapshots nos sirve para monitorear el estado de salud. 
Si ocurriera un problema de desempeño nos ayudaría a saber en que momento comenzó a fallar. **Por default se toma un SnapShot cada hora.**