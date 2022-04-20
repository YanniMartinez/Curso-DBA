# Tema 5 Administración de procesos

¿Qué es un proceso? 
Un proceso es un programa o conjunto de ejecuciones.
El procesador ejecuta las instrucciones, una vez que acabaron su proceso quedan en 0% es decir, en espera. A los procesos que se quedan en modo espera son llamados background.

Para ver los procesos de listas es mediante:

* `ps`
* `ps -ef | grep oracle`: Mostrará todos los comandos que sólo son ejecutados por el comando Oracle.
    `dbw`: Es el db writer
    `lgwr`: Log writer

Para matar un proceso podemos usar, recordemos que el segundo es el padre:

`kill -9 32086`: en este caso el -9 signica la prioridad más alta.

`kill -9 idProceso` Si se muere el DB writer vemos que la instancia se muere por completo, es decir, tira la base de datos.

## Arquitectura de procesos:

Procesos obligatorios:
* PMON
* SMON


Los procesos se pueden definir como: 

* (user proces). Como el SQL Developer.

* Server process: Este proceso es llamado por la peticion del usuario

    * dedicated server process. Es decir un proceso dedicado a cada usuario.
    * Shared server process.

* Demonios (Daemons)/ Application process: Se crean desde que la instancia se inicia.

El **listener** es un ejemplo claro de aplication process. El listener puede atender 2 instancias.

## Procesos dedicados

El listener sirve sólo como un puente para poder realizar la conexión entre cliente y servidor, una vez que ya está la conexión no afecta si se cae el listener.

Cada service process es dedicado al usuario, es decir, si tenemos 1000 usuarios entonces debemos tener 1000 conexiones y vinculaciones.

-----------------

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

Para ello es necesario configurar los parametros con valor mayor a cero

`shared_servers` >0
`dispatchers` > 0

Afortunadamente los shared_servers pueden configurarse. lo que se recomienda es:

`shared servers=1` cuando el dispatcher es estaclecido `max_shared_servers=1/8` del valor del parametro processes.

Relacion 1 a 1: Es en el user process es un proceso dedicado

Estos son los 2 principales modos para poder habilitar las configuraciones.

Si la configuración del `shared services` es muy bajo no debemos preocuparnos porque podemos aumentarlos de formá dinamica

### Forma sencilla de modificar el proceso

**Un shared process por cada 10 conexiones**

Ejemplos:

```
alter system set dispatchers='(PROTOCOL=tcp)'

--configurar 2 dispatchers para protocolo TCP
alter system set dispatchers='(dispatchers=2)(protocol=tcp)'
;

--configura 20 shared process
alter system set shared_servers=20;
```

## Configuración del listener y el tnsnames.ora en modo compartido

Tanto el listener como el archivo `tnsnames.ora` en el que se configuran los nombre del servicio. Ofrece la lista de servicios que ofrece. El listener identifica las instancias mediante el `service_name`, el listener lee lo siguiente.

```
service_name=
nombre de la BD: db_name + db_domain
instancia 1<iniciales>=>db_name
Dominio de la BD: .fi.unam => db_domain (opcional pero conveniente obligatorio)
```

Para resolver un nombre de host es mediante

`hostname -i` este valor sale de un DNS. Este servicio resuelve el nombre de host, pero nosotros tenemos nuestro propio DNS local, en este caso es localhost, es decir: `127.0.1.1` nuestro DNS local es el HOST (`more etc/host`)

-----------------------
`àlter system register;` hace que el proceso en background despierte, le avisa al listener.

`lsnrctl services` le indica al listener que el modo compartido fue habilitado.

para verificar que el modo compartido está habilitado podemos usar la vista `v$process` los que empiezan con `S0` son los shared process.

```
select program, pid, pname
from v$process
where pname like 'S0%'
or pname like 'D0%'
order by program;
```

En el archivo **tnsnames.ora** tiene un parametro el cual es llamado **SERVER** si  no lo ponemos entonces por default es dedicado. Cuando lo ponemos le indicamos que sea compartido.


* `SERVER=DEDICATED`
* `SERVER=SHARED`


Para acceder al modo compartido ponemos el siguiente comando:

``

1. Configurar los parametros
2. Configurar alias de permiso y poner el parametro SERVER=SHARED
3. 


|Vista|uso|
|--|--|
|v$dispatcher|Vemos los dispatchers|
|v$dispatcher_config|Cuantos dispatchers se han configurado|
|$queue|Muestra que tanto tiempo han estado encolads los procesos, para resolver tiempos largos lo que podemos hacer es aumentar los shared servers|
|v$shared_server|Muestra un renglon por cada shared services|
|v$circuit|Son los clientes conectados en el modo compartido|


Si al consultar `v$shared_server` y vemos que por mucho tiempo en **mensssages** signigica que sólo 1 está trabajando y los otros no. (Es el número de peticiones desde que se inició)


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

CLMM delega algunos procesos. y se encarga del monitoreo de la limpieza.

`v$cleanup_process`: proporciona información de los procesos PMON.

