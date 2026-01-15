CREATE SCHEMA IF NOT EXISTS pelu;
SET search_path TO pelu, public;

-- Catálogos
CREATE TABLE IF NOT EXISTS comuna (
  id           BIGSERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS peluqueria (
  id           BIGSERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  comuna_id    BIGINT NOT NULL REFERENCES pelu.comuna(id)
);

CREATE TABLE IF NOT EXISTS cliente (
  id           BIGSERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  comuna_id    BIGINT NOT NULL REFERENCES pelu.comuna(id),
  genero       CHAR(1) NOT NULL CHECK (genero IN ('M','F','X')),
  fecha_nac    DATE
);

CREATE TABLE IF NOT EXISTS empleado (
  id           BIGSERIAL PRIMARY KEY,
  peluqueria_id BIGINT NOT NULL REFERENCES pelu.peluqueria(id),
  nombre       VARCHAR(120) NOT NULL,
  cargo        VARCHAR(40)  NOT NULL
);

CREATE TABLE IF NOT EXISTS peluquero (
  empleado_id  BIGINT PRIMARY KEY REFERENCES pelu.empleado(id)
);

CREATE TABLE IF NOT EXISTS horarios (
  id           BIGSERIAL PRIMARY KEY,
  peluqueria_id BIGINT NOT NULL REFERENCES pelu.peluqueria(id),
  dia_semana   SMALLINT NOT NULL CHECK (dia_semana BETWEEN 0 AND 6),
  hora_inicio  TIME NOT NULL,
  hora_fin     TIME NOT NULL,
  CHECK (hora_fin > hora_inicio)
);

CREATE TABLE IF NOT EXISTS servicio (
  id           BIGSERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  precio_base  NUMERIC(12,2) NOT NULL CHECK (precio_base >= 0),
  activo       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS producto (
  id           BIGSERIAL PRIMARY KEY,
  nombre       VARCHAR(120) NOT NULL,
  precio       NUMERIC(12,2) NOT NULL CHECK (precio >= 0),
  activo       BOOLEAN NOT NULL DEFAULT TRUE
);

-- Transaccionales
CREATE TABLE IF NOT EXISTS cita (
  id            BIGSERIAL PRIMARY KEY,
  peluqueria_id BIGINT NOT NULL REFERENCES pelu.peluqueria(id),
  cliente_id    BIGINT NOT NULL REFERENCES pelu.cliente(id),
  peluquero_id  BIGINT NOT NULL REFERENCES pelu.peluquero(empleado_id),
  fecha         DATE NOT NULL,
  hora_inicio   TIME NOT NULL,
  hora_fin      TIME NOT NULL,
  CHECK (hora_fin > hora_inicio)
);

CREATE TABLE IF NOT EXISTS detalle (
  id             BIGSERIAL PRIMARY KEY,
  cita_id        BIGINT NOT NULL REFERENCES pelu.cita(id),
  tipo_item      VARCHAR(10) NOT NULL,   -- 'SERVICIO' | 'PRODUCTO'
  servicio_id    BIGINT REFERENCES pelu.servicio(id),
  producto_id    BIGINT REFERENCES pelu.producto(id),
  cantidad       INTEGER NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
  total          NUMERIC(12,2) NOT NULL CHECK (total >= 0),
  CHECK (tipo_item IN ('SERVICIO','PRODUCTO')),
  CHECK (
    (tipo_item='SERVICIO' AND servicio_id IS NOT NULL AND producto_id IS NULL) OR
    (tipo_item='PRODUCTO' AND producto_id IS NOT NULL AND servicio_id IS NULL)
  )
);

CREATE TABLE IF NOT EXISTS pago (
  id         BIGSERIAL PRIMARY KEY,
  cita_id    BIGINT NOT NULL REFERENCES pelu.cita(id),
  fecha_pago DATE NOT NULL,
  metodo     VARCHAR(20) NOT NULL,
  monto      NUMERIC(12,2) NOT NULL CHECK (monto >= 0)
);

-- Índices sugeridos
CREATE INDEX IF NOT EXISTS ix_peluqueria_comuna        ON pelu.peluqueria(comuna_id);
CREATE INDEX IF NOT EXISTS ix_cliente_comuna           ON pelu.cliente(comuna_id);
CREATE INDEX IF NOT EXISTS ix_empleado_pelu            ON pelu.empleado(peluqueria_id);
CREATE INDEX IF NOT EXISTS ix_cita_pelu_fecha_hora     ON pelu.cita(peluqueria_id, fecha, hora_inicio);
CREATE INDEX IF NOT EXISTS ix_pago_cita_fecha          ON pelu.pago(cita_id, fecha_pago);
CREATE INDEX IF NOT EXISTS ix_detalle_cita             ON pelu.detalle(cita_id);
