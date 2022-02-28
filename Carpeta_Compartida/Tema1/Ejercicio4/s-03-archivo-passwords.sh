#!/bin/bash
# @Autor Martinez Martinez Yanni 
# @Fecha 21/02/2022
# @Descripcion Simula recuperacion de archivo de passwords

orapwd FILE='${ORACLE_HOME}/dbs/orapwymmbda1' FORCE=Y FORMAT=12.2 SYS=password SYSBACKUP=password 

ls -l $ORACLE_HOME/dbs/orapwymmbda1 