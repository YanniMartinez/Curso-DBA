/*
b. Considerar los siguientes parámetros:
 shared_pool_size, large_pool_size, java_pool_size, db_cache_size, streams_pool_size
pga_aggregate_target,sga_target
memory_target
Suponer que la instancia está configurada con administración de memoria “Manual Memory Management”.  
Generar las sentencias necesarias para que ahora la administración sea “Automatic Shared Memory Management”. 
Se deberán configurar todos los parámetros anteriores. Su valor puede ser 0.  
Proponer valores de memoria típicos para una BD donde se requiere que aproximadamente el 80% de la RAM
sea asignada a la SGA y el 20% a la PGA.**/
connect sys as sysdba 

select value/1048576
from v$pgastat
where name='maximum PGA allocated';


alter system set memory_max_target = (select value from v$spparameter where component='sga_target')
scope = spfile;


alter system set sga_target = 0;
alter system set pga_aggregate_target = 0;

alter system set shared_pool_size=0;
alter system set large_pool_size=0;
alter system set java_pool_size=0;
alter system set db_cache_size=0;
alter system set streams_pool_size=0;





/*
c. Generar las sentencias SQL necesarias de tal forma que, al ejecutar las siguientes instrucciones, sea posible realizar conexiones en el modo que se indica.
Proponer valores para los parámetros que permitan configurar cada caso.
sqlplus /nologconnect u1@shared deberá realizarse una conexión en modo compartido.
sqlplus u2@dedicated deberá realizarse una conexión en modo dedicado.
*/
--configura 2 dispatchers para protocolo TCP
alter system set dispatchers='(dispatchers=2)(protocol=tcp)';
--configura 20 shared servers
alter system set shared_servers=20;

alter system register;

/*d. Generar una sentencia SQL que muestre la siguiente información de los procesos de background que actualmente corren en una instancia: identificador del proceso asignado por el sistema operativo, nombre del proceso, ubicación de su archivo de bitácora donde se puede consultar mensajes o alertas de error, cantidad de memoria RAM en MB empleada por el proceso. */
select sosid, pname, tracefile, pga_used_mem/1024/1024
from v$process

