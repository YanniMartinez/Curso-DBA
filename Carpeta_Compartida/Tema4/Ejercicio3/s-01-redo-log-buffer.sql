

connect sys as sysdba;

CREATE TABLE yanni0402.t01_sga_components
(
  REDO_BUFFER_SIZE_PARAM_MB NUMBER(10,2),
  REDO_BUFFER_SGA_INFO_MB NUMBER(10,2),
  RESIZEABLE VARCHAR2(10),
);

INSERT into yanni0402.t01_db_buffer_cache ( REDO_BUFFER_SIZE_PARAM_MB, REDO_BUFFER_SGA_INFO_MB,RESIZEABLE)
  VALUES (
  (select truncate(value/1024/1024) from v$system_parameter where name='log_buffer'),
  (select truncate(bytes/1024/1024)  from v$sgainfo where name='Redo Buffers'),
  (select resizeable  from v$sgainfo where name='Redo Buffers')
);

