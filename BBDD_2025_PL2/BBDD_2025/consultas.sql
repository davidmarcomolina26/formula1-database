-- consultas.sql - Parte 1: 10 Consultas 

SET search_path = 'final';

-- 1. Listado de todos los circuitos, así como el número de grandes premios que ha albergado cada uno.

\echo '1. Circuitos + número de GPs'
SELECT c.name AS circuito, COUNT(r.raceId) AS num_grandes_premios
FROM circuits c
JOIN races r ON c.circuitId = r.circuitId
GROUP BY c.circuitId, c.name
ORDER BY num_grandes_premios DESC, c.name;

-- 2. Número de grandes premios que ha corrido Ayrton Senna, así como el total de puntos conseguidos en las mismas.

\echo '2. Ayrton Senna: GPs y puntos'
SELECT COUNT(re.raceId) AS num_grandes_premios,
       COALESCE(SUM(re.points), 0) AS puntos_totales
FROM drivers d
JOIN results re ON d.driverId = re.driverId
WHERE d.forename = 'Ayrton' AND d.surname = 'Senna';

-- 3. Listado con el nombre y apellidos de todos los pilotos nacidos después del 31 de diciembre de 1999. Junto con el número de carreras en las que haya participado cada uno de ellos.

\echo '3. Pilotos nacidos después del 31/12/1999'
SELECT d.forename || ' ' || d.surname AS piloto,
       COUNT(re.raceId) AS num_carreras
FROM drivers d
LEFT JOIN results re ON d.driverId = re.driverId
WHERE d.dob > '1999-12-31'::date
GROUP BY d.driverId, d.forename, d.surname
ORDER BY num_carreras DESC, piloto;

-- 4. Nombre de todas las escuderías españolas o italianas junto con el número de grandes premios corridos.

\echo '4. Escuderías españolas o italianas + GPs'
SELECT c.name AS escuderia,
       COUNT(DISTINCT re.raceId) AS num_grandes_premios
FROM constructors c
JOIN results re ON c.constructorId = re.constructorId
WHERE c.nationality IN ('Spanish', 'Italian')
GROUP BY c.constructorId, c.name
ORDER BY num_grandes_premios DESC, c.name;

-- 5. Vista donde, para cada temporada, se muestren los pilotos que han corrido en la misma, así como los puntos totales que han obtenido cada uno en esa temporada.

\echo '5. Vista: puntos por temporada'
CREATE OR REPLACE VIEW puntos_por_temporada AS
SELECT s.year AS temporada,
       d.forename || ' ' || d.surname AS piloto,
       COALESCE(SUM(re.points), 0) AS puntos_totales
FROM seasons s
CROSS JOIN drivers d
LEFT JOIN results re ON d.driverId = re.driverId
     AND re.raceId IN (SELECT raceId FROM races WHERE year = s.year)
GROUP BY s.year, d.driverId, d.forename, d.surname
ORDER BY s.year, puntos_totales DESC;

-- Ejemplo de uso 
SELECT * FROM puntos_por_temporada WHERE temporada = 2023 AND puntos_totales > 0 LIMIT 5;

-- 6. Nombre de los pilotos que han ganado, al menos, un GP (posición = 1)

\echo '6. Pilotos que han ganado al menos 1 GP'
SELECT DISTINCT d.forename || ' ' || d.surname AS piloto_ganador
FROM drivers d
JOIN results re ON d.driverId = re.driverId
WHERE re.position = 1
ORDER BY piloto_ganador;

-- 7. Número de Grandes Premios por país

\echo '7. Número de GPs por país'
SELECT c.country AS pais,
       COUNT(r.raceId) AS num_grandes_premios
FROM circuits c
JOIN races r ON c.circuitId = r.circuitId
GROUP BY c.country
ORDER BY num_grandes_premios DESC, pais;

-- 8. Piloto con la vuelta más rápida en toda la historia (se prohíbe expresamente el uso de la sentencia LIMIT)

\echo '8. Vuelta más rápida (SIN LIMIT)'
SELECT d.forename || ' ' || d.surname AS piloto,
       r.name AS gran_premio,
       lt.time AS tiempo_vuelta
FROM lap_times lt
JOIN drivers d ON lt.driverId = d.driverId
JOIN races r ON lt.raceId = r.raceId
WHERE lt.milliseconds = (SELECT MIN(milliseconds) FROM lap_times WHERE milliseconds IS NOT NULL);

-- 9. Número de paradas en boxes por piloto en el gran premio de Mónaco de 2023

\echo '9. Paradas en boxes - Mónaco 2023'
SELECT d.forename || ' ' || d.surname AS piloto,
       COUNT(ps.stop) AS num_paradas
FROM pit_stops ps
JOIN drivers d ON ps.driverId = d.driverId
JOIN races r ON ps.raceId = r.raceId
WHERE r.name = 'Monaco Grand Prix' AND r.year = 2023
GROUP BY d.driverId, d.forename, d.surname
ORDER BY num_paradas DESC, piloto;

-- 10. Nombre de los pilotos que hayan participado en más de 100 premios ordenados por aquellos que hayan participado en más grandes premios.

\echo '10. Pilotos con más de 100 GPs'
SELECT d.forename || ' ' || d.surname AS piloto,
       COUNT(re.raceId) AS num_grandes_premios
FROM drivers d
JOIN results re ON d.driverId = re.driverId
GROUP BY d.driverId, d.forename, d.surname
HAVING COUNT(re.raceId) > 100
ORDER BY num_grandes_premios DESC, piloto;