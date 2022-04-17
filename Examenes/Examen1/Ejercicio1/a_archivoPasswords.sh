#!/bin/bash
# @Autor Martinez Martinez Yanni 
# @Fecha 14/03/2022
# @Descripcion Simula recuperacion de archivo de passwords

#Estableciendo la base de datos temporal
export ORACLE_SID=ymmbda2
#a
cp ${ORACLE_HOME}/dbs/orapwymmbda1 ${ORACLE_HOME}/dbs/orapwymmbda2
#b
chmod 640 orapwymmbda2
#c
su
mkdir /root/bd/
mkdir /root/bd/backups/
cp ${ORACLE_HOME}/dbs/orapwymmbda2 
cd /root/bd/backups/
sudo chown oracle:oracle orapwymmbda2