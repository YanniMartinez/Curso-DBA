--@Autor Martinez Martinez Yanni 
--@Fecha 20/02/2022
--@Descripcion Creación de procedimiento almacenado que permite identificar si existe o no un usuario
--Asignación de esquema y creación de tabla a traves de una query


--esta instrucción permite detener la ejecución del script al primer error
--útil para detectar errores de forma rápida.
--al final del script se debe invocar a whenever sqlerror continue none
--para regresar a la configuración original.
whenever sqlerror exit rollback;
-- para propósitos de pruebas y propósitos académicos se incluye el password
-- no hacer esto en sistemas reales.
Prompt conectando como usuario sys  
connect sys/system1 as sysdba 

declare 
v_count number;
v_username varchar2(20) := 'yanni0104';
begin --Inicio del procedimiento
select count(*) into v_count from all_users where username=v_username; 
if v_count >0 then 
execute immediate 'drop user '||v_username|| 'cascade'; 
end if;
end;
/

Prompt creando al usuario yanni0104
create user yanni0104 identified by yanni quota unlimited on users;
grant create session, create table to yanni0104;


create table yanni0104.t01_db_version as
select product,version,version_full
from product_component_version;

