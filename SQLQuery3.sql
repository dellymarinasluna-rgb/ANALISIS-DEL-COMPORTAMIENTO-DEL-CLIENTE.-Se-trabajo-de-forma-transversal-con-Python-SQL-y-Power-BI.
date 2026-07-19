--1.Ingresos por género – Comparación de los ingresos 
--totales generados por clientes hombres frente a mujeres

select sexo, sum(monto_de_compra) as TotalComprado
from cliente
group by sexo


--2.Usuarios de descuentos con alto gasto - Identificación de clientes que
--utilizaron descuentos pero cuyo gasto superó el importe medio de compra
SELECT IDCLIENTE,monto_de_compra
FROM CLIENTE
WHERE descuento_aplicado= 'YES' AND monto_de_compra>=59(SELECT AVG(monto_de_compra) from cliente)



--59 ES EL PROMEDIO
SELECT AVG(monto_de_compra) FROM CLIENTE


--3 Los 5 productos mejor valorados
-- Identificación de los productos con las valoraciones(COMENTARIOS) medias más altas.

SELECT TOP 5articulo_comprado,
       CAST(AVG(calificacion_del_cliente) AS DECIMAL(10,2)) AS promedio_calificacion_cliente
FROM cliente
GROUP BY articulo_comprado
ORDER BY CAST(AVG(calificacion_del_cliente) AS DECIMAL(10,2)) DESC;

--4. Comparación de tipos de envio
--Comparación de lo importes medios de compra entre envios estándar y exprés.
SELECT tipo_de_envio,
       AVG(monto_de_compra) AS promedio_monto_de_compra
FROM cliente
WHERE tipo_de_envio IN ('Standard', 'Express')
GROUP BY tipo_de_envio;

--5. Suscriptores frente a no suscriptores 
--Compraración del gasto medio y los ingresos totales según el estado de suscripción.

SELECT estado_de_suscripcion,
       COUNT(idcliente) AS total_de_clientes,
       AVG(monto_de_compra) AS gasto_promedio,
       SUM(monto_de_compra) AS total_comprado
FROM cliente
GROUP BY estado_de_suscripcion
ORDER BY total_comprado DESC, gasto_promedio DESC;

--6. Productos con alta dependencia de descuentos 
--Identificación de los 5 productos con mayor porcentaje 
--de compras realizadas con descuento.
SELECT top 5 articulo_comprado,
       ROUND(
           100.0 * SUM(CASE
                          WHEN descuento_aplicado = 'Yes' THEN 1
                          ELSE 0
                       END) / COUNT(*),
           2
       ) AS tasa_de_descuento
FROM cliente
GROUP BY articulo_comprado
ORDER BY tasa_de_descuento DESC;

-- 7.Segmentación de clientes 
--Clasificación de los clientes en segementos (nuevos, recurrerentes y fieles)
--según su historial de compras.

with tipo_cliente as (
select idcliente,compras_anteriores,
CASE
   WHEN compras_anteriores = 1 then 'Nuevo'
   when compras_anteriores between 2 and 10 then 'Recurrente'
   else 'Leal'
   end as Segmento_cliente
from cliente)

select Segmento_Cliente, count(*) as Numero_de_clientes
from tipo_cliente
group by Segmento_Cliente

-- 8. Los 3 mejores productos por categoria
--Listado de los productos más comprados en cada categoria


WITH CUENTADEARTICULOS AS
(
    SELECT
        CATEGORIA,
        ARTICULO_COMPRADO,
        COUNT(IDCLIENTE) AS TOTAL_DE_PEDIDOS,
        ROW_NUMBER() OVER
        (
            PARTITION BY CATEGORIA
            ORDER BY COUNT(IDCLIENTE) DESC
        ) AS RANKING_DE_PRODUCTOS
    FROM CLIENTE
    GROUP BY
        CATEGORIA,
        ARTICULO_COMPRADO
)

SELECT
    RANKING_DE_PRODUCTOS,
    CATEGORIA,
    ARTICULO_COMPRADO,
    TOTAL_DE_PEDIDOS
FROM CUENTADEARTICULOS
WHERE RANKING_DE_PRODUCTOS <= 3;



-- 9. Clientes recurrentes y suscripciones - Análisis de si los clientes con más de
-- 5 compras tienen mayor probabilidad de suscribirse.

select estado_de_suscripcion,
       count(idcliente) as Compras_recurentes
from cliente
where compras_anteriores >5
group by estado_de_suscripcion