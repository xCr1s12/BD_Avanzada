------------------------------------
------Consultas de prueba de las funciones
------------------------------------


------------------------
------Estado inicial
------------------------
SELECT * FROM cuentas ORDER BY id;

SELECT * FROM movimientos ORDER BY id;


------------------------
------Funcion 1: info_cuenta_cliente
------------------------

-- cuentas existentes
SELECT info_cuenta_cliente(1);

SELECT info_cuenta_cliente(3);

-- cuenta inexistente, se captura la excepcion para que el script continue
DO $$
BEGIN
    PERFORM info_cuenta_cliente(999);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Excepcion capturada -> %', SQLERRM;
END;
$$;


------------------------
------Funcion 3: reporte_cuentas
------------------------

-- sin parametro (DEFAULT 'TODAS')
SELECT * FROM reporte_cuentas();

SELECT * FROM reporte_cuentas('TODAS');

SELECT * FROM reporte_cuentas('ACTIVAS');

SELECT * FROM reporte_cuentas('INACTIVAS');

-- cualquier otro valor retorna todas las cuentas
SELECT * FROM reporte_cuentas('CUALQUIER_COSA');


------------------------
------Funcion 2: procesar_cierre_cuentas
------------------------

-- retorna la cantidad de movimientos procesados
SELECT procesar_cierre_cuentas();

-- cuentas y movimientos despues del cierre
SELECT * FROM cuentas ORDER BY id;

SELECT * FROM movimientos ORDER BY id;


------------------------
------Verificacion final
------------------------

-- saldos actualizados con la funcion 1
SELECT info_cuenta_cliente(id) FROM cuentas ORDER BY id;

-- saldos actualizados con la funcion 3
SELECT * FROM reporte_cuentas('ACTIVAS');