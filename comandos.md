grant create session to yanni0106;# Comandos Principales

Comandos: 

|Comando|Uso|
|||
|`export ORACLE_SID=ymmbdaN`|Permite seleccionar la base de datos|

SQL:

|Comando|Uso|
|--|--|
|`grant sysdba to jorge01;`|Al usuario Jorge01 le asigna el rol de sysdba|
|`grant create session to yanni0106;`|Asigna el privilegio para crear una sesion|
|`grant insert on t04_my_schema to <usuario>;`|Permiso a otro usuario para insertar en la tabla|
|`alter user nombre_usuario identified by nueva_contraseña;`|Cambio del password de un usuario|


## Consulta al alert log:

```
col name format a25
col value format a70
select name,value from v$diag_info;
```


## Ver objetos de un usuario

Primero autenticar con el usuario, y luego realizar la siguiente consulta:
`select object_name, object_type from user_objects`

## Eliminar una sesion:

para eliminar una sesión se puede emplear el siguiente comando:

`alter system kill session 'sid,serial#'`