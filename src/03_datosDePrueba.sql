INSERT INTO planes (nombre, tasa_bono, saldo_minimo) VALUES
('Plan Básico', 0.0100, 0.00),         -- 1% de bono, sin saldo mínimo
('Plan Premium', 0.0350, 50000.00),    -- 3.5% de bono, saldo mínimo 50k
('Plan VIP', 0.0500, 100000.00);       -- 5% de bono, saldo mínimo 100k

INSERT INTO clientes (rut, nombre, plan_id) VALUES
('11111111-1', 'Juan Pérez', 1),
('22222222-2', 'María González', 2),
('33333333-3', 'Carlos López', 3),
('44444444-4', 'Ana Rojas', 1);

INSERT INTO cuentas (cli_id, saldo_base, total_bonos, total_cargos, saldo_final, activa) VALUES
(1, 10000.00, 0.00, 0.00, 10000.00, TRUE),
(2, 60000.00, 0.00, 0.00, 60000.00, TRUE),
(3, 150000.00, 0.00, 0.00, 150000.00, TRUE),
(4, 0.00, 0.00, 0.00, 0.00, TRUE); -- Esta cuenta inicia en cero

INSERT INTO movimientos (cta_id, tipo, monto, procesado) VALUES
(1, 'A', 5000.00, FALSE),   -- Abono a cuenta 1
(1, 'C', 2000.00, FALSE),   -- Cargo a cuenta 1
(2, 'A', 15000.00, FALSE),  -- Abono a cuenta 2
(3, 'C', 10000.00, FALSE),  -- Cargo a cuenta 3
(3, 'A', 25000.00, FALSE),  -- Abono a cuenta 3
(4, 'A', 8000.00, FALSE);   -- Abono a cuenta 4 (primer ingreso)