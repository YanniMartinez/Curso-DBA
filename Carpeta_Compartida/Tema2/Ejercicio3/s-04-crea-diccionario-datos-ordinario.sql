--@Autor:          Yanni Martinez Martinez
--@Fecha creación:  23/03/2022
--@Descripción:  Script que permite generar un diccionario de datos

--Conectando como sys empleando el archivo de passwords creado anteriormente
--Con un usuario ordinario
connect sys as sysdba

Prompt Connectando como usuario Sys

--Creando el diccionario de datos con el usuaro sys
--El @ es como un include
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/utlrp.sql

--Creando diccionario de datos con usuario system
Prompt Conectando como usuario System

connect system 
@?/sqlplus/admin/pupbld.sql


Prompt Fin del proceso
