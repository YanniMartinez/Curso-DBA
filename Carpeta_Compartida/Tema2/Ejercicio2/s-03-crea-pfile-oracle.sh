#!/bin/bash
# @Autor Martinez Martinez Yanni
# @Fecha 06/03/2022
# @Descripcion Creación de un PFILE
echo "1. Creando un archivo de parámetros básico"
export ORACLE_SID=ymmbda2
pfile=$ORACLE_HOME/dbs/init${ORACLE_SID}.ora 

if [ -f "${pfile}" ]; then
  #El comando read -P actua como un Scanf de C pero en este caso sólo es para hacer
  #Una pequeña pausa y seguir adelante con el programa
  read -p "El archivo ${pfile} ya existe, [enter] para sobrescribir"
fi;

#El comando  "">$pfile lo que hace es transferir el contenido de la cadena al archivo.
#que se indica despues del caracter >
echo \
"db_name='${ORACLE_SID}'
memory_target=768M
control_files=(/unam-bda/d01/app/oracle/oradata/${ORACLE_SID^^}/control01.ctl,
               /unam-bda/d02/app/oracle/oradata/${ORACLE_SID^^}/control02.ctl,
               /unam-bda/d03/app/oracle/oradata/${ORACLE_SID^^}/control03.ctl)
" >$pfile

echo "Listo"
echo "Comprobando la existencia y contenido del PFILE"
echo ""
cat ${pfile} #Muestra el contenido del PFILE