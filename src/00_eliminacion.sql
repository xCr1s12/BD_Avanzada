
------------------------
------Eliminar funciones
------------------------
DROP FUNCTION IF EXISTS info_cuenta_cliente(INT);
DROP FUNCTION IF EXISTS procesar_cierre_cuentas();
DROP FUNCTION IF EXISTS reporte_cuentas(VARCHAR);

------------------------
------Eliminar tablas
------------------------

DROP TABLE IF EXISTS movimientos CASCADE;
DROP TABLE IF EXISTS cuentas CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS planes CASCADE;

------------------------
------Eliminar esquema 
------------------------

-- El proyecto trabaja en el esquema public, que no se debe eliminar.
-- Si se usara un esquema propio, descomentar y ajustar el nombre:
-- DROP SCHEMA IF EXISTS cooperativa CASCADE;