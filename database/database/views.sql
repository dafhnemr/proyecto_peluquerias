-- database/views.sql
SET search_path TO pelu, public;

-- Q1: horario con más citas por día y peluquería (incluye comuna)
CREATE OR REPLACE VIEW pelu.vw_top_horario_por_dia AS
SELECT *
FROM (
  SELECT
    p.id AS peluqueria_id,
    p.nombre AS peluqueria,
    cm.nombre AS comuna_peluqueria,
    c.fecha,
    date_trunc('hour', c.hora_inicio)::time AS hora,
    COUNT(*) AS total_citas,
    ROW_NUMBER() OVER (
      PARTITION BY p.id, c.fecha
      ORDER BY COUNT(*) DESC, date_trunc('hour', c.hora_inicio)
    ) AS rn
  FROM pelu.cita c
  JOIN pelu.peluqueria p ON p.id = c.peluqueria_id
  JOIN pelu.comuna cm    ON cm.id = p.comuna_id
  GROUP BY p.id, p.nombre, cm.nombre, c.fecha, date_trunc('hour', c.hora_inicio)
) t
WHERE rn = 1;

-- Q2: cliente que más gasta por mes y peluquería (incluye comunas)
CREATE OR REPLACE VIEW pelu.vw_top_gasto_mensual_por_peluqueria AS
SELECT *
FROM (
  SELECT
    p.id AS peluqueria_id, p.nombre AS peluqueria,
    cm_p.nombre AS comuna_peluqueria,
    cl.id AS cliente_id, cl.nombre AS cliente,
    cm_c.nombre AS comuna_cliente,
    date_trunc('month', pg.fecha_pago)::date AS mes,
    SUM(pg.monto) AS total_gastado,
    ROW_NUMBER() OVER (
      PARTITION BY p.id, date_trunc('month', pg.fecha_pago)
      ORDER BY SUM(pg.monto) DESC, cl.id
    ) AS rn
  FROM pelu.pago pg
  JOIN pelu.cita c       ON c.id = pg.cita_id
  JOIN pelu.peluqueria p ON p.id = c.peluqueria_id
  JOIN pelu.comuna cm_p  ON cm_p.id = p.comuna_id
  JOIN pelu.cliente cl   ON cl.id = c.cliente_id
  JOIN pelu.comuna cm_c  ON cm_c.id = cl.comuna_id
  GROUP BY p.id, p.nombre, cm_p.nombre, cl.id, cl.nombre, cm_c.nombre,
           date_trunc('month', pg.fecha_pago)
) t
WHERE rn = 1;
