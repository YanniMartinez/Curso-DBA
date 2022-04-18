# Iniciar y detener una base de datos

## Comando Startup

El comando startup pasa por 3 fases: inicia la instancia, monta y abre una base de datos.

Para que un usuario pueda iniciar sesion debió cumplirse todos los pasos anteriores.

Se puede levantar la instancia mediante métodos como:

* SQL*Plus
* A través de Oracle Restart. (normalmente es un script que puede correr de parte del SO para iniciar la instancia)
* A traves de Recovery Manager (RNAM permite hacer respaldos y recuperar una instancia tras una falla)
* Oracle Enterprise Manager cloud

## Startup

Puede ir acompañado mediante un PFILE o SPFILE, por ejemplo la siguiente sintaxis:

`startup=/u01/oracle/dbs/mySpfile.ora`

## Etapas del startup
shutdown --> nomount (instancia iniciada) --> mount (abre el archivo de control) --> open (se abre la base de datos)


### Startup nomount

Lo que hace es iniciar la instancia sin montar la BD. Es decir, hasta este punto la instancia aún no es asociada a una BD.

Se encarga de:
* Crear todas las áreas de memoria.
* Los procesos de background.
* Ubica y lee los parametros considerando el siguiente orden:

1. spfile{ORACLE_SID}.ora: En este caso es el SPFILE.
2. spfile.ora
3. init{ORACLE_SID}.ora


**Caso de estudio:**

Sí se digitan los siguientes comandos es valido? o se generan errores? (Considere que base2 no existe)

```
export ORACLE_SID=base2

sqlplus sys as sysdba
```

No generará ningun error, sin embargo tras ese comando nos pedirá autenticar, y apesar de cualquier combinación que hagamos nunca nos dejará autenticar. Recordemos que el archivo de parametros se contruye a partir del ORACLE_SID.

Pero si autenticamos como Oracle:

```
ORACLE> export ORACLE_SID=base2
ORACLE> sqlplus / as sysdba
```

Notamos que funciona y no solicita una autenticación como el caso anterior.

La diferencia es que en el caso anterior fue autenticación via archivo de passwords y en esta usamos autenticación mediante SO

Sin embargo en ORACLE a pesar de entrar. Si queremos colocar **startup** nos arrojará un error como el siguiente:

`could not open parameter file '/u01/app/oracle/product(19.3.0/dbhome_1/dbs/initbase2.ora'`

Es decir, no encuentra el pfile con nombre **initbase2.ora**. Por lo que es la ultima opción que busca.




### CASO 1 iniciar con NOMOUNT

Si quisieramos autenticar con una ORACLE_SID que no existe y damos sqlplus sys as sysdba no nos marcará error pero a la hora de autenticar no nos permitirá.

Si entramos como oracle y ponemos sqlplus / as sysdba, entraremos correctamente por autenticar como SO. sin embargo, al dar startup nos marcará error porque no encontró el ultimo archivo.

Recordemos que la nomenclatura de un **init{ORACLE_SID}.ora** es un **PFILE**.

Normalmente este modo está muy limitado, de hecho sólo es usado para crear una nueva base de datos o recrear archivos de control.

Podemos usar NOMOUNT aun cuando no existen archivos de control ni una base de datos.

* Si un archivo de control se pierde si podemos llegar hasta el nivel de mount.


## Startup mount
Lo que hace es ir al segundo escalon pasando primero por el **nomount**. En si lo que hace es iniciar la instancia y montar la BD. Montar significa crear una relación entre instancia y base de datos.

* Ubica y lee el contenido del archivo de control y lo lee (Recordemos que el archivo de control le indica todas las caracteristicas de la base de datos para poder identificarla) El archivo de control sólo dice que archivos se tienen sin embargo, en este punto no se verifican. Su dirección se obtiene del parametro **control_files**

En resumen necesita:
* SPFILE
* Archivos de control iguales si no no levanta la instancia.


#### Daño en control files
Si perdemos nuestros archivos de control si es muy complicado recurperarse.
sin embargo si sólo se daño 1 archivo de control podemos recuperarnos gracias al multiplexeo que habiamos hecho, para ello primero deberiamos bajar por completo la instancia porque todo el tiempo el control file sigue trabajando

### CASO 2 usando el MOUNT

