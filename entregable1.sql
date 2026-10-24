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

\echo 'Finalizado'