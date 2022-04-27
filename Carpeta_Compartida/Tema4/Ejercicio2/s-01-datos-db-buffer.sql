
connect sys as sysdba

CREATE TABLE yanni0402.t01_sga_components
(
  block_size NUMBER(10,2),
  current_size NUMBER(10,2),
  buffers NUMBER(10,2),
  target_buffers NUMBER(10,2),
  prev_size NUMBER(10,2),
  prev_buffers NUMBER(10,2),
  default_pool_size varchar2(255)
)

INSERT into yanni0402.t01_db_buffer_cache (
    block_size, current_sizee, buffers,  target_buffers, prev_size, prev_buffers,default_pool_size)
    VALUES (
        (select block_size from v$buffer_pool ),
        (SELECT current_size FROM v$buffer_pool ),
        (SELECT buffers from v$buffer_pool),
        (SELECT  target_buffers from v$buffer_pool ),
        (SELECT prev_size from v$buffer_pool ),
        (SELECT prev_buffers from v$buffer_pool ),
      (SELECT name FROM v$spparameters where='db_cache_size')
);




--* 1.4)
create table yanni0402.t02_db_buffer_sysstats.(
	db_blocks_gets_from_cache ,
  consistent_gets_from_cache ,
  physical_reads_cache 
);

INSERT 
INTO yanni0402.t02_db_buffer_sysstats.
SELECT value
FROM v$sysstat
WHERE name in('db block gets from cache','consistent gets from cache', 'physical reads cache');


--* caché
alter table yanni0402.t02_db_buffer_sysstats ADD cache_hit_radio NUMBER(12,6) ;

insert into yanni0402.t02_db_buffer_sysstats (cache_hit_radio) 
VALUES(1-(SELECT physical_reads_cache from yanni0402.t02_db_buffer_sysstats)/(SELECT db_blocks_gets_from_cache from yanni0402.t02_db_buffer_sysstats)+(SELECT consistent_gets_from_cache from yanni0402.t02_db_buffer_sysstats));

--incluir resultados de la siguiente ocnsulta
select * from t02_db_buffer_sysstats


--*1.5)
