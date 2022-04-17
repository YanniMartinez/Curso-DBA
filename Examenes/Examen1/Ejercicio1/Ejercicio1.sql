/*Parte 1
Considerar que se tiene una terminal abierta con el usuario ordinario. Realizar las siguientes acciones, emplear sudo o cambiarse de sesión de usuario según se requiera.*/
--export ORACLE_SID=ymmbda2
--sqlplus sys as sysdba

a. Suponer que el archivo de passwords de la instancia 2 fue eliminado por accidente. Se ha decidido copiar el archivo de passwords de la instancia 1 hacia el directorio de la instancia 2. Empleando el usuario oracle, realizar la copia y cambiar el nombre para que la instancia 2 lo pueda usar.
--archivo SH

--b. Para mejorar la seguridad se ha decidido cambiarle los permisos a la copia con base al siguiente patrón: : rw-r-----

--c. Adicional a lo anterior, se ha decidido generar una copia del archivo en /root/bd/backups. Empleando el usuario root, crear la estructura de directorios y copiar el archivo de passwords a la carpeta backups. Asegurarse que la copia le pertenezca al usuario root y al grupo root para mayor seguridad.


/*Parte 2
Considerar que se tiene una terminal abierta con el usuario ordinario. Realizar las siguientes acciones, asumir que la instancia está iniciada.
a. Suponer la existencia de una tabla public.T1 y un usuario llamado admin que cuenta con todos los privilegios de administración. Generar una sentencia que permita crear una sesión de tal forma que el usuario admin pueda ejecutar la siguiente sentencia sin la necesidad de indicar nombres de esquemas: select * from T1;*/


--b. Empleando autenticación del sistema operativo, generar una sesión con privilegio sysdba.

--c. Generar una consulta que verifique si el usuario admin cuenta con el privilegio de administración sysoper.

--d. Generar una sentencia SQL que permita eliminar el privilegio sysoper al usuario admin,

--e. Como usuario sys, generar una sentencia que permita mostrar el contenido de la tabla T1.


/*f. Haciendo uso del archivo de passwords, generar una sentencia que permita crear una sesión empleando el privilegio de administración sysbackup a partir del usuario admin
Parte 3.
Considerar que se tiene una terminal abierta con el usuario ordinario. Realizar las siguientes acciones, emplear sudo o cambiarse de sesión de usuario según se requiera
a. Suponer que el archivo de passwords se ha dañado. El nombre global de la BD es myprod.unam.fi Generar un Shell script que se encargue de crear un nuevo archivo, incluir al usuario sys y sysbackup en el archivo.*/


--b. Posteriormente, en el script se desea incluir a un usuario existente llamado admin para que pueda acceder a los objetos del esquema public.
