--@Autor:          Yanni Martinez Martinez
--@Fecha creación:  23/03/2022
--@Descripción:  Validador  ejercicio práctico 04

whenever sqlerror exit rollback

--Modificar las siguientes 2 variables en caso de ser necesario.
--En scripts reales no debeń incluirse passwords. Solo se hace para
--propósitos de pruebas y evitar escribirlos cada vez que se quiera ejecutar 
--el proceso de validación de la práctica (propósitos académicos).

--
-- Nombre del alumno empleado como prefijo para crear usuarios en la BD
--
define p_nombre='yanni'

--
-- Password del usuario sys
--
define p_sys_password='system2'


--- ============= Las siguientes configuraciones ya no requieren cambiarse====

whenever sqlerror exit rollback
set verify off
set feedback off


Prompt =========================================================
Prompt Iniciando validador - Ejercicio práctico 02 - 03
Prompt Presionar Enter si los valores configurados son correctos.
Prompt De lo contario editar el script s-06-validador-oracle-main.sql
Prompt O en su defecto proporcionar nuevos valores
Prompt =========================================================

accept p_nombre default '&&p_nombre' prompt 'Prefijo empleado para crear usuarios (nombre del alumno) [&&p_nombre]: '
accept p_sys_password default '&&p_sys_password' prompt 'Proporcionar el password de sys [Configurado en script]: ' hide

define p_script_validador='s-05p-validador-ejercicios.plb'

Prompt Creando procedimientos para validar.

connect sys/&&p_sys_password as sysdba
set serveroutput on
@s-00-funciones-validacion.plb
@&&p_script_validador

exit