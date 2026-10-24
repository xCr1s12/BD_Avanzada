------------------------------------
------Archivo Maestro Entregable 1
------------------------------------


\echo 'Iniciando despliegue de Base de Datos...'

------------------------
------Crear las tablas
------------------------
\i src/01_tablas.sql


------------------------
------Crear las Funciones
-------------------------
\i src/02_funciones.sql

------------------------
------Datos de Prueba
------------------------
\i src/03_datosDePrueba.sql

------------------------
--------Consultas
------------------------
\i src/04_consultas.sql
\echo 'Finalizado'