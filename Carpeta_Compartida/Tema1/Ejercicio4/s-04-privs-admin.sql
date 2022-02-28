--@Autor Martinez Martinez Yanni 
--@Fecha 21/02/2022
--@Descripcion Creacion de usuarios de administracion

Prompt creando al usuario yanni0105 
create user yanni0105 identified by yanni quota 0M on users; 
grant create session to yanni0105;

Prompt creando al usuario yanni0106
create user yanni0106 identified by yanni quota 0M on users; 
grant create session to yanni0106;


grant sysdba to yanni0104;
grant sysoper to yanni0105;
grant sysbackup to yanni0106;

