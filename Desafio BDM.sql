-- CREACION DE LA BASE DE DATOS

CREATE DATABASE ARTE;

USE ARTE;

CREATE TABLE PIEZAS (
cod_pieza CHAR(5) PRIMARY KEY NOT NULL,
nombre_pieza VARCHAR(50)
)

CREATE TABLE EXPOSICION (
id_exposicion CHAR(5) PRIMARY KEY NOT NULL,
cod_pieza CHAR(5),
id_pintor CHAR(5),
precio DECIMAL(10,2)
)

CREATE TABLE PINTORES (
id_pintor CHAR(5) PRIMARY KEY NOT NULL,
nombre VARCHAR(30)
)

-- CREACION DE LAS RELACIONES ENTRE LAS TABLAS

ALTER TABLE EXPOSICION ADD CONSTRAINT FK_EXPO_PINTOR FOREIGN KEY (id_pintor) REFERENCES PINTORES(id_pintor)
ALTER TABLE EXPOSICION ADD CONSTRAINT FK_EXPO_PIEZA FOREIGN KEY (cod_pieza) REFERENCES PIEZAS(cod_pieza)

-- INSERTANDO LOS DATOS A LAS TABLAS

INSERT PIEZAS VALUES ('PA001', 'La última cena')
INSERT PIEZAS VALUES ('PA002', 'La Gioconda')
INSERT PIEZAS VALUES ('PA003', 'La Noche Estrellada')
INSERT PIEZAS VALUES ('PA004', 'Las Tres Gracias')
INSERT PIEZAS VALUES ('PA005', 'El grito')
INSERT PIEZAS VALUES ('PA006', 'La Guernica')
INSERT PIEZAS VALUES ('PA007', 'La Creación de Adán')
INSERT PIEZAS VALUES ('PA008', 'Los Girasoles')
INSERT PIEZAS VALUES ('PA009', 'La Tentación de San Antonio')
INSERT PIEZAS VALUES ('PA010', 'Los fusilamiento del 3 de mayo')
INSERT PIEZAS VALUES ('PA011', 'El Taller de BD')

INSERT PINTORES VALUES ('NA001', 'Goya')
INSERT PINTORES VALUES ('NA002', 'Dalí')
INSERT PINTORES VALUES ('NA003', 'Van Gogh')
INSERT PINTORES VALUES ('NA004', 'Miguel Angel')
INSERT PINTORES VALUES ('NA005', 'Pablo Picasso')
INSERT PINTORES VALUES ('NA006', 'Rubens')
INSERT PINTORES VALUES ('NA007', 'Da Vinci')
INSERT PINTORES VALUES ('NA008', 'Kevin')

INSERT EXPOSICION VALUES ('EX001', 'PA001', 'NA007', 12000.80)
INSERT EXPOSICION VALUES ('EX002', 'PA002', 'NA007', 13500.70)
INSERT EXPOSICION VALUES ('EX003', 'PA003', 'NA003', 18000.13)
INSERT EXPOSICION VALUES ('EX004', 'PA004', 'NA006', 25000.80)
INSERT EXPOSICION VALUES ('EX005', 'PA005', 'NA003', 30879.00)
INSERT EXPOSICION VALUES ('EX006', 'PA006', 'NA005', 25000.75)
INSERT EXPOSICION VALUES ('EX007', 'PA007', 'NA004', 50000.75)
INSERT EXPOSICION VALUES ('EX008', 'PA008', 'NA003', 10000.80)
INSERT EXPOSICION VALUES ('EX009', 'PA009', 'NA002', 13000.10)
INSERT EXPOSICION VALUES ('EX010', 'PA010', 'NA001', 09000.05)
INSERT EXPOSICION VALUES ('EX011', 'PA011', 'NA008', NULL)

/* ===========================================================
		  REALIZACION DE LAS CONSULTAS SOLICITADAS
   ===========================================================*/

-- 1. Obtener los nombres de todas las piezas de arte:

SELECT nombre_pieza FROM PIEZAS

-- 2. Obtener todos los datos de todos los pintores:

