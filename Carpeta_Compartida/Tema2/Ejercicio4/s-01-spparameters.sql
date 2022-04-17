--@Autor: Martínez Martínez Yanni
--@Fecha creación: 15/04/2022
--@Descripción: Creación de PFILE a partir de un SPFILE y tabla de parametros 

connect sys as sysdba

--Creación de un PFILE a partir del SPFILE:
create pfile='/unam-bda/ejercicios-practicos/t0204/e-02-spparameter-pfile.txt' from spfile='$ORACLE_HOME/dbs/spfileymmbda2.ora';

--*1.3
declare
  v_count number;
  v_username varchar2(20) := 'yanni0204';
begin
  select count(*) into v_count from all_users where username=v_username;
  if v_count >0 then
    execute immediate 'drop user '||v_username|| 'cascade';
  end if;
end;
/

create user yanni0204 identified by yanni quota unlimited on users;
grant create session, create table, create procedure, create sequence to yanni0204;


--Creando tabla
CREATE TABLE yanni0204.t01_spparameters
  AS (select name,value from v$spparameter
  where value is not null);
