


CREATE TABLE planes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tasa_bono NUMERIC(5, 4) NOT NULL,
    saldo_minimo NUMERIC(12, 2) NOT NULL
);

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    plan_id INT NOT NULL REFERENCES planes(id)
);

CREATE TABLE cuentas (
    id SERIAL PRIMARY KEY,
    cli_id INT NOT NULL UNIQUE REFERENCES clientes(id),
    saldo_base NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_bonos NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_cargos NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    saldo_final NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    activa BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE movimientos (
    id SERIAL PRIMARY KEY,
    cta_id INT NOT NULL REFERENCES cuentas(id),
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo CHAR(1) NOT NULL CHECK (tipo IN ('A', 'C')),
    monto NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
    procesado BOOLEAN NOT NULL DEFAULT FALSE
);