```
select name,state,dead_in_cleanup, cleanup_time,time_since_last_cleanup, num_cleaned
from v$cleanup_process
```

* Para sacar un usuario de la base de datos se usa `alter system kill session '74,18605,@1' ` @1 es el id de la instancia. Resumen del comando `<sid>,<serial#>,@<inst_id>`


## PMAN Process Manager
Se enfoca más al modo compartido y la proramación de tareas como jobprocesses.
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
* Juntar extensiones (extents) libres contiguas dentro del tablespace manejado por el diccionario. Semejante a la acción de defragmentación. 
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


* **Checkpoint** es un evento para sincronizar buffer sucios con un checkpoint.

Normalmente hay un solo proceso de `db_writer_process`, normalmente se tiene uno por procesador.

## Checkpoints
Es una señala que le indica al DBW escribir todos los buffer suciones que existan en el DB Buffer Caché.
Existen algunos tipos de Checkpoints:
* Checkpoint total: Escribe el 100% de todos los buffer sucios existentes.
* Checkpoint parcial: Escribe el 100% de los buffer sucios pero de un determinado datafile.

Podemos mandar un Checkpoint manual en los siguientes casos:

Podemos ejecutar de forma manual la instrucción `alter system checkpoint`, pero hay que tener cuidado porque puede afectar el performance de la base.

Cuando la BD se establese en modo read only.

Podemos auxiliarnos de la vista `v$`


## Log Writer.

Redo Log Buffer lo que hace es sincronizar los DB Buffer caché a los online redo logs por medio del DBWriter.

El tamaño de un datafile es mucho más grande que un redolog.

El redolog son solo un conjunto de datos que se van apilando. Por default un redolog mide 100mb.

El redorecord va a ir a dar a la ruedita es decir, el redo log buffer. Aunque el usuario no haga commit el cambio puede estar ya en el redolog. Puede haber datos en los Datafiles de transacciones que no hayan pasado por un commit y esto es normal porque el DBWriter no valida, sino que agarra un bonche de secciones y los sincroniza con los datafiles. Cuando existe ese montaje de información en los datafiles lo que pasa es sobreescribir los valores, cuando el usuario realiza un rollback lo que hará entonces es usar los valores undos, por lo que los cambios nuevos pasaran a algo viejo.

Que pasa cuando el usuario hace el rollback y muere la instancia sin haber sincronizado en el datafile? al querer reiniciar la instancia ocurrirá un recovery, lo que se hace es ver que teniamos el cambio de `9-->10` esto se conoce como un checkpoint parcial (primera ocacion en la que el DBW despertó). Cuando el usuario manda el rollback entonces pasa de `10-->9`, pero si no se sincroniza y muere la instancia, cuando se lance el recovery se leerá el redolog en el ultimo checkpointy estos son los que sincroniza, los que estaban antes del recovery los ignora. Este cambio se reflejará cuando el DBwriter vuelva a despertar.

El redolog despierta cuando:

Almenos cada 3 segundos el LogWriter despierta para sincronizar en redologs. (a menos que haya otro evento que lo llame).

Los redologs se guardan en: `unam-bda/d01/app/oracle/oradata/YMMBDA2`  y en cada punto de montaje encontramos los redologs.

Los redologs tienen una frecuencia muy alta de modificación con respecto a los datafiles, estos se encuentran en: `$ORACLE_BASE/oradata/YMMBDA2/*.dbf` son todos con terminación **.bdf**.

Sí el LogWriter tiene mucha carga entonces se puede auxiliar de `Log writer Slave(LGn)`

## ARCn: Archiver processes,log switch

**¿Qué es un log switch?**

Cuando la base de datos comienza a escribir en los redologs, pero para una base de datos con actividade DML (Muchos updates,inserts) esto hará que acabe el espacio de los redologs. Cuando se acaba de llenar hacemos un switch y llenamos en otro redolog. Pero cuando se llena el tercer grupo notamos que no hay un cuarto, lo que hace es regresar al primero (significando que reescribiría). La condición a cumplirse para hacer esto es: `Que exista un checkpoint` para que esto funcione el **dbwriter** debio hacer su chamba haciendo la sincronización a modo que los cambios de los redologs ya los tenga en los datafiles.

**Archiver** significa archivar. Si los cambios del grupo 1 están sincronizados podemos sobrescribir, es decir, confiamos en el datafile (pero no son infalibles). A pesar de tener el switch el datafile es responsable de guardar cambios, si falla podemos perder todos los cambios. 
La solución es garantizar que haya una copia del RedoLog por si un datafile llegase a fallar, es decir, los archivará. Por lo que un Archive es un archivado de los redologs. **(Esta función por default no está activada)**.

Casi al instante cuando se llene el grupo deberia hacerse el archivado y sincronización.


Para asegurar que un commit quedó completamente asegurado es cuando está en los OnlineRedoLogs. Si uno de los grupos falla entonces lo que hará es esperar a que funcione el grupo. Si los cambios ya están en el datafile entonces el grupo puede ser sobrescrito.

