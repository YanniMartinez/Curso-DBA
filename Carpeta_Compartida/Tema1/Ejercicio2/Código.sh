#!/bin/bash

# @Autor Martínez Martínez Yanni
# @Fecha dd/mm/yy
# @Descripcion 

#Parámetros de entrada
archivoImagenes="${1}"
numImagenes="${2}"
archivoZip="${3}"

#* Funcion ayuda, encargada de mostrar la ayuda en pantalla
function ayuda(){ #Declaración de la función
    #Parametro 1: Código de error
    status="${1}"
    #Mostrando texto de ayuda
    cat s-02-ayuda-sh
    #El comando exit hace que el programa se detenga con el código salida quele indiquemos
    exit "${status}" #Le da exit con el código de error que se le indica, en este caso es el código de error que recibe
}

#* Validando parámetro 1
#El -z verifica si la variable está vacia.
if [ -z "${archivoImagenes}" ]; then #Mucho cuidado con esta estructura, sino manda error
    echo "ERROR: El nombre del archivo de imagenes ${archivoImagenes} no fue especificado" #Echo es un mensaje en consola
    #Invocando a la función ayuda y le mandamos el código de error, en este caso el ejercicio dice que mandemos el 100
    ayuda 100 #Manda a llamar a la función ayuda y le manda el parámetro 100
else #Si se especificó la entrada aun hay que validar algo más:
    #validar que el archivo exista:
    if ! [ -f "${archivoImagenes}" ]; then #Si el archivo no existe entonces:
        echo "ERROR: El archivo de imagenes ${archivoImagenes} no existe"
        ayuda 101 #Manda a llamar a la función
    fi;
fi;

#* Validando parametro 2 (es el número de imagenes)
#La siguiente expresión lo que indica es que numImagenes cumpla con la siguiente expresión regular
if ! [[ "${numImagenes}" =~ [0-9]+ && "${numImagenes}" -gt 0 && "${numImagenes}" -le 90 ]]; then #If con expresión regular lleva doble corchete y una negación
    echo "ERROR: El número de imagenes ${numImagenes} no cumple con la estructura o no está en el rango"
    ayuda 102 #Manda el código de error 102
fi;

#Este if sería cuando si nos especifican el nombre de salida
#* Validando parámetro 3. Recordemos que es opcional
if [ -n "${archivoZip}" ]; then
    #Se especificó ruta y nombre del archivo zip. Hay que validar que la ruta exista.
    #¿Cómo obtengo una ruta a partir de una ruta absoluta? Acontinuación se verá
    dirSalida=$(dirname,"${archivoZip}") #Extrae la ruta del archivo
    nombreZip=$(basename,"${archivoZip}") #Extrae el nombre del archivo
    #A partir de una cadena obtuvimos la dirección y el nombre del archivo unicamente con esos 2 comandos.

    #Valida si un directorio existe
    if ! [ -d "${dirSalida}" ]; then
        echo "ERROR: "
        ayuda 103
    fi;

#Es cuando no se especificó el tercer parametro, es decir, si no se especifica entonces se creará por defecto
#el directorio:
else
    dirSalida="/tmp/${USER}/imagenes"
    #$(date '+%Y-%m-%d-%H-%M-%S') Actua como una función de hecho al ejecutarlo devolverá la fecha en ese formato
    nombreZip="imagenes-$(date '+%Y-%m-%d-%H-%M-%S').zip"
fi; 

#* Validaciones de parámetros concluida



#* Limpiando directorio de salida:
rm "${dirSalida}"/*  #Borrará todo lo que hay dentro del directorio de salida, antes de iterar



#* Descargando Imagenes:
count=0 #Inicializando contador
echo "Obteniendo imagenes, serán guardadas en ${dirSalida}"
#Otra manera de acceder al contenido de un archivo es mediante un WHILE
while read -r linea 
do
    #Obtiene la imagen del URL indicado en el archivo de imagenes
    #wget se usa para obtener la imagen de una url dada
    #-P "${dirSalida}" le indicamos en donde guardará la imagen. El Flag -P indica el directorio donde se descargará ese archivo
    #El flag -q significa Quiet o silencioso por lo que no mostrará nada en consola cuando descargue, sólo lo hará
    wget -q -P "${dirSalida}" "${linea}"
    #Si wget genera un codigo de salida 0 entonces significa que lo hizo bien
    if ! [ ${status} -eq 0 ]; then #Si el código de salida no fue 0 entonces:
        echo "ERROR: ..."
        ayuda 104 #Se invoca la función con el c´dogio 104
    fi;

    if [ "${count}" -ge "${numImagenes}" ]; then
        #Se alcanza el número de imagenes y no necesita iterar
        break;
    fi;

    count=$((count+1)) #count+1 Cuenta el número de líneas.

done < "${archivoImagenes}" #Con este se cierra el ciclo
#Este ciclo recorre el archivo ${archivoImagees} y cada valor de línea lo guarda en la variable "Linea".
#Cuando se usa el operador "<" significa que el contenido de "${archivoImagenes}" va a ser la fuente de entrada de este ciclo. Y cada una de las líneas será guardada en "Linea"
#Hasta aquí las imagenes ya están en el directorio.

#* Construir el archivo zip
#Inicializar variable de entorno
export IMG_ZIP_FILE="${dirSalida}/${nombreZip}"
echo "Generando archivo Zip en ${IMG_ZIP_FILE}"

#Haciendo limpieza del archivo:
rm "${IMG_ZIP_FILE}"

zip -j "${IMG_ZIP_FILE}" "${dirSalida}/" #Crea el Zip y el "-j" Lo que hace es quitar la estructura de carpetas
chmod 600 "${IMG_ZIP_FILE}"


#* Generando archivo de texto
rm "${dirSalida}"/s-00-lista-archivos.txt  #Generando limpieza

unzip -Z1 "${IMG_ZIP_FILE}" > "${dirSalida}"/s-00-lista-archivos.txt #-Z1 lo que hace es obtener todo el contenido de sin descomprimir y con > lo mandamos al archivo.

echo "Listo"