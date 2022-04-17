--@Autor: Martínez Martínez Yanni
--@Fecha creación: 16/04/2022
--@Descripción: Modificación de parámetros y creación de tablas
-- con los nuevos valores

--Entrar a sesion como sysdba
connect sys as sysdba

--Modificando formato de la fecha:
Prompt 2.a Modificando nls_date a nivel sesion 
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

--False, False, es un valor estático
Prompt 2.b Modificando db_writer_processes a 2
alter system set db_writer_processes=2 scope=spfile;

--False, False, es un valor estático. Log buffer almacena el valor en bytes
Prompt 2.c Modificando log_buffer a 10mb
alter system set log_buffer=10485760 scope=spfile;

--False, False, es un valor estático.
Prompt 2.d Modificando data_files a 250
alter system set db_files=250 scope=spfile;

--False, False, es un valor estático.
Prompt 2.e Modificando número máximo de bloqueos en instrucciones DML a 2500
alter system set dml_locks=2500 scope=spfile;

--False, False, es un valor estático.
Prompt 2.f Modificando valor de los segmentos de rollback a 600
alter system set transactions=600 scope=spfile;

--true, False, es un modificable a sesion y estático
Prompt 2.g Modificando memoria para ejecutar hash joins a 2 MB a nivel sesion y futuro
--sesion
alter session set hash_area_size=2097152; 
--spfile para futuras sesiones
alter system set hash_area_size=2097152 scope=spfile;

--true, deferred, se puede moficar a nivel session
Prompt 2.h Modificando memoria para sort a 1MB a nivel sesion
alter session set sort_area_size=1048576; 

--TRUE, inmediate. Puede modificar de inmediato a nivel instancia o memoria
Prompt 2.i Modificando la salida de datos de debug en sentencias SQL a nivel instancia
alter system set sql_trace=TRUE scope=memory;
--TODO: Está en 2 tablas, menos en spfile

--! false, inmediate. Aplicamos both para que surta efecto de inmediato a sesion y spfile
Prompt 2.j Modificando las búsquedas de datos se realicen de la forma más eficiente
alter system set optimizer_mode='FIRST_ROWS_100' scope=both;
--TODO: deberá estar en 3 tablas


--True, inmediate. Se puede modificar a nivel instancia sin problema
Prompt 2.k Modificando estilo de validación de cursores a DEFERRED únicamente a nivel sesión.
alter session set cursor_invalidation='DEFERRED';










--* Apartado 3
Prompt 3.0 Crear una tabla llamada t03_update_param_session

--parámetros modificados en la sesión del usuario 
create table yanni0204.t03_update_param_session as
select name,value
from v$parameter
where name in (
'cursor_invalidation','optimizer_mode',
'sql_trace','sort_area_size','hash_area_size','nls_date_format',
'db_writer_processes','db_files','dml_locks','log_buffer','transactions'
)
and value is not null;

--*4. Tablas con informacion de instancia y de SPFILE
--parámetros modificados en la instancia del usuario 
create table yanni0204.t04_update_param_instance as
select name,value
from v$system_parameter
where name in (
'cursor_invalidation','optimizer_mode',
'sql_trace','sort_area_size','hash_area_size','nls_date_format',
'db_writer_processes','db_files','dml_locks','log_buffer','transactions'
)
and value is not null;

--parámetros modificados en el SPFILE del usuario 
create table yanni0204.t05_update_param_spfile as
select name,value
from v$spparameter
where name in (
'cursor_invalidation','optimizer_mode',
'sql_trace','sort_area_size','hash_area_size','nls_date_format',
'db_writer_processes','db_files','dml_locks','log_buffer','transactions'
)
and value is not null;

 
--*5 Creando PFILE despues de los cambios
create pfile='/unam-bda/ejercicios-practicos/t0204/e-03-spparameter-pfile.txt' from spfile='$ORACLE_HOME/dbs/spfileymmbda2.ora';


--*6 Ejecución del archivo: sqlplus /nolog
--start s-03-modifica-parametros.sql


/*Antes de modificar un parametro es importante primero revisar
las columnas isses_modifiable y issys_modifiable las cuales nos dirán
cual es la instrucción correcta para modificar un valor,
es decir, permiten indentificar si es un valor:
 - Estatico
 - Dinamio
 
 
 isses se refiere a nivel sesión
 issys se refiere a nivel system*/


/*
isses: Si el valor es true, significa que el valor puede ser modificado 
a nivel de sesión. Por lo tanto es posible usar 
'alter session set <parametro>=<val>'

issys: Nos dice si el valor es estático o dinámico en base a 3 valores
 *-Inmediate: Puede efectuar el cambio de forma inmediata y se aplica a
 nivel de MEMORIA (instancia). Al poder modificar de inmediato a nivel instancia
 entonces significa que es DINÁMICO. 

 Al ser un cambio en memoria no le importa si se levanta con PFILE o SPLFILE

 *-Deferred: El cambio no toma efecto luego luego, por lo que debemos reiniciar
 sesion. Por lo que también debe hacerse a nivel MEMORIA(instancia).

 Tampoco le importa si inicia con PFILE o SPFILE


 *-False: Indica que es un parametro estático, por lo que el cambio debe ponerse
 forzosamente meediante el SPFILE. Por lo que el comando sería:

 TODO: alter system set x=y scope=spfile;
*/


/*
Para comprobar los valores podemos usar los siguientes convenciones:

 - show parameter <param>: Valor a nivel MEMORIA(sesion)
 - v$parameter: Valor a nivel SESION


 *-Sí el valor de isses es true significa que puede modicarse a nivel SESION
    alter session set <param>=<value>
 
 *-Sí el valor de isses es falso y el de issys tambien es falso significa
 que es ESTATICO
    alter system set <param>=<value> scope=spfile;

 *-Sí el valor de isses es falso y el de issys es inmediate significa que 
 no se puede moficiar a nivel sesión pero si a nivel INSTANCIA. Aplica tanto
 para nivel memoria como nivel spfile.
    alter system set <param>=<value> scope=memory;

    alter system set <param>=<value> scope=spfile;

    IMPORTANTE: Saber donde queremos almacenarlo segun lo que pidan en este caso.

 *-Si el valor de isses es true y el de issys es inmediate signicia que podemos
 hacer el cambio en cualquier de los niveles y es valido.
 

! Plantilla de query:
select name, value, isses_modifiable, issys_modifiable
from v$system_parameter
where name='nombreParametro';
--where name like '%optimizer%';

1MB --> 1048576 byte
*/