
create user jorge01 identified by jorge quota unlimited on users;
grant create session, create table to jorge01;

grant sysdba to jorge01;
grant sysoper to jorge01;

--a
show user 

-- b
select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual; --El esquema será usuario01

--c
create table test(id number);

 --Disconect saca de sesión pero seguimos en SQLPlus, no detiene el spool. Pero el Exit si.
--6
disconnect
--* 7 Ingresando como sqlplus yanni01 as sysdba
show user --Ahora mostrará SYS
spool /home/yanni/Desktop/e-t01-01-jrc.txt append

select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual; --Ahora el esquema será Sys
--a 
SYS
--b
Sys
--c Dirá que la tabla no existe.
select * from test;
--Debemos cambiar el esquema
select * from jorge01.test; --Aquí si podriamos ver los datos.


--* 8
sqlplus yanni01 as sysoper
show user --Será public
select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual; --Ahora el esquema será public
--c Dirá que la tabla no existe.
select * from test; 
--Aun cuando indiquemos el esquema no podemos ver los datos porque no tiene privilegios.
select * from jorge01.test;

select count(*) from user_objects; --Lista el numero de objetos publicos,, algunos creados en la instlacion

--* Conectar como otro usuario:
connect jorge01 
select count(*) from user_objects; --Mostrará 1 y corresponde a la tabla TEST

--* Connectar como sysdba
connect jorge01 as sysdba
select count(*) from user_objects; --Dará más objetos que public. Dará todos los objetos que tiene sys.

--fin ejercicio
