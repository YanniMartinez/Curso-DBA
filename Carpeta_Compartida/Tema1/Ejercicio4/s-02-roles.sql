--@Autor Martinez Martinez Yanni 
--@Fecha 20/02/2022
--@Descripcion Creacion de las tablas

create table yanni0104.t02_db_roles as
select ROLE_ID ,ROLE
from dba_roles;

create table yanni0104.t03_dba_privs as
select privilege 
from dba_sys_privs
where grantee='DBA';
