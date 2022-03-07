#!/bin/bash
# @Autor Martinez Martinez Yanni
# @Fecha 06/03/2022
# @Descripcion Creación de archivo de Passwords


#Estableciendo la base de datos temporal
export ORACLE_SID=ymmbda2

#Creando el archivo de passwords para la instancia 2
orapwd FILE='${ORACLE_HOME}/dbs/orapwymmbda2' FORCE=Y FORMAT=12.2 SYS=password 

ls -l $ORACLE_HOME/dbs/orapw${ORACLE_SID} 
