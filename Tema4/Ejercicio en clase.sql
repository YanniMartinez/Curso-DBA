--A partir de este tema usaremos SQLDeveloper, para ello es necesario levantar el Listener

--Primero se levanta el listener y luego la instancia
lnsrctl start

--Despues levantar la instancia
startup

lsnrctl services --Lo que nos dice es que instancias están levantadas.

--Lo que hace SQL es iniciar una conexión
/*Aquí se le dice que el que normalmente se hace mediante método TNS
es decir TNS
Todo lo que esté en Network es lo que tiene que ver con la red

cd $ORACLE_HOME
more tnsnames.ora

show parameter db domain --Si no se tiene entonces podemos tener problemas
--Si no aparece en verde el tnsnames.ora no nos aparecerá en los alias.

Podemos agregar un parametro con Netmanager*/

--*a)
select * from v$sga;
--Muestra el resumen, para mostrar en bytes se pone lo siguiente
select name, value/1024/1024 value_mb
from v$sga;

--*b) Total de memoria asignada
select sum(value)/1024/1024 total_mv 
from v$sga;

--*c) Mostrar el valor de Memory targer
show parameter memory_target;

--*d) Cantidad de memoria asignada a la memoria SGA
--v$sga_dynamic_component --contiene todos los componentes de la SGA
desc v$sga_dynamic_components
select component, current_size/1024/1024 current_size_mb
from v$sga_dynamic_components
order by current_size_mb desc;
--Los primeros 5 elementos son vitales. Quizá el más importante es el segundo
--DEFAULT_BUFER_SIZE

--*e) v$sga_resize_ops contiene las ultimas 800 operaciones de resize.
desc v$sga_resize_ops

select component, oper_type, parameter,
  trund(initial_size/1024/1024,2) initial_size_mb, --Trunca a 2 decimales el valor
  trunc(target_size/1024/1024,2) target_size_mb,
  trunc(final_size/1024/1024,2) final_size_mb,
  status, start_time
from v$sga_resize_ops
order by final_size_mb desc;
--Oracle19c podemos ver toda la documentación
/*Vemos que hay un componente 3 veces, esto va representanto el historico,
cuando se inicializó, creció y estableció.
Todos esos parametros la instancia los calcula, podemos cambiarlos con el nombre del parametro*/

--*f) Mostrar el total de RAM libre en MB que tiene la instancia v$

select * from v$sga_dynamic_free_memory

select current_size/1024/1024 current_size_mb from v$sga_dynamic_free_memory;

--*e) Ver como esta distribuida la informacion de la memoria
select * from v$sgainfo 
--esta vista contiene los componentes de la SGA, es un resumen de los más importantes
select name, trunc(bytes/1024/1024,2) MBs, resizeable from v$sgainfo;
--La columa "Resizeable" indica si el parametro es dinamico o no.