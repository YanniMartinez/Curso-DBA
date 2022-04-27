--t01_sga_components
CREATE TABLE yanni0401.t01_sga_components
(
    memory_target_param NUMBER(12,2),
    fixed_size NUMBER(12,2),
    variable_size NUMBER(12,2),
    database_buffers NUMBER(12,2),
    redo_buffers NUMBER(12,2),
    total_sga NUMBER(12,2)
)

INSERT into yanni0401.t01_sga_components (
    memory_target_param, fixed_size, variable_size, database_buffers, redo_buffers, total_sga)
    VALUES (
        (select value/1024/1024 from v$spparameter where name='memory_target';),
        (SELECT value/1024/1024 FROM v$SGA where name="Fixed_size"),
        (SELECT value/1024/1024 from v$SGA where name="Variable_size"),
        (SELECT value/1024/1024 from v$SGA where name="Database_buffers"),
        (SELECT value/1024/1024 from v$SGA where name="Redo_buffers" ),
        (SELECT sum(value)/1024/1024 from v$SGA )
);

--*B
create table yanni0401.t02_sga_dynamic_components(
    component_name varchar2(64),
    current_size_mb number(10,2),
    operation_count number(10,0),
    last_operation_type varchar2(13),
    last_operation_time date
);

INSERT 
INTO yanni0401.t02_sga_dynamic_components
SELECT component, current_size/1024/1024, oper_count/1024/1024, last_oper_type, last_oper_time
FROM v$sga_dynamic_components ORDER BY current_size desc;


--*C)
create table yanni04010401.t03_sga_max_dynamic_component(
    component_name varchar2(64),
    current_size_mb number(10,2),
);

INSERT 
INTO yanni0401.t03_sga_max_dynamic_component
SELECT component, current_size/1024/1024
FROM v$sga_dynamic_components
WHERE current_size(select MAX(current_size) from v$sga_dynamic_components);


--*D)
create table yanni0401.t04_sga_min_dynamic_component(
component_name varchar2(64),
current_size_mb number(10,2),
);

INSERT 
INTO yanni0401.t04_sga_min_dynamic_component
SELECT component, current_size/1024/1024
FROM v$sga_dynamic_components
WHERE current_size(select MIN(current_size) from v$sga_dynamic_components WHERE current_size>0);



--*E)
create table yanni0401.t05_sga_memory_info(
name varchar2(64),
current_size_mb number(10,2),
);

INSERT 
INTO yanni0401.t05_sga_memory_info
SELECT name, bytes/1024/1024
FROM v$sgainfo
WHERE name in ('Maximum SGA Size', 'Free SGA Memory Available');


--*F)
create table yanni0401.t06_sga_resizeable_components(
    name varchar2(64)
);

INSERT 
INTO yanni0401.t06_sga_resizeable_components
SELECT name
FROM v$sgainfo
WHERE resizeable='Yes';


Commit;



--*1.3
create table yanni0401.t07_sga_resize_ops(
    component varchar2(64),
    oper_type  varchar2(13),
    parameter  varchar2(80),
    initial_size_mb number(10,2),
    target_size_mb  number(10,2),
    final_size_mb number(10,2),
    increment_mb  number(10,2),
    status  varchar2(9),
    start_time  date,
    end_time  date,
);

INSERT 
INTO yanni0401.t07_sga_resize_ops
SELECT component, oper_type, parameter, initial_size/1024/1024, final_size/1024/1024, con_id/1024/1024, status, start_time, end_time
FROM v$sga_resize_ops
ORDER BY component desc, end_time desc;
--/opt/sqldeveloper/sqldeveloper.sh &
