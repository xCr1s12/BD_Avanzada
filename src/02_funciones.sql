
-- FUNCION que retorna la info de la cuenta en base a el id de la cuenta a buscar
-- params (ID_CUENTA) es la cuenta que se esta buscando su informacion 
CREATE OR REPLACE FUNCTION info_cuenta_cliente(ID_CUENTA INT)
RETURNS VARCHAR as $$
DECLARE 

    -- se declara Nombre del cliente, rut, nombre del plan y saldo final (actual de la cuenta)
    NOMBRE_CLIENTE clientes.nombre%TYPE;
    RUT clientes.rut%TYPE;
    NOMBRE_PLAN planes.nombre%TYPE;
    SALDO_FINAL cuentas.saldo_final%TYPE;
BEGIN 

    -- Query que busca los datos en las tabas de clientes, planes y cuentas

    SELECT clientes.nombre, clientes.rut, planes.nombre, cuentas.saldo_final
    INTO NOMBRE_CLIENTE, RUT, NOMBRE_PLAN, SALDO_FINAL
    FROM clientes 
    JOIN planes on clientes.plan_id = planes.id 
    JOIN cuentas on cuentas.cli_id = clientes.id
    WHERE cuentas.id = ID_CUENTA;

    -- condicional NOT FOUND 
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: La cuenta con ID % no existe', ID_CUENTA;
    END IF;

    -- TEXTO FORMATEADO con la informacion de la cuenta
    RETURN FORMAT('INFORMACION DE LA CUENTA: NOMBRE DEL TITULAR: %s RUT: %s  Plan Asociado: %s  Saldo Final: %s', NOMBRE_CLIENTE,RUT, NOMBRE_PLAN, SALDO_FINAL);
END;

$$ LANGUAGE plpgsql; 


------------------------------------------------------------------------------------------------------------------------------------------------------



-- FUNCION PARA PROCESAR EL cierre de cuenta, sin parametros de entrada
CREATE OR REPLACE FUNCTION procesar_cierre_cuentas()
RETURNS INTEGER as $$ 
DECLARE 
    
    -- DECLARAMOS CUENTA Y MOVIMIENTO que son records == datos que nacen vacios y toman forma en un bucle 
    -- BONOS_ACUMULADOS Y CARGOS ACUMULADOS son acumuladores (variables auxiliares para acumular movimientos cargos/bonos)
    -- TOTAL PROCESADOS ES EL CONTADOR DE PROCESOS 
    -- BONO SOLO SE OCUPA SI SE CUENTA CON LOS REQUISITOS
    -- SALDO MINIMO Y TASA DE BONO son para verificar si se cumple con los requisitos del plan 

    CUENTA RECORD;
    MOVIMIENTO RECORD;
    CARGOS_ACUMULADOS NUMERIC;  
    BONOS_ACUMULADOS NUMERIC; 
    TOTAL_PROCESADOS INT := 0;
    BONO NUMERIC; 
    v_saldo_minimo planes.saldo_minimo%TYPE; 
    v_tasa_bono planes.tasa_bono%TYPE;

BEGIN 

    -- PRIMER BUCLE para encontrar la cuentas activas
    FOR CUENTA IN 
        SELECT c.id, c.saldo_base, cl.plan_id
        FROM cuentas c
        JOIN clientes cl ON cl.id = c.cli_id
        WHERE c.activa = TRUE 
    LOOP 
        SELECT p.saldo_minimo, p.tasa_bono
        INTO v_saldo_minimo, v_tasa_bono
        FROM planes AS p
        WHERE p.id = CUENTA.plan_id;
    


        CARGOS_ACUMULADOS := 0;  
        BONOS_ACUMULADOS := 0; 
        BONO := 0; 
        
        --SEGUNDO BUCLE para recorrer los movimientos asociados a la cuenta
        FOR MOVIMIENTO IN 
            SELECT id, monto, tipo
            FROM movimientos as M
            where M.procesado = FALSE AND M.cta_id = CUENTA.id 
        LOOP 

            -- CONDICIONAL para cumular MONTOS a BONOS o CARGOS
            if MOVIMIENTO.tipo = 'C' THEN 
                CARGOS_ACUMULADOs := CARGOS_ACUMULADOS + MOVIMIENTO.monto;

            ELSIF MOVIMIENTO.tipo = 'A' THEN 
                BONOS_ACUMULADOS := BONOS_ACUMULADOS + MOVIMIENTO.monto; 

            ELSE
                RAISE EXCEPTION 'tipo de movimiento desconocido %', MOVIMIENTO.tipo;  
            END IF; 

            -- update en el movmiento para no hacer doble conteo 
            UPDATE movimientos
                set procesado = TRUE
                WHERE id = MOVIMIENTO.id;
            
            
            TOTAL_PROCESADOS := TOTAL_PROCESADOS + 1;
        
        END LOOP; 

        -- Verificar si la cuenta cumple con los requisitos para el bono del plan         
        IF CUENTA.saldo_base >= v_saldo_minimo THEN
            BONO := CUENTA.saldo_base * (v_tasa_bono / 100);
            RAISE NOTICE 'Se emitio un bono por el plan asociado a la cuenta';
        END IF;


        -- Updatear los datos de la cuenta 
            UPDATE cuentas 
                SET total_bonos = BONOS_ACUMULADOS + BONO,
                    total_cargos = CARGOS_ACUMULADOS,
                    saldo_final = CUENTA.saldo_base + (BONOS_ACUMULADOS + BONO) - CARGOS_ACUMULADOs
                WHERE id = CUENTA.id;
    END LOOP;  

    RETURN TOTAL_PROCESADOS;
END; 

$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------------------------------------------------------


-- FUNCION PARA EL REPORTE PARAMETRIZADO DE CUENTAS
-- params de entrada (p_filtro) para filtrar las cuentas según su estado
-- y utiliza parámetros OUT junto con RETURN QUERY para retornar registros (SETOF RECORD)
CREATE OR REPLACE FUNCTION reporte_cuentas(
    IN p_filtro VARCHAR DEFAULT 'TODAS',
    OUT out_cuenta_id INT,
    OUT out_cliente VARCHAR,
    OUT out_saldo NUMERIC,
    OUT out_activa BOOLEAN
)
RETURNS SETOF RECORD AS $$ 
BEGIN 
    -- CONDICIONAL PARA EVALUAR EL FILTRO  
    IF p_filtro = 'ACTIVAS' THEN 
        RETURN QUERY 
        SELECT c.id, cl.nombre, c.saldo_final, c.activa
        FROM cuentas AS c
        JOIN clientes AS cl ON c.cli_id = cl.id
        WHERE c.activa = TRUE;

    ELSIF p_filtro = 'INACTIVAS' THEN 
        RETURN QUERY 
        SELECT c.id, cl.nombre, c.saldo_final, c.activa
        FROM cuentas AS c
        JOIN clientes AS cl ON c.cli_id = cl.id
        WHERE c.activa = FALSE;

    ELSE 
        RETURN QUERY 
        SELECT c.id, cl.nombre, c.saldo_final, c.activa
        FROM cuentas AS c
        JOIN clientes AS cl ON c.cli_id = cl.id;

    END IF; 
END; 
$$ LANGUAGE plpgsql;