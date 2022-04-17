--@Autor: Martínez Martínez Yanni
--@Fecha creación: 16/04/2022
--@Descripción: Restauración del SPFILE tras la modificación de parámetros

--Entrar a sesion como sysdba
connect sys as sysdba

Prompt Deteniendo la instancia 
shutdown immediate

Prompt Creación de SPFILE desde el PFILE e-02-spparameter
create spfile='$ORACLE_HOME/dbs/spfileymmbda2.ora' from pfile='/unam-bda/ejercicios-practicos/t0204/e-02-spparameter-pfile.txt';

Prompt Proceso Finalizado correctamente, SPFILE restaurado