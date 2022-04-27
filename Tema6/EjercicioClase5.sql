--* Consultando las tablas que tiene el usuario en curso
select table_name
from user_tables;

--* Vistazo a la vista user_segments
select * from user_segments;
/*Los registrosque inician con BIN son las que aun existen
--y sirven para reciclar.
La columna Bytes nos puede dar un estimado del espacio que usa
la tabla
*/

--* Vistazo a la vista de extensiones a una tabla especifica
/*Nos desplegará en nivel de mbs el espacio de la tabla*/
select bytes/1024/1024 mbs
from user_segments
where segment_name='T03_RANDOM_DATA';

--* Si de esos 112 mb quisieramos ver los bloques en uso o libres
--debemos usar los procedimientos almacenados.



--*TODO: Creación de tablas y segmentos
create table test(str char(1024));
select * from user_segments;
/*Si realizamos consulta de los segmentos vemos que la tabla test no está
--Para que la creacion de la tabla sea rápida no se le asigna espacio. 
por default la tabla no genera espacio, hasta que se asigna valores
Hasta que se insertan datos se le asigna su segmento
*/
insert into test values ('a');
insert into test values ('b');   --Si lo agregamos tendiamos 2k
insert into test values ('c');   --Si lo agregamos tendiamos 2k
insert into test values ('d');   --Si lo agregamos tendiamos 2k
insert into test values ('e');   --Si lo agregamos tendiamos 2k
insert into test values ('f');   --Si lo agregamos tendiamos 2k
insert into test values ('g');   --Si lo agregamos tendiamos 2k
insert into test values ('h');   --Si lo agregamos tendiamos 2k

/*Tras insertar el char podemos ver que pesa:*/
select lengthb(str) from test; --b es de bytes 1024
select length(str) from test; --llena 1024
select length(trim(str)) from test; 
/*Notemos que el uso de char es un valor fijo y siempre usará los 1024 establecidos
el varchar es dinámico*/


--*TODO: La cosa cambia si usamos la siguiente información
create table test2(str char(1024)) segment creation inmediate;
/*
Aquí notaremos que tarda más, hace que reserve espacio
*/
select * from user_extents where segment_name = 'TEST2';

select * from user_extents where segment_name='TEST2';

/*
Normalmente se recomienda usar DEFFER, por ejemplo un nuevo sistema
al usar inmediate podriamos tener problemas porque se le asigna un valor, es mejor
hacer DEFFERED para hacer dinámico el espacio. 
Con el inmediate podriamos demandar más espacio.

Para crear tablas de forma más rápida usamos el DEFFER.
*/

select 8*1024 from dual; --Aproximadamente cada extension mide 8192



--TODO: Que pasa si aparte agregamos una APK?
create table test3(
    id number constraint test3_pk primary key,
    str varchar2(1)
) segment 
--Notamos que generó 2 segmentos, 1 para la PK y otro para el registro, cada pk es un segmento

--Si creamos un indice vemos un nuevo segmento
create index test3_str_ix on test3();