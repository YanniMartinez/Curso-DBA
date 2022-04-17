/*Ejercicios de PlaceHolder, en el tema 10 es un curso de PLSQL*/
--Bloque Anonimo: No tiene nombre y no se guarda
declare
begin
end;
/


--*Creando una tabla
create table orden_compra{
    id number,
    fecha date,
    importe number(10,2)
};

--!Declaración de procedimiento almacenado
declare
    v_orden_compra orden_compra%rowtype;
begin
    for i in 1..50000 loop
        begin--Bloque anonimo anidado
            --Declaración para código dinámico
            execute inmediate 'select * from order_compra where id='||i --Estamos concatenando el i, esto genera consultas duras
            into v_orden_compra--uGuarda en la variable
        exception
            when no_data_found then
                null;
        end;
    end loop;
end;
/
--Tarda cerca de 2 minutos

--*Buena práctica
declare
    v_orden_compra orden_compra%rowtype;
begin
    for i in 1..50000 loop
        begin--Bloque anonimo anidado
            --Declaración para código dinámico
            execute inmediate 'select * from orden_compra where id= :ph1' 
            into v_orden_compra--uGuarda en la variable el resultado de la consulta
            using i --En este caso le estamos pasando un placeholder por lo que es mejor y genera consultas suaves.
        exception
            when no_data_found then
                null;
        end;
    end loop;
end;
/
--Llega a tardar 00.76 segundos


/*Si tuvieramos más de 1 placeholder podemos usar
* using i, i, i
* hasta n variables que quisieramos usar*/

set timing on --Al final de una sentencia muestra cuanto tarda

















--Procedimiento: Tiene un nombre y se guarda como tabla

--Funciones


--Trigger


--Paquete
    --funciones
    --procedimientos
    --contantes
    --En PLSQL todos los paquetes se llaman así dbms<nombre_paquete>