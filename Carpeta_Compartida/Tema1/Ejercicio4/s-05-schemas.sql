
connect yanni0104/yanni

Prompt Creando Tabla yanni0104.t04_my_schema
create table t04_my_schema (
username varchar2(128),
schema_name varchar2(128)
);



Prompt Asignando roles

GRANT select,insert on yanni0104.t04_my_schema to yanni0104; 
GRANT select,insert on yanni0104.t04_my_schema to yanni0105; 
GRANT select,insert on yanni0104.t04_my_schema to yanni0106; 



/*************************************************************************/
Prompt insertando datos con yanni0104 as sysdba
connect yanni0104/yanni as sysdba


insert into yanni0104.t04_my_schema (username,schema_name)
values (
sys_context('USERENV','CURRENT_USER'),
sys_context('USERENV','CURRENT_SCHEMA')
);

--Prompt Consultando tabla
--select * from yanni0104.t04_my_schema;

 

/*****************************************************************************/
Prompt insertando datos con yanni0105 
connect yanni0105/yanni 
Prompt Insertando a la tabla t04_my_schema
insert into yanni0104.t04_my_schema (username,schema_name)
values (
sys_context('USERENV','CURRENT_USER'),
sys_context('USERENV','CURRENT_SCHEMA')
);


Prompt insertando datos con yanni0106 as sysbackup
connect yanni0106/yanni 
insert into yanni0104.t04_my_schema (username,schema_name)
values (
sys_context('USERENV','CURRENT_USER'),
sys_context('USERENV','CURRENT_SCHEMA')
);

commit; 

connect sys as sysdba

select username,sysdba,sysoper,sysbackup,last_login from v$pwfile_users;

alter user sys identified by system1;