# Entregable 1: Cierre de Cuentas y Bonificaciones (PostgreSQL / PL/pgSQL)

Proyecto desarrollado para la asignatura **Bases de Datos Avanzadas** de la **Universidad de Los Lagos**.

## Descripción

Una cooperativa de ahorro y crédito necesita automatizar el procesamiento de los movimientos diarios (abonos y cargos) y la asignación de bonificaciones por permanencia de sus clientes. Este proyecto implementa, en PostgreSQL:

- El esquema relacional (tablas y restricciones de integridad).
- Datos de prueba.
- Tres funciones almacenadas en PL/pgSQL.
- Consultas que demuestran el funcionamiento de cada función.

### Modelo de datos

| Tabla | Campos principales |
|-------|--------------------|
| `planes` | `id` (PK), `nombre`, `tasa_bono`, `saldo_minimo` |
| `clientes` | `id` (PK), `rut` (UNIQUE), `nombre`, `plan_id` (FK → planes) |
| `cuentas` | `id` (PK), `cli_id` (FK → clientes, UNIQUE), `saldo_base`, `total_bonos`, `total_cargos`, `saldo_final`, `activa` |
| `movimientos` | `id` (PK), `cta_id` (FK → cuentas), `fecha`, `tipo` (`'A'` abono / `'C'` cargo), `monto` (> 0), `procesado` |

### Reglas de negocio

1. Cada cliente tiene un único plan y una única cuenta.
2. Si el `saldo_base` es mayor o igual al `saldo_minimo` del plan, la cuenta recibe un bono: `saldo_base × tasa_bono / 100`.
3. Los movimientos nacen con `procesado = FALSE` y pasan a `TRUE` al ser incluidos en el cierre.
4. `saldo_final = saldo_base + total_bonos - total_cargos`.

### Funciones implementadas

| Función | Descripción |
|---------|-------------|
| `info_cuenta_cliente(ID_CUENTA INT)` | Retorna un texto con nombre del titular, RUT, plan y saldo final. Lanza excepción si la cuenta no existe. |
| `procesar_cierre_cuentas()` | Recorre las cuentas activas, acumula abonos y cargos pendientes, marca los movimientos como procesados, calcula el bono del plan y actualiza la cuenta. Retorna la cantidad de movimientos procesados. |
| `reporte_cuentas(p_filtro VARCHAR DEFAULT 'TODAS')` | Retorna una tabla con id de cuenta, cliente, saldo y estado. Filtros: `'ACTIVAS'`, `'INACTIVAS'` o cualquier otro valor para todas. |

## Estructura de carpetas

```
.
├── entregable1.sql          # Archivo maestro: ejecuta todos los scripts en orden
├── README.md                # Este archivo
├── .gitignore               # Archivos ignorados por Git
└── src/
    ├── 01_tablas.sql          # Creación de tablas y restricciones (PK, FK, UNIQUE, CHECK)
    ├── 02_funciones.sql       # Las 3 funciones PL/pgSQL
    ├── 03_datosDePrueba.sql   # INSERT de planes, clientes, cuentas y movimientos
    └── 04_consultas.sql       # SELECT de prueba para cada función
```

### Contenido de cada archivo

- **`entregable1.sql`**: script maestro. Usa `\i` de psql para incluir los archivos de `src/` en este orden: tablas, funciones, datos de prueba y consultas.
- **`src/01_tablas.sql`**: define `planes`, `clientes`, `cuentas` y `movimientos` con sus claves primarias, foráneas, `UNIQUE` y `CHECK` (`tipo IN ('A','C')`, `monto > 0`).
- **`src/02_funciones.sql`**: código de `info_cuenta_cliente`, `procesar_cierre_cuentas` y `reporte_cuentas`.
- **`src/03_datosDePrueba.sql`**: datos de ejemplo (mínimo 3 planes, 4 clientes, 4 cuentas y 6 movimientos), incluyendo cuentas activas e inactivas.
- **`src/04_consultas.sql`**: sentencias `SELECT` que prueban cada función, incluido el caso de error por cuenta inexistente.
- **`.gitignore`**: excluye archivos que no deben versionarse.

## Requisitos

- PostgreSQL 12 o superior.
- Cliente `psql` (los comandos `\i` y `\echo` solo funcionan en psql, no en otros clientes gráficos).

## Cómo ejecutar

1. Crear la base de datos:

   ```bash
   createdb -U postgres cooperativa
   ```

2. Situarse en la **raíz del proyecto** (las rutas `\i src/...` son relativas a esta carpeta):

   ```bash
   cd ruta/al/proyecto
   ```

3. Ejecutar el archivo maestro:

   ```bash
   psql -U postgres -d cooperativa -f entregable1.sql
   ```

   O desde dentro de psql:

   ```sql
   \c cooperativa
   \i entregable1.sql
   ```

4. Para volver a ejecutar desde cero, recrear la base de datos:

   ```bash
   dropdb -U postgres cooperativa && createdb -U postgres cooperativa
   ```

### Ejecución manual de las pruebas

```sql
-- Función 1: información de una cuenta
SELECT info_cuenta_cliente(1);

-- Función 1: caso de error (cuenta inexistente)
SELECT info_cuenta_cliente(999);

-- Función 2: cierre de cuentas (retorna movimientos procesados)
SELECT procesar_cierre_cuentas();

-- Función 3: reportes
SELECT * FROM reporte_cuentas();
SELECT * FROM reporte_cuentas('ACTIVAS');
SELECT * FROM reporte_cuentas('INACTIVAS');
```

> Los mensajes `RAISE NOTICE` de `procesar_cierre_cuentas` se muestran en la consola de psql.