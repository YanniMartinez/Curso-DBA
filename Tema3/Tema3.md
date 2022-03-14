# Iniciar y detener una base de datos

## Comando Startup

El comando startup pasa por 3 fases: inicia la instancia, monta y abre una base de datos.

Para que un usuario pueda iniciar sesion debió cumplirse todos los pasos anteriores.

Se puede levantar la instancia mediante métodos como:

* SQL*Plus
* A través de Oracle Restart. (normalmente usado en la nube)
* A traves de Recovery Manager (RNAM)
* Oracle Enterprise Manager cloud

## Etapas del startup
shutdown --> nomount --> mount --> open.

Cuando se utiliza el **nomount** la base de datos busca los siguientes parametros en este orden:

1. spfile{ORACLE_SID}.ora: En este caso es el SPFILE.
2. spfile.ora
3. init{ORACLE_SID}.ora

### CASO 1 iniciar con NOMOUNT

Si quisieramos autenticar con una ORACLE_SID que no existe y damos sqlplus sys as sysdba no nos marcará error pero a la hora de autenticar no nos permitirá.

Si entramos como oracle y ponemos sqlplus / as sysdba, entraremos correctamente por autenticar como SO. sin embargo, al dar startup nos marcará error porque no encontró el ultimo archivo.

Recordemos que la nomenclatura de un **init{ORACLE_SID}.ora** es un **PFILE**.

Normalmente este modo está muy limitado, de hecho sólo es usado para crear una nueva base de datos o recrear archivos de control.

Podemos usar NOMOUNT aun cuando no existen archivos de control ni una base de datos.

* Si un archivo de control se pierde si podemos llegar hasta el nivel de mount.

### CASO 2 usando el MOUNT

Significa que de un jalón queremos iniciar la base, primero pasa por el modo nomount, despues iniciar instancia y montar la base de datos. 
* Montar la base de datos significa que realizará una relación entre instancia y la base de datos. a traves del archivo de control le indica todos los parametros, para saber como se llama, que archivos tiene, etc, es como un informe.

En este modo es **vital** que exista el **archivo de control**

Cuando la base está arriba siempre se están escribiendo los archivos de control, para ello deberiamos hacer un shutdown para recuperar la copia del archivo de control.

Además necesita que los archivos de control sean identicos.





* Innactiva la instancia: 
    `alter system quiesce restricted;`

* `Shutdown inmediate` detiene todas las transacciones, y las que se tenian sólo se hacen un rollback para que no afecten.