Significa que de un jalón queremos iniciar la base, primero pasa por el modo nomount, despues iniciar instancia y montar la base de datos. 
* Montar la base de datos significa que realizará una relación entre instancia y la base de datos. a traves del archivo de control le indica todos los parametros, para saber como se llama, que archivos tiene, etc, es como un informe.

En este modo es **vital** que exista el **archivo de control**

Cuando la base está arriba siempre se están escribiendo los archivos de control, para ello deberiamos hacer un shutdown para recuperar la copia del archivo de control.

Además necesita que los archivos de control sean identicos.


## Startup open ó STARTUP
Lo que hace es pasar primero por todos los anteriores pasos.

* A partir de las ubicaciones y nombres de los data files y redologs, lo que hace es leer su contenido y revisar si los archivos están sincronizados. Si todo esto es correcto procede a abrir la base de datos, en caso contrario inicia el proceso de recuperación.

* Se obtiene un table espace tipo **undo** para ser utilizado.

* A partir de este punto la BD puede ser accedida


## Startup open recover

Es forzar un recovery en la base de datos.


## Problemas que pueden ocurrir al inicio

* Archivo de control dañado o no disponible
* Si alguno de los archivos especificados en el archivo de control no están disponibles la BD no se podrá montar.

## Modo resringido de BD

* El acceso a modo restringido solo se otorga a los usuarios administradores
* Es útil para las siguientes actividades:

    * Operaciones import y export de datos.
    * Realizar cargas masivas de datos, ejemplo, empleando SQL * Loader.
    * Restringe acceso a usuarios que no cuentan con privilegios de administración.
    * Realizar operaciones de migración y actualización de software de la BD

* El usuario debe contar con los privilegios de: `Create Session` y `Create restricted session`.

Para iniciar y/o montar la base de datos en este modo podemos usuar el siguiente comando:

`startup restrict`

* Opcionalmente se puede utilizar en las fases `nomount`, `mount`

Para deshabilitar este modo usamos el siguiente comando:

`alter system disale restricted session`.

Este modo es agresivo porque no permite iniciar sesión a los demás usuarios, existen otros modos no tan agresivos.

## Subir de nivel en la instancia
Para ello tenemos los siguientes comandos:

|Comando| Descripción|
|--|--|
|alter database mount|Cambia el estado actual de la instancia al modo mount|
|alter database open|Cambia el estado a modo open|
|alter data base open read only|Permite consultas pero ninguna modificación en los Online redo Logs|
|alter database open read write|Es el valor por default equivalente a `alter database open` es equivalente al `startup`|


## SHUTDOWN
* Open: Base de datos abierta
* Close: Base de datos cerrada, control file abierto
* nomount: contorl file cerrado instancia iniciada.
* Shutdown

1. Base de datos cerrada: Todos los datos del SGA se escriben o sincronizan con los datafiles y online redologs.
    Los datafiles y redologs se cierran
    Los archivos de control está abierto
    La sentencia es `alter database close`
2. Base de datos no montada: La base de datos es desasociada a la instancia.
    El archivo de control se cierra
    La instancia permanece en memoria

3. Base de datos detenida: La memoria se libera y los procesos de background son terminados. (shutdown)
    En algunos casos hay remanentes, si es el caso, podemos usar `shutdown abort`


### Tipos de Shutdown:

* Shutdown normal: Es la opción por default
    - No se permiten más conexiones.
    - Si hay usuarios conectados, la instancia espera a que cierren sesión para detener la instancia
    - Se realiza sincronización por lo que no necesita proceso de recuperación.

* Shutdown inmediate: 
    - No se permiten nuevas conexiones
    - Para las sesiones actuales se cierran de inmediato, las sesiones actuales se les hace rollback.
    - No espera a que ellos cierren sesión.
    - Cierre ordenado y sincronización.

* Shutdown transactional: 
    - No permite nuevas conexiones.
    - Permite que las transacciones en curso terminen, pero no permite nuevas transacciones.
    - Al cierre de las transacciones cierra sesión de usuarios conectados que no hacen nada.

* Shutdown abort: Es la opción más agresiva.
    - No nuevas sesiones
    - Termina sesiones actuales
    - Se salta la sincronización, se debe realizar una recuperación, normalmente es durante una emergencia.



* Innactiva la instancia: 
    `alter system quiesce restricted;`

* `Shutdown inmediate` detiene todas las transacciones, y las que se tenian sólo se hacen un rollback para que no afecten.

