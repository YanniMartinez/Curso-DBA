
--Entrar a sesion como sysdba
connect sys as sysdba

--Modificando formato de la fecha:
Prompt 2.a Modificando fecha a nivel sesion 
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
