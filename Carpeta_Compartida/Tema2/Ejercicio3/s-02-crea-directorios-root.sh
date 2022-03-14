

export ORACLE_SID=ymmbda2
cd /u01/app/oracle/oradata

#Creando carpeta para los directorios (Los ^^ pasan a mayusculas)
mkdir ${ORACLE_SID^^}

#Asignando nuevo usuario y grupo
chown oracle:oinstall ${ORACLE_SID^^}

#Cambiando para que los externos al grupo no puedan hacer nada
chmod 750 ${ORACLE_SID^^}

#Crear directorios para Redo Log y control files.
echo "Creando directorios para RedoLogs y Control Files"
cd /unam-bda/d01
mkdir -p app/oracle/oradata/${ORACLE_SID^^}
chown -R oracle:oinstall app #El -R significa que es recursivo
chmod -R 750 app

cd /unam-bda/d02
mkdir -p app/oracle/oradata/${ORACLE_SID^^}
chown -R oracle:oinstall app
chmod -R 750 app

cd /unam-bda/d03
mkdir -p app/oracle/oradata/${ORACLE_SID^^}
chown -R oracle:oinstall app
chmod -R 750 app

#Comprobando
echo "Comprobando la información"

echo "Mostrando directorio de data files"
ls -l /u01/app/oracle/oradata
echo "Mostrando directorios para control files y Redo Logs"
ls -l /unam-bda/d0*/app/oracle/oradata

