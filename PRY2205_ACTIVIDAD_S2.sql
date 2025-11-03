--Lucas Silva Adasme - Frank Cordoba Alvarez / Grupo N°3 / Analista y Programador Computacional
-----------------------------------------------------------------------------------------------
--                                       Actividad Formativa N°2
--                                       -----------------------

  
--Caso 1: Análisis de Facturas
--(segun figura 2)

SELECT
    f.numfactura AS "N° Factura",   
    INITCAP(TO_CHAR(f.fecha, 'DD "de" Month')) AS "Fecha Emisión",
    LPAD(f.rutcliente, 10, '0') AS "RUT Cliente",
    '$' || TO_CHAR(f.neto, 'FM999G999G999') AS "Monto Neto",
    '$' || TO_CHAR(f.iva, 'FM999G999G999') AS "Monto Iva",
    '$' || TO_CHAR(f.total, 'FM999G999G999') AS "Total Factura",
    
    CASE 
        WHEN f.total BETWEEN 0 AND 50000 THEN 'Bajo'
        WHEN f.total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",
    
    CASE 
        WHEN f.codpago = 1 THEN 'EFECTIVO'
        WHEN f.codpago = 2 THEN 'TARJETA DEBITO'
        WHEN f.codpago = 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de Pago"
    
FROM
    factura f
WHERE
    EXTRACT(YEAR FROM f.fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY
    f.fecha DESC,
    f.neto DESC;
    
--------------------------------------------------------------------------------

--Caso 2: Clasificación de Clientes
--(Según figura 3)
    
SELECT
    LPAD(REVERSE(rutcliente), 12, '*') AS "RUT",
    nombre AS "Cliente",
    NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
    estado AS "ESTADO",
 
    CASE 
        WHEN saldo / credito < 0.5 THEN 'Bueno: ' || TO_CHAR(credito - saldo, '999G999G999')
        WHEN saldo / credito BETWEEN 0.5 AND 0.8 THEN 'Regular: ' || TO_CHAR(saldo, '999G999G999')
        ELSE 'Crítico'
    END AS "Estado Crédito",
    
    CASE 
        WHEN mail IS NULL THEN 'Correo no registrado'
        ELSE UPPER(SUBSTR(mail, INSTR(mail, '@') + 1))
    END AS "Dominio Correo"

FROM cliente
WHERE estado = 'A'
  AND credito > 0
ORDER BY nombre ASC;
--------------------------------------------------------------------------------

--Caso 3: Stock de productos
--(según figura 4)

SELECT
    codproducto AS "ID",
    descripcion AS "Descripción de Producto",
    NVL(TO_CHAR(valorcompradolar, '999G999D99') || ' USD', 'Sin registro') AS "Compra en USD",
    
    CASE 
        WHEN valorcompradolar IS NOT NULL THEN '$' || TO_CHAR(valorcompradolar * &TIPOCAMBIO_DOLAR, '999G999G999') || ' PESOS'
        ELSE 'N/A'
    END AS "USD convertido",
    totalstock AS "Stock",

    CASE
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",

    CASE
        WHEN totalstock > 80 THEN '$' || TO_CHAR(vunitario * 0.9, '999G999G999')
        ELSE 'N/A'
    END AS "Precio Oferta"

FROM producto
WHERE UPPER(descripcion) LIKE '%ZAPATO%' 
  AND LOWER(procedencia) = 'i'
ORDER BY 
    CASE WHEN UPPER(descripcion) LIKE '%MUJER%' THEN 1 ELSE 2 END,
    codproducto DESC;
    
    