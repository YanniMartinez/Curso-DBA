#!/bin/bash
# @Autor Martinez Martinez Yanni
# @Fecha 06/03/2022
# @Descripcion Creación de Disk Images y puntos de montaje

#Creación de la carpeta Disk Images
echo "Creando carpeta de Disk Images"
cd /  #asegura que se vaya a la raíz
sudo mkdir /unam-bda/disk-images #Creará la carpeta en la ruta indicada
sudo chown yanni:yanni disk-images
sudo chmod 755 disk-images

#Ingresando a la carpeta DiskImages
cd /
cd /unam-bda/disk-images #Ingresa a la carpeta

#Creación de los LoopDevices
dd if=/dev/zero of=disk1.img bs=100M count=10 #Genera 10 veces los espacios de 100Men el archivo
dd if=/dev/zero of=disk2.img bs=100M count=10
dd if=/dev/zero of=disk3.img bs=100M count=10

#Comprobando que se hayan creado bien los Discos
#Comprueba todos al tener un formato de expresion regular
du -sh disk*.img

#Asigna un LoopDevice a una imagen existente.
#El flag -f busca el numero de loop disponible y asigna
#El flag P actualiza la tabla de LoopDevices
losetup -fP disk1.img
losetup -fP disk2.img
losetup -fP disk3.img

#Muestra los LoopDevices creados despues de las 3 intrucciones anteriores:
losetup -a

#* Hasta este punto ya están creadas las simulaciones de discos pero aun falta formatear:

#* Dando formato EXT4 a las simulaciones de disco:
mkfs.ext4 disk1.img
mkfs.ext4 disk2.img
mkfs.ext4 disk3.img

#Creando carpetas para el punto de montaje:
mkdir /unam-bda/d01
mkdir /unam-bda/d02
mkdir /unam-bda/d03

#Este comando monta el LoopDevice pero se cancela al apagar la pc, se debe aplicar en el 
#/etc/fstab con el sig comando /unam-bda/disk-images/disk1.img /unam-bda/d01 auto loop 0 0
#mount -o loop /dev/loop0 /unam-bda/d01

#*Monta todo lo que existe en el archivo fstab:
mount -a

#*Verificando que todo salió bien (Deberá mostrar los puntos de montaje)
df -h | grep "/*unam-bda/*"
