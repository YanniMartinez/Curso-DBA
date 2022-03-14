
--! NOTA:
--Conectando como sys empleando el archivo de passwords creado anteriormente
--Con un usuario ordinario
connect sys as sysdba

/*Startup nomount lo que hace es iniciar la instancia, pero mediante el spfile
es decir, no voltea ver a la base de datos porque hasta este punto aún no existe
Una instancia y una BD son totalmente diferentes pero trabajan en conjunto para
que sean usadas. Entonces es importante no confundir estos conceptos.

Notar que solo se requiere
de un PFILE o un SPFILE para poder iniciar una nueva instancia sin su base de datos.*/
startup nomount

--Cuando ocurre un error entonces deja de ejecutar y termina. Si antes de esto
--existen inserciones o algo así se hace un rollback para que no afecte en nada.
whenever sqlerror exit rollback

--!Creando la base de datos, uso de CreateDataBase:
--echo "Iniciando la creación de la BD"

create database ymmbda2
  user sys identified by system2
  user system identified by system2
  logfile group 1 (
    '/unam-bda/d01/app/oracle/oradata/YMMBDA2/redo01a.log',
    '/unam-bda/d02/app/oracle/oradata/YMMBDA2/redo01b.log',
    '/unam-bda/d03/app/oracle/oradata/YMMBDA2/redo01c.log') size 50m blocksize 512,
  group 2 (
    '/unam-bda/d01/app/oracle/oradata/YMMBDA2/redo02a.log',
    '/unam-bda/d02/app/oracle/oradata/YMMBDA2/redo02b.log',
    '/unam-bda/d03/app/oracle/oradata/YMMBDA2/redo02c.log') size 50m blocksize 512,
   group 3 (
    '/unam-bda/d01/app/oracle/oradata/YMMBDA2/redo03a.log',
    '/unam-bda/d02/app/oracle/oradata/YMMBDA2/redo03b.log',
    '/unam-bda/d03/app/oracle/oradata/YMMBDA2/redo03c.log') size 50m blocksize 512
  maxloghistory 1
  maxlogfiles 16
  maxlogmembers 3
  maxdatafiles 1024
  character set AL32UTF8
  national character set AL16UTF16
  extent management local
  datafile '/u01/app/oracle/oradata/YMMBDA2/system01.dbf'
    size 700m reuse autoextend on next 10240k maxsize unlimited
  sysaux datafile '/u01/app/oracle/oradata/YMMBDA2/sysaux01.dbf'
    size 550m reuse autoextend on next 10240k maxsize unlimited
  default tablespace users
    datafile '/u01/app/oracle/oradata/YMMBDA2/users01.dbf'
    size 500m reuse autoextend on maxsize unlimited
  default temporary tablespace tempts1
    tempfile '/u01/app/oracle/oradata/YMMBDA2/temp01.dbf'
    size 20m reuse autoextend on next 640k maxsize unlimited
  undo tablespace undotbs1
    datafile '/u01/app/oracle/oradata/YMMBDA2/undotbs01.dbf'
    size 200m reuse autoextend on next 5120k maxsize unlimited;

--echo "Fin de la creación de la BD YMMBDA2"

--Cuando acabe este punto se habrán creado cerca de 17 archivos, incluidos los redologs y los
--controlFiles, estos se crean al crear la instancia o cerebro.

--Cambiando la contraseña de los usuarios:
alter user sys identified by system2;
alter user system identified by system2;