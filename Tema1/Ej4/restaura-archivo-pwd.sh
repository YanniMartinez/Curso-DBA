#!/bin/bash
#
#
#

echo "Generando archivo de passwords"

#Comando para recuperar archivo
#El comando no tendrá problemas en buscar el archivo de passwords porque está en el path ya establecido
#El apartado FORCE=Y significa: "Si existe sobreescribelo"
orapwd FILE='${ORACLE_HOME}/dbs/orapwymmbda1' FORCE=Y FORMAT=12.2 \ #El "\" significa que el comando continua en la linea de abajo. Significa que el comando aun no termina y continua en la linea de abajo
SYS=password \ #Por tema de seguridad aquí no dejará poner contraseña en texto plano, nos preguntará el password cuando iniciemos sesion
SYSBACKUP=password #El valor password no significa que ese sea su password. significa que agregara el usuario "SYS" y "SYSBACKUP" al archivo de passwords

echo "Revisando el nuevo archivo"

ls -l $ORACLE_HOME/dbs/orapwymmdba1 