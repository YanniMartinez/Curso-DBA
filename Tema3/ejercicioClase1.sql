connect sys as sysdba

--* a)

--Inicia la base
startup 

--Como nadie hizo algo no afecta, es el metodo más rapido
starup abort 

--Inicio en modo nomount, vemos que es rapido
startup nomount

--Se usa para mostrar el estado de la instancia y su BD
desc v$instance

--Modifica a nivel sesion el formato de la fecha
alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';

--Para que se expanda en toda la ventana
set linesize window

--Modifica el valor de la columna
col_instance_name format a20
col database_status format a20


--Selección del nombre, del tiempo de inicio, status intancia, status BD
select instance_name, startup_time, status, database_status, active_state from v$instance;


--* b) Cambiar estatus a MOUNTED
--Cambia al siguiente paso
alter database mount;

select instance_name, startup_time, status, database_status, active_state from v$instance;

--* c) Que valor debera tener el param undo_tablespace a niver sesion e intancia?

show parameter undo_tablespace;
--Vemos que a este punto es nulo, aun no tiene un tablspace

--* d) cambiar el status de la instancia a OPEN y ver valor de undo_tablespace
alter database open;

show parameter undo_tablespace;

--* e) cerrar DB usando alter database close y revisar estatus de la BD
alter database close;

select instance_name, startup_time, status, database_status, active_state from v$instance;

--veremos que el estatus es MOUNTED
--La otra opción para llegar a este punto es la siguiente:
--TODO: alter database mount


--*f) Detener la instancia, luego abrirla a nivel solo lectura y verificar que sólo es lectura. 
--* despues detener instancia en modo abort.

--Primero detener de forma ordenada de la forma más rapida
shutdown immediate

startup nomount
alter database mount;
--En este paso sube de mount a open y aparte la pone en modo sólo lectura
alter database open read only;

/*
* Tras el paso anterior no dejará a los usuarios modificar en la BD por ejemplo:

TODO: create table test(id_number);

recibiremos el siguiente error:

    ! database or pluggable database open for read-only access
*/


--En este caso el shutdown abort es seguro porque solo es lectura entonce sno hay cambios pendientes
--para ser sincronizados
shutdown abort;