SELECT * FROM PINTORES

-- 3. Obtener el precio medio de los cuadros expuestos (dos decimales):

SELECT ROUND(AVG(precio), 2) AS [Precio Medio] FROM EXPOSICION

-- 4. Obtener el nombre del pintor que hizo la pieza “El grito”:

SELECT nombre AS [Autor de "El grito"] FROM PINTORES WHERE 
id_pintor=(SELECT id_pintor FROM EXPOSICION WHERE cod_pieza=(SELECT cod_pieza FROM PIEZAS WHERE nombre_pieza='El grito'))

-- 5. Obtener los nombres de las piezas expuestas del pintor Van Gogh:

SELECT nombre_pieza AS [Piezas del autor Van Gogh] FROM PIEZAS WHERE cod_pieza IN 
(SELECT cod_pieza FROM EXPOSICION WHERE id_pintor=(SELECT id_pintor FROM PINTORES WHERE nombre='Van Gogh'))

-- 6. Obtener el nombre de la pieza más cara de toda la exposición:

SELECT MAX(precio) AS [Obra mas Cara] FROM EXPOSICION

-- 7. Obtener el nombre d ellos 3 pintores que suministran las piezas más caras, 
-- indicando el nombre de la pieza y el precio de la obra de arte:

SELECT TOP 3 PINTORES.nombre, PIEZAS.nombre_pieza, EXPOSICION.precio FROM 
((PINTORES INNER JOIN EXPOSICION ON PINTORES.id_pintor = EXPOSICION.id_pintor) 
INNER JOIN PIEZAS ON PIEZAS.cod_pieza = EXPOSICION.cod_pieza) ORDER BY EXPOSICION.precio DESC

-- 8. Nombre de los pintores en exposición y su cantidad de cuadros respectivos:

SELECT T1.nombre, T2.[Cantidad Piezas] FROM 
(PINTORES AS T1 INNER JOIN (SELECT id_pintor, COUNT(cod_pieza) AS [Cantidad Piezas] FROM EXPOSICION GROUP BY id_pintor) AS T2 ON T1.id_pintor = T2.id_pintor)

-- 9. Nombre de los cuadros de los pintores Van Gogh y Da Vinci:

SELECT nombre_pieza FROM PIEZAS WHERE cod_pieza IN 
(SELECT cod_pieza FROM EXPOSICION WHERE id_pintor IN (SELECT id_pintor FROM PINTORES WHERE nombre IN ('Van Gogh', 'Da Vinci')))

-- 10. Aumentar los precios de las piezas en una unidad:

SELECT cod_pieza AS [Codigo Pieza], id_pintor AS [ID Pintor], precio + 1 AS [Nuevo precio] FROM EXPOSICION

-- 11. Sustituir los datos del pintor Van Gogh por el nombre “Vincent Van Gogh”:

UPDATE PINTORES SET nombre = 'Vincent Van Gogh' WHERE nombre = 'Van Gogh'
SELECT * FROM PINTORES

-- 12. Sustituir los datos del pintor Da Vinci por el nombre “Leonardo Da Vinci”:

UPDATE PINTORES SET nombre = 'Leonardo Da Vinci' WHERE nombre = 'Da Vinci'
SELECT * FROM PINTORES

-- 13. Hacer constar en la base da datos que el artista Kevin ya no va a exponer ningún cuadro en nuestro Museo 
-- (Aunque el pintor en sí va a seguir en nuestra base de datos):

DELETE FROM EXPOSICION WHERE precio IS NULL
SELECT * FROM EXPOSICION

-- 14. Eliminar el documento del pintor con menos cantidad de obras expuestas:

DELETE FROM EXPOSICION WHERE id_exposicion = 
(SELECT id_exposicion FROM EXPOSICION INNER JOIN 
(SELECT TOP 1 id_pintor, COUNT(cod_pieza) AS Piezas FROM EXPOSICION GROUP BY id_pintor ORDER BY Piezas ASC) AS T1 
ON EXPOSICION.id_pintor = T1.id_pintor)
SELECT * FROM EXPOSICION