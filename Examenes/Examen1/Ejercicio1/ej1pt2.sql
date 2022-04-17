/*Parte 2
Considerar que se tiene una terminal abierta con el usuario ordinario. Realizar las siguientes acciones, asumir que la instancia está iniciada.
a. Suponer la existencia de una tabla public.T1 y un usuario llamado admin que cuenta con todos los privilegios de administración. Generar una sentencia que permita crear una sesión de tal forma que el usuario admin pueda ejecutar la siguiente sentencia sin la necesidad de indicar nombres de esquemas: select * from T1;*/
GRANT select on public.T1 to admin; 

--b. Empleando autenticación del sistema operativo, generar una sesión con privilegio sysdba.
create user new_session identified by yanni quota unlimited on users; 
grant create session to new_session;

--c. Generar una consulta que verifique si el usuario admin cuenta con el privilegio de administración sysoper.
select username,sysdba,sysoper
from v$pwfile_users
where username='admin';

--d. Generar una sentencia SQL que permita eliminar el privilegio sysoper al usuario admin,
revoke grant sysoper from admin;

--e. Como usuario sys, generar una sentencia que permita mostrar el contenido de la tabla T1.
select * from public.T1;

/*f. Haciendo uso del archivo de passwords, generar una sentencia que permita crear una sesión empleando el privilegio de administración sysbackup a partir del usuario admin
Parte 3.
Considerar que se tiene una terminal abierta con el usuario ordinario. Realizar las siguientes acciones, emplear sudo o cambiarse de sesión de usuario según se requiera
a. Suponer que el archivo de passwords se ha dañado. El nombre global de la BD es myprod.unam.fi Generar un Shell script que se encargue de crear un nuevo archivo, incluir al usuario sys y sysbackup en el archivo.*/

#!bin/bash
export ORACLE_SID= myprod.unam.fi

orapwd FILE='${ORACLE_HOME}/dbs/orapwymmbda1' FORCE=Y FORMAT=12.2 SYS=password SYSBACKUP=password 

ls -l $ORACLE_HOME/dbs/orapwymmbda1 
--b. Posteriormente, en el script se desea incluir a un usuario existente llamado admin para que pueda acceder a los objetos del esquema public.
grant sysoper to admin;


