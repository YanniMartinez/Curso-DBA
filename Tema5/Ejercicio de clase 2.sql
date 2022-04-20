--Levantar el listener para usar el SQLDeveloper
lsnrctl start

--Net service name incorrecto ServiceName = ORACLE_SID
sqlplus sys as sysdba

/*
* Considerar las vistas v$session, v$sql
*/

--*a) Terminal con usuario sys
desc v$session;

select osuser, machine, status, program
from v$session 
where username='SYS';


--*b) Mostrar el identificador y sentencia SQL
select s.sql_id, sq.sql_text
from v$session s, v$sql sq 
where s.sql_id=sq.sql_id
and s.username='SYS'
and s.program='SQL Developer';

select * from v$sql; -- veremos todas las sentencia SQL ejecutadas
--v$sql lo que hace es ver registro de las sql ejecutadas


/*Cuando ejecutamos una sentencia atras hay muchas más de sys
antes de ver datos debe verificar las vistas, ver que tengan las columnas
ver si se tienen los permisos o si es factible usarla
*/


--*c) usar v$active_session_history
select h.sample_time, h.sql_id, sq.sql_text, s.sid
from v$session s, v$sql sq, v$active_session_history h 
where h.sql_id=sq.sql_id 
and s.sql_id = h.sql_id 
and s.sid=h.session_id
and s.username='SYS'
and s.program='SQL Developer'
order by sample_time asc;

--select * from v$active_session_history where session_id = 326 order by sample_time;
--Muestreo del inicio de sesión

--select * from v$session where sid=326;