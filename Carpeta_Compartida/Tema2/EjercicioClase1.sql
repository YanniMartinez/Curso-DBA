/*A. Generar la sentencia necesaria para modificar su valor con base a los requerimientos de la siguiente
tabla. Si el valor del parámetro es una cadena, debe especificarse entre comillas simples.*/

--TODO Levantando la instancia:
--export ORACLE_SID=ymmbda2
--sqlplus sys as sysdba
--startup
--show user

--TODO Cualquier usuario puede hacer cambios en su sesión
--create user yanni02 identified by yanni quota unlimited on users
--grant create session, create table to yanni02

--! Inicio de ejercicio
show parameter nls_date_format --Este comando mostrará el valor a nivel de memoria(instancia)
--el comando anterior deberia ser consultado a nivel de sys, en caos contrario no mostrará nada

--Para verlo sin problema podemos hacerlo de la siguiente manera:
select sysdate from dual; --Salida 22-FEB-22

--Modificación del parametro a nivel session:
--* Punto 1:
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

--Verificando si cambió el valor:
select sysdate from dual; --Salida 22/02/2022 ...

--* El cambio se efectuó correctamente, sin embargo, si iniciamos sesion en otra
--terminal aún con el mismo usuario notaremos que dará el formato de la primera consulta
--es decir, el valor --Salida 22-FEB-22

--*Punto 2:
/*Al analizar el parametro processes vemos que ambas banderas tienen el valor de false
por lo que significa que es completamente estatico el valor
La instrucción que nos permitiría cambiar su valor sería AlterSystem. Pero para ello debemos cambiarnos
a SYS*/

connect sys as sysdba 
alter system set processes=300 scope=spfile; --Hay que tener cuidado porque es valor permanente

--*Punto 3:
/*Analizando el valor de sessions notamos que dice false e inmediate.
El false significa que no se puede modificar a nivel de session
Al decir inmediate significa que el cambio se reflejará de inmediato

si no quisieramos que fuera permanente, sino a nivel instancia pondriamos el siguiente comando*/
--alter system set sessions=500 scope=memory; 
--Para lo que pide el usuario seria el siguiente:
--Al ser derivado de processes no puede hacerse mediante el scope memory, deberia ser permanente
alter system set sessions=500 scope=spfile;

/*Para verificar algun valor usamos la siguiente consulta:
select issys modifiable from v$parameter where name='sessions' */

--*Punto 4:
/*El parametro java_jit_enabled lo que nos permite es habilitarlo o deshabilitarlo
nos pemrite hacer que el código en Java corra casi de forma nativa en nuestra BD
analizandolo vemos que es true en ambas banderas, por lo que puede hacerse a nivel sesion
y de forma inmediata*/

--1 a nivel sessión:
select value from v$parameter where name='java_jit_enabled';
alter session set java_jit_enabled=false; --si pusiera un scope a nivel sessión estaria mal

--2 comprobar el vlaor
select value from v$parameter where name='java_jit_enabled'; --Comprobamos que cambió a false

--3 Que valor tendrá el parametro si se abre en una nueva session?
connect sys as sysdba 
show parameter java_jit_enabled --Notaremos que regresó al valor de True porque el cambio se hizo a nivel session

--4 dehabilitar el valor a nivel instancia:
alter system set java_jit_enabled=false scope=memory;

--5 Comprobar el resultado. Deberia mostrar false por estár a nivel de memoria
show parameter java_jit_enabled


/*Para comprobar el reinicio podemos hacer lo siguiente
shutdown inmediate
startup*/



/*Si se nos presentara un caso en el que cambiamos el parametro y hace que truene
la instancia al leventar, ¿Cuales serian los pasos a seguir?

1. Crear un PFILE 
2. Modificarlo y haciendo correcciones al valor.
3. startup pfile=path/ 
4. Crear SPFILE (este nuevo sobreescribirá el anterior)
5. Hacer un shutdown de la base
6. Startup solito sin el parametro del PFILE.

En el alert log podriamos ver porque la instancia no levantó
*/


/*Tenemos un SPFILE corrupto y no tenemos un respaldo reciente de parte del PFILE
por lo que está obsoleto, ¿Qué harias?

Checariamos el ALERT LOG porque mostraría los parametros de la ultima vez que la
base levantó correctamente. Mostraria todos los parametros que tenia el SPFILE
A partir de esa lista podriamos crear un PFILE y y reperir los pasos.
*/