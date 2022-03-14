

## Loop devices
Se formatean con la **`ext4`** 

## PFile y SPfile
El archivo init.ora es una plantilla unicamente para crear un PFILE. (Sólo plantilla)


Cada usuario tiene asociado su esquema, el esquema está relacionado a un tablespace y cada tablescpace está relacionado a un datafile.
Normalmente para los usuarios creados se usa el tablespace se usa `users`

Table spaces:
* System, guarda todos los datos importantes que se necesitan
* Sysaux, son datos adicionales que no son tan necesarios
* Users, Es donde se guardan datos de los usuarios a crear.
* Tmp, es como el área de swap, es donde se guardan calculos temporales o así.
* Undo, la versión antigua de los datos se guardan aqui para hace run rollback

Cada tablespace debe estár asociado como minimo a una datafile.
estos archivos se llaman `nombreTablespace.dbf`


El **@** le indica a SQL que abra el archivo y ejecute, por ejemplo:
@?/rdbms/admin/catalog.sql


## Tipos de valores segun el nivel:
Los valores pueden estar diferentes a nivel: Sesión, SPfile y a nivel memoria.


* Consulta a nivel SPFILE:
    `show spparameter nls_date_format`

* Consulta a nivel Instancia (memoria):
    `show parameters nls_date_format`

* Consulta a nivel sesion:
    `select value from v$parameter where name='nls_date_format';`

    El valor de la sesión se hereda desde la instancia o memoria, pero podemos modificar estos valores sólo para el nivel de la sesion, a continuación vemos un ejemplo:

    `alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';`

    Y volviendo a realizar la consulta veremos reflejado el valor:

    `select value from v$parameter where name='nls_date_format';`

## Parametros estáticos o dinámicos

* Parámetros dinámicos: Los cambios toman efecto de forma inmediata sin
requerir reinicio.
* Parámetros estáticos: Los cambios no toman efecto en la instancia de forma inmediata. Se deben
escribir al SPFILE y requieren reinicio.

### Cambio de valor a nivel sesion, instancia o spfile
* Un parametro estático no tiene sentido ponerlo a nivel memoria o sesión porque se perderían al cerrar sesión o cuando apague la memoria.

* Cuando es a nivel sesión `alter session set <parametro>=<valor>;`
* Para intancia o SPFILE se usa `alter system set <pametro>=<valor>`

El scope sólo aplica para **Alter system**, y se puede especificar si es a nivel memoria(instancia) o a nivel SPFILE, si queremos que en ambos se aplique entonces se poner `Both`

Marcará error si queremos modificar el SPFILE pero iniciamos la instancia con el PFILE, esto no es posible.

* Instrucción `alter system reset <parametro> [scope={spfile|memory|both}]`: Nos sirve para regresar el valor de un parametro a su valor original.

Un parametro puede tener valor en: sesión, instancia y spfile.

* La desventaja de iniciar la instancia con PFILE es que no podemos modificar los valores de los parametros.

|Tipo de cambio|Significado|
|--|--|
|`ìnmediate`|Se aplica para valores dinámicos y puede verse reflejado directamente a nivel instancia o a nivel sesion. No importa si se inició mediante spifile o no, debido a que los cambios los hace a nivel memoria|
|`deferred`|Como su nombre lo dice, es necesario reiniciar la sesión, puede aplicarse a nivel sesion, pero para que aun guarde deberia hacerse desde memoria.Tampoco importa si es iniciado mediante PFILE o SPFILE|
|`false`|Es para valores estaticos, la unica opción es haber iniciado sesión desde un SPFILE. Para ello deberia ser mediante `alter system`|

**Ejemplo**: `alter system set x=y;` Si se levanta con un PFILE y quisieramos establecerlo nos marcaria error debido a que el Scope es **false**, pero esto marca error por que no se habia especificado el scope, pero nos mencionará que no es aplicable para memoria (Alter system es solo spfile). Deberiamos poner lo siguiente **`alter system set x=y scope=spfile;`** 

### Obtener un SPFILE de prueba desde memeoria
Si quisieramos obtener un SPFILE de prueba para poder testear el cambio del valor en los parametros podriamos hacer lo siguiente:
* `create spfile=/tmp/spfile_test from memory` Si no se le pusiera la ruta entonces sobreescribe el actual spfile

### Ejercicio de clase 1:

|Parametro|Significado|
|--|--|
|`issies_modifiable`|Nos indica si es modificable a nivel sesión|
|`issys_modifiable`|Significa que es estático. si tuvieramos False en esa columna significaría que el nuevo valor sólo aplicaria a nivel sesión, al cerrar sesión se perdería el valor. Para modificar el valor tendriamos que usar `alter system`|

Se recomienda generar un usuario por cada tema:
**`create user yanni02 identified by yanni quota unlimited on users`**
y asignar los privilegios de:
**`grant create session, create table to yanni02`**

### Casos de ejemplos en la vida real:

Si se nos presentara un caso en el que cambiamos el parametro y hace que truene
la instancia al leventar, ¿Cuales serian los pasos a seguir?

1. Crear un PFILE 
2. Modificarlo y haciendo correcciones al valor.
3. startup pfile=path/ 
4. Crear SPFILE (este nuevo sobreescribirá el anterior)
5. Hacer un shutdown de la base
6. Startup solito sin el parametro del PFILE.

En el alert log podriamos ver porque la instancia no levantó

**otro caso**
Tenemos un SPFILE corrupto y no tenemos un respaldo reciente de parte del PFILE
por lo que está obsoleto, ¿Qué harias?

Checariamos el ALERT LOG porque mostraría los parametros de la ultima vez que la
base levantó correctamente. Mostraria todos los parametros que tenia el SPFILE
A partir de esa lista podriamos crear un PFILE y y reperir los pasos.