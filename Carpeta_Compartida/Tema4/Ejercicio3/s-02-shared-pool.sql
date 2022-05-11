
connect sys as sysdba

CREATE TABLE yanni0403.t02_shared_pool(
  SHARED_POOL_PARAM_MB NUMBER(10,4),
  SHARED_POOL_SGA_INFO_MB NUMBER(10,4),
  RESIZEABLE  VARCHAR2(10),
  SHARED_POOL_COMPONENT_TOTAL NUMBER(10,4),
  SHARED_POOL_FREE_MEMORY  NUMBER(10,4)
);


INSERT INTO yanni0403.t02_shared_pool 
(SHARED_POOL_PARAM_MB, SHARED_POOL_SGA_INFO_MB,RESIZEABLE,SHARED_POOL_COMPONENT_TOTAL,SHARED_POOL_FREE_MEMORY)
VALUES (
  select truncate(value/1024/1024) from v$system_parameter where name='shared_pool_size'
  select truncate(bytes/1024/1024) from v$sgainfo where name='Shared Pool Size'
  select resizeable from v$sgainfo where name='Shared Pool Size'
  select count(*) from v$sgastat where pool='shared pool'
  select truncate(bytes/1024/1024) from v$sgastat where pool='shared pool' and name='free memory'
);




--*c)
CREATE TABLE yanni0403.t03_library_cache_hist(
  id NUMBER(10),
  reloads NUMBER(10,4),
  invalidations NUMBER(10,4),
  pins NUMBER(10,4),
  pinhits NUMBER(10,4),
  pinhitratio NUMBER(10,4)
);

INSERT INTO yanni0403.t03_library_cache_hist
(id,reloads,invalidations,pins,pinhits,pinhitratio)
VALUES(
  1,
  (select reloads from v$librarycache where namespace='SQL AREA'),
  (select invalidations from v$librarycache where namespace='SQL AREA'),
  (select pins from v$librarycache where namespace='SQL AREA'),
  (select pinhits from v$librarycache where namespace='SQL AREA'),
  (select pinhitratio from v$librarycache where namespace='SQL AREA')
);

--*D)
create table yanni0403.test_orden_compra(id number);

--*E)
/*El siguiente código provocará un cambio en el valor del library cache hit ratio. El programa realizará
50,000 consultas a la tabla test_orden_compra empleando el valor del campo id.*/
--Mala práctica hardcodeado
Prompt ejecutando consultas con sentencias sql estáticas
set timing on
declare
    orden_compra jorge0403.test_orden_compra%rowtype;
  begin
    for i in 1 .. 50000 loop
      begin
        execute immediate
          'select * from jorge0403.test_orden_compra where id = ' || i
           into orden_compra;
      exception
        when no_data_found then
          null;
      end;
    end loop;
  end;
/
set timing off

--*F. Agregar un registro a la tabla <nombre>0403.t03_library_cache_hist con id = 2. Hacer commit.
Prompt capturando nuevamente estadísticas del library cache
insert into yanni0403.t03_library_cache_hist(id,reloads,invalidations,pins,
  pinhits,pinhitratio)
  select 2 id, reloads,invalidations,pins,pinhits,pinhitratio
    from v$librarycache
    where namespace='SQL AREA'
;
commit;

--*G)
Prompt Apagando la instancia
shutdown inmediate

Prompt Iniciando
startup


connect sys as sysdba

--*H. Agregar un registro a la tabla <nombre>0403.t03_library_cache_hist con id = 3. Hacer commit.
Prompt capturando nuevamente estadísticas del library cache
insert into yanni0403.t03_library_cache_hist(id,reloads,invalidations,pins,
  pinhits,pinhitratio)
  select 3 id, reloads,invalidations,pins,pinhits,pinhitratio
    from v$librarycache
    where namespace='SQL AREA'
;
commit;


/*
*I)Agregar un nuevo bloque anónimo tomando como base el bloque anónimo que hace uso de
sentencias estáticas. El programa deberá hacer uso de placeholders para aprovechar el uso del library
cache. C1. Incluir en el reporte el código del bloque anónimo PL/SQL
*/
--TODO: Parseo suave
Prompt ejecutando consultas con sentencias sql estáticas y placeholders
set timing on
declare
    orden_compra jorge0403.test_orden_compra%rowtype;
  begin
    for i in 1 .. 50000 loop
      begin
        execute immediate
          'select * from jorge0403.test_orden_compra where id = :ph1' using i;
          into orden_compra;
      exception
        when no_data_found then
          null;
      end;
    end loop;
  end;
/
set timing off

--using i; permite poner el valor de los placeholders que usaremos

--*J) Agregar un registro a la tabla <nombre>0403.t03_library_cache_hist con id = 4. Hacer commit.
Prompt capturando nuevamente estadísticas del library cache
insert into yanni0403.t03_library_cache_hist(id,reloads,invalidations,pins,
  pinhits,pinhitratio)
  select 4 id, reloads,invalidations,pins,pinhits,pinhitratio
    from v$librarycache
    where namespace='SQL AREA'
;
commit;

--*K) Mostrar los datos de la tabla <nombre>0403.t03_library_cache_hist.
select * from yanni0403.t03_library_cache_hist;