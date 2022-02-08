# Este documento contiene un conjunto de listados utiles para el curso

|Comando|Descripcion|
|--|--|
|`echo`| Imprime en pantalla |
|`chown`| Permite cambiar el propietario del archivo o directorio |
|`chmod`| Permite cambiar los permisos del archivo o directorio |
|`mkdir`| Permite la creación de una carpeta |
|`nano`| Permite editar un archivo |
|`chown oracle:oinstall <archivo_zip>`| Cambia el dueño y el grupo de un archivo en un sólo comando|
|`mv nombreArchivo Destino`| Permite mover de un lugar a otro un archivo |
|`su -l usuario`| Permite cambiar de sesión |
|`rm nombreArchivo`| Permite eliminar un archivo a línea de comandos |
|`xhost +`| Abre permisos para el entorno gráfico |
|`echo $DISPLAY`| Habilita variable para ver interfaz gráfica |
|`export DISPLAY=:0`| Establece el valor de `:0` para que el usuario Oracle sea capaz de ejecutar el entorno gráfico |
|`sqlplus / as sysdba`| Inicia SQL en modo Sistema Operativo |
|`env`| Lista todas las variables de entorno en el sistema |
|`wget`| Sirve para obtener la imagen de una url dada|
|`wc -l`| Retorna el número de líneas de un archivo|
|`zip "${IMG_ZIP_FILE}" "${dirSalida}/"`| Genera un archivo Zip|

## Flags para los comandos
|Flag|Descripción|
|--|--|
|`$USER`| Se trata de una **Variable de entorno** y nos devolverá el usuario actual |
|`$PATH`| Es una lista de directorio donde el sistema encontrará los comandos |
|`-R`| Representa que será una acción recursiva |
|`-z`| Verifica si la variable está vacia |
|`-f`| Valida la existencia de un archivo|
|`-gt 0`| Greater than, Significa mayor que 0 |
|`-ge `| Mayor o igual|
|`-le 90`| Less or equal, Menor o igual a 90 |
|`eq 0`| Igual a cero|
|`-n`| Verifica que el archivo sea NO NULO, si es NO NULO entonces retorna verdadero|
|`-d`| Verifica si un directorio existe|
|`wget -P "${dirSalida}"`| El Flag `-P` indica el directorio donde se descargará ese archivo |
|`wget -q URL`| Lo que hace es descargar la imagen sin imprimir nada en consola, es decir, es un proceso silencioso. |
|`-j`| Quita toda la estructura de carpetas que pudiera tener, es decir, todo el contenido quedaría a nivel raíz. Sin el comando se tendría una estructura de carpetas una dentro de otra|
|`-Z1`| Lo que hace es mostrar el contenido del Zip pero sin descomprimirlo y muestra el nombre de los archivos|
|`>`| La salida de un comando la redirige para guardarla en un archivo por ejemplo `find "cadena" > prueba.txt`|

## Shell

* Para invocar una función primero se pone el nombre, luego un espacio y el parametro que recibirá, por ejemplo `ayuda 100`
* Podemos leer un archivo mediante un While y su estructura es la siguiente: `while ... do ... done < "${archivo}"`

## Permisos
Es muy facil cambiar los permisos, pero para ello primero es mejor consultarlos con el siguiente comando que nos da mucha información al respecto:

`ls -lrst`

Encontrará una estructura como la siguiente:
-- | Permisos | Archivos | Dueño | Grupo | Tamaño | Mes | Día | Hora | Nombre Archivo

Para poder identificar como asignar permisos hay que tener identificado que existen 3 rubros en los que deberemos poner atención, es decir:
* Dueño
* Grupo
* Otros

Cada uno de los rubros anteriormente mencionados necesitan de 3 bits siendo `111` = `rwx` 

Por ejemplo, si el enunciado pide que sólo el dueño pueda leer y escribir en el archivo deberia verse algo así: `110 000 000` => 600 su equivalente decimal es `600`

El permiso `755` permite ejecutar y leer por cualquier usuario

## Comandos para SQLPlus

|Comando|Acción|
|--|--|
|`sqlplus / as sysdba`|Inicia SQL en modo Sistema Operativo|
|`startup`|Inicializa la instancia|

## Ejecución del SQLDeveloper

Sólo basta con ejecutar el siguiente comando desde el usuario administrador normal. `/opt/sqldeveloper/sqldeveloper.sh &`


## Buenas prácticas

* Por convención todas las **Variables de entorno** se ponen en mayusculas para distinguirlas de cualquier otra variable. Con el comando `env` podemos listarlas todas.

