

--Conectando como sys empleando el archivo de passwords creado anteriormente
--Con un usuario ordinario
connect sys as sysdba

--Creacion de un SPFILE desde un PFILE
create spfile from pfile;
--Es equivalente usar también el siguiente comando:
--create spfile='/u01/oracle/dbs/test_spfile.ora' from pfile='/u01/oracle/dbs/test_init.ora';

--* En SQL se usa el ! para indicar que se trata de un comando de systema
--Ahorita servirá para comprobar que se creó el archivo
--Se ejecuta con el usuario que autenticó. Podemos verlo con !whoami
!ls ${ORACLE_HOME}/dbs/spfileymmbda2.ora




--Los PFILE son init**.ora
--Los SPFILE son spfile***