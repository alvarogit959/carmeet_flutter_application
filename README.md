# Carmeet_flutter_application


## Elementos base 
Primero hay que instalar las dependencias:
npm install
npm install bcrypt 
npm install flutter  
Instalar correctamente la SDK y los elementos dentro de la carpeta del proyecto.
Tras ello deberia de lanzarse la app correctamente
Tras ello hay que instalar Flutter
## Run de la app 
El primer paso es iniciar el server, que lo guardé dentro del proyecto de vue, recomiendo ver ese documento primero. Para lanzar el server hay que lanzarla dentro de su carpeta con:

node .\serverVueElectron.js

Para lanzar la app correctamente primero hay que abrir el proyecto en Visual Studio y abrir el Emulador en Android Studio,
tras ello usar:

flutter pub get

Si la app muestra artefactos usar este comando!:

flutter run --no-enable-impeller

Tras ello dentro de main.dart preferiblemente:

Presiona F5 start debugging

Con esto debería de abrirse la app correctamente en el emulador.
Esta app en estructura y visualmente es practicamente la misma que la de vue, siendo simplemente adaptada para Flutter.
Dentro de la documentación de Vue esta la documentación completa de uso, siendo la misma.

## Errores encontrados:
Esta parte del trabajo fue mucho mas sencilla debido a que ya tenía la base de datos de Mongo creada correctamente y el server, teniendo que adaptar las funciones y el diseño a app movil. 

El problema mas grande que me encontré fue adaptar la lectura de fechas y horas para que lo lea correctamente, dando numerosos errores e incluso subiendo elementos corruptos a la base de datos.

En tema visual fue sencillo debido a que sabía exactamente que estructura utilizar, siendo la misma que la de escritorio pero ajustada. Errores fueron principalmente por elementos que fueron dificiles de adaptar,
siendo complicado añadir el fondo correctamente.
La app tiene un bug en el cual aparecen artefactos, solo pasa en el ordenador de clase y no en el mio, desactivndo impeller lo arregla.