Toda base productiva deberia tener su modo archive activa.
Para sobrescribir con toda certeza el grupo de redo primero deberian pasar:

* Cambios pasados a logfiles
* El redo esté archivado

## CKPT: Checkpoint

En versiones anteriores el dbwriter hacia `full checkpoints` por lo que se veia reflejado en el desempeño. Por lo que para poder mejorar eso es mediante `incremental checkpoint`, a algunos cambios dentro del `db buffer caché` se seleccionan algunos elementos para saber cuales entran en un checkpoint y cuales no, de este modo tenemos un registro y saber hasta donde nos quedamos.

En resumen se sincroniza con DBWriter y realiza la sincronización de una fracción y tener el control mediante sincronizaciones parciales y no completas. Esto permite mejorar el performance de la base.

Un ejemplo claro es un separador de libro `marca donde se quedó` y sirve para saber a donde más seguir.

Checkpoint parcial y checkpoint incremental son equivalentes.

Para encontrar un checkpoint es cuando usamos Un `shutdown o shutdown ordenado` es cuando genera una sincronización total.

En cuanto el grupo esté lleno deberia ser archivado y prácticamente sincronizado para no tener problemas.

## MMON: Manageability Monitor

Durante la operacion se generan estadisticas las cuales se guardan en la SGA, MMON lo que hace es despertar y pasa de memoria al AWR (automatic write repository) en donde se guardará la historia y estadisticas, el MMON guarda todo este tipo de estadisticas. 

Cada que el MMON despierta genera un snapshot (una instantanea).

El AWR es un repositorio donde se almacenan las estadisticas, el hacer diagnosticos, esto genera snapshot (es como un screen shot), es como una captura instantanea en el momento, cada vez que MMON despierta genera un SnapShot. Todos estos Snapshots nos sirve para monitorear el estado de salud de la base de datos.

Si ocurriera un problema de desempeño nos ayudaría a saber en que momento comenzó a fallar. **Por default se toma un SnapShot cada hora.**

Masomenos dura 1 semana en la memoria.

**AWR Baseline** Es un conjunto de estadisticas tomadas en un periodo de tiempo cuando la BD se comporta correctamente con cargas de trabajo máximas (tiempos pico). Este conjunto de estadisticas puede ser fomado por un conjunto de snapshots.

El AWR baseline puede ser comparado con estadisticas tomadas en un periodo donde la BD se comporta con bajo deseméño y poder de esta fomra diagnosticas probleas.

Es una herramienta para ver que la BD funciona correctamente

## ADDM 
Trabaja en conjunto con el AWR, adicionalmente MMON lanza una herramienta llamada ADDM. es un self-advisor que de forma automática y proactiva diagnostica el desempeño de la BD y determina como resolver problemas identificados.

* Dentro de sus actividades, ADDM identifica áreas dentro de la BD que consumen una gran cantidad de tiempo de procesamiento, realiza analisis detallado para encontrar la causa raíz del problema.

* puede recomendar cambios a nivel hardware, configuration de la BD, cambios en la configuracion de esquema, aplicaciones y reporta el beneficio obtenido.

* Como resultado de ejecutar esta herramienta, MMON puede lanzar diversas **alertas** notificando la existencia de algun posible problema.

Hay aplicaciones gráficas que permiten visualizar esto.

## MMNL Manageability Monitor Lite

Este proceso se llama monitor lite, es parecido a MMON (trabaja a nivel SGA) pero el MMNL es a nivel sesión para ver los valores de las sesiones a nivel de cada usuario.

* Obtiene datos a nivel sesion
* Estos datos se almacenan en un buffer en la SGA llamado Active Session History (ASH)

--------------------
### Active Session History (ASH)

* Realiza monitoreo de sesiones activas en la base de datos cada segundo.
* De forma especifica, el muestro se realiza ddesde las vistas `v$session` y `v$session_wait` y se almacenan en la vista ``v$active_session_history`

Los datos que se registran son:

* Id del usuario
* Estado
* Sentencia SQL que está ejecutando.

En general contiene las estadisticas de la sesión casi en tiempo real y los vacia en el AWR en la vista `DBA_`



## RECO: Recovered process

Este proceso de background trabaja en base de datos distribuidas

`update orden@B set importe=100 ...` cuando se vea esta sintaxis hace referencia a otra base de datos que está en otro server, es decir, podemos mandar instrucciones a una base completamente remota.

El nodo que lanza la transacción hacia otro nodo entonces debe buscar la sincronización. 

Lo que hace reco es verificar que transacciones están pendientes, cuales quedan pendientes y como pueden avanzar.

## Vista del diccionario de procesos

`select * from v$process` en esta vista se muestra el id del sistema operativo.

por ejemplo el MMON:
`select * from v$process where sosid='28317'`

Todo proceso tiene su archivo de monitoreo y se puede mostrar en esa vista, cada proceso de background tiene su propia auditoria. A cada proceso de background se le asigna su propia PGA. También se guarda cuanto CPU usa.

PMAN se encarga de reiniciar procesos cuando se caen.