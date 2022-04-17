--@Autor: Martínez Martínez Yanni
--@Fecha creación: 16/04/2022
--@Descripción: Creación de tabla de parametros

connect sys as sysdba

CREATE TABLE yanni0204.t02_other_parameters
AS 
(select num, name, value, default_value, isses_modifiable as is_session_modifiable, issys_modifiable as is_system_modifiable
from v$system_parameter);