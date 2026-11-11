\pset pager off

SET client_encoding = 'UTF8';

BEGIN;

\echo 'Creando el esquema temporal para la BD de F1'

CREATE SCHEMA IF NOT EXISTS temp;
SET search_path = 'temp, public';

-- Tablas temporales (todos text, sin constraints)
\echo 'Creando tabla temporal: circuits_temp'
CREATE TABLE temp.circuits_temp (
    circuitId text,
    circuitRef text,
    name text,
    location text,
    country text,
    lat text,
    lng text,
    alt text,
    url text
);

\echo 'Creando tabla temporal: constructors_temp'
CREATE TABLE temp.constructors_temp (
    constructorId text,
    constructorRef text,
    name text,
    nationality text,
    url text
);

\echo 'Creando tabla temporal: seasons_temp'
CREATE TABLE temp.seasons_temp (
    year text,
    url text
);

\echo 'Creando tabla temporal: status_temp'
CREATE TABLE temp.status_temp (
    statusId text,
    status text
);

\echo 'Creando tabla temporal: drivers_temp'
CREATE TABLE temp.drivers_temp (
    driverId text,
    driverRef text,
    number text,
    code text,
    forename text,
    surname text,
    dob text,
    nationality text,
    url text
);

\echo 'Creando tabla temporal: races_temp'
CREATE TABLE temp.races_temp (
    raceId text,
    year text,
    round text,
    circuitId text,
    name text,
    date text,
    time text,
    url text,
    fp1_date text,
    fp1_time text,
    fp2_date text,
    fp2_time text,
    fp3_date text,
    fp3_time text,
    quali_date text,
    quali_time text,
    sprint_date text,
    sprint_time text
);

\echo 'Creando tabla temporal: qualifying_temp'
CREATE TABLE temp.qualifying_temp (
    qualifyId text,
    raceId text,
    driverId text,
    constructorId text,
    number text,
    position text,
    q1 text,
    q2 text,
    q3 text
);

\echo 'Creando tabla temporal: pit_stops_temp'
CREATE TABLE temp.pit_stops_temp (
    raceId text,
    driverId text,
    stop text,
    lap text,
    time text,
    duration text,
    milliseconds text
);

\echo 'Creando tabla temporal: results_temp'
CREATE TABLE temp.results_temp (
    resultId text,
    raceId text,
    driverId text,
    constructorId text,
    number text,
    grid text,
    position text,
    positionText text,
    positionOrder text,
    points text,
    laps text,
    time text,
    milliseconds text,
    fastestLap text,
    rank text,
    fastestLapTime text,
    fastestLapSpeed text,
    statusId text
);

\echo 'Creando tabla temporal: lap_times_temp'
CREATE TABLE temp.lap_times_temp (
    raceId text,
    driverId text,
    lap text,
    position text,
    time text,
    milliseconds text
);

\echo 'Cargando datos en tablas temporales'
-- Asume que los CSVs están en un directorio accesible, e.g., ./datos/
\COPY temp.circuits_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/circuits.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.constructors_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/constructors.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.seasons_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/seasons.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.status_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/status.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.drivers_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/drivers.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.races_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/races.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.qualifying_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/qualifying.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.pit_stops_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/pit_stops.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.results_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/results.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');
\COPY temp.lap_times_temp FROM 'C:/Users/david/Downloads/BBDD_2025/archivos_csv/lap_times.csv' WITH (FORMAT csv, HEADER, DELIMITER ',', NULL '\N', ENCODING 'UTF-8');

\echo 'Creando esquema final'
CREATE SCHEMA IF NOT EXISTS final;
SET search_path = 'final, public';

-- Tablas finales con tipos y constraints (adaptado al dataset F1)
\echo 'Creando tabla final: circuits'
CREATE TABLE final.circuits (
    circuitId integer PRIMARY KEY,
    circuitRef text,
    name text,
    location text,
    country text,
    lat numeric,
    lng numeric,
    alt integer,
    url text
);

\echo 'Creando tabla final: constructors'
CREATE TABLE final.constructors (
    constructorId integer PRIMARY KEY,
    constructorRef text,
    name text,
    nationality text,
    url text
);

\echo 'Creando tabla final: seasons'
CREATE TABLE final.seasons (
    year integer PRIMARY KEY,
    url text
);

\echo 'Creando tabla final: status'
CREATE TABLE final.status (
    statusId integer PRIMARY KEY,
    status text
);

\echo 'Creando tabla final: drivers'
CREATE TABLE final.drivers (
    driverId integer PRIMARY KEY,
    driverRef text,
    number integer,
    code text,
    forename text,
    surname text,
    dob date,
    nationality text,
    url text
);

\echo 'Creando tabla final: races'
CREATE TABLE final.races (
    raceId integer PRIMARY KEY,
    year integer REFERENCES final.seasons(year),
    round integer,
    circuitId integer REFERENCES final.circuits(circuitId),
    name text,
    date date,
    time time,
    url text,
    fp1_date date,
    fp1_time time,
    fp2_date date,
    fp2_time time,
    fp3_date date,
    fp3_time time,
    quali_date date,
    quali_time time,
    sprint_date date,
    sprint_time time
);

\echo 'Creando tabla final: qualifying'
CREATE TABLE final.qualifying (
    qualifyId integer PRIMARY KEY,
    raceId integer REFERENCES final.races(raceId),
    driverId integer REFERENCES final.drivers(driverId),
    constructorId integer REFERENCES final.constructors(constructorId),
    number integer,
    position integer,
    q1 text,
    q2 text,
    q3 text
);

\echo 'Creando tabla final: pit_stops'
CREATE TABLE final.pit_stops (
    raceId integer REFERENCES final.races(raceId),
    driverId integer REFERENCES final.drivers(driverId),
    stop integer,
    lap integer,
    time time(3), 
    duration text,
    milliseconds bigint,
    PRIMARY KEY (raceId, driverId, stop)
);

\echo 'Creando tabla final: results'
CREATE TABLE final.results (
    resultId integer PRIMARY KEY,
    raceId integer REFERENCES final.races(raceId),
    driverId integer REFERENCES final.drivers(driverId),
    constructorId integer REFERENCES final.constructors(constructorId),
    number integer,
    grid integer,
    position integer,
    positionText text,
    positionOrder integer,
    points numeric,
    laps integer,
    time text,
    milliseconds bigint,
    fastestLap integer,
    rank integer,
    fastestLapTime text,
    fastestLapSpeed numeric,
    statusId integer REFERENCES final.status(statusId)
);

\echo 'Creando tabla final: lap_times'
CREATE TABLE final.lap_times (
    raceId integer REFERENCES final.races(raceId),
    driverId integer REFERENCES final.drivers(driverId),
    lap integer,
    position integer,
    time text,
    milliseconds bigint,
    PRIMARY KEY (raceId, driverId, lap)
);

\echo 'Insertando datos en esquema final'
-- Inserts con casts y DISTINCT si es necesario (adaptar si hay duplicados)
\echo 'cargando tabla circuits'
INSERT INTO final.circuits (circuitId, circuitRef, name, location, country, lat, lng, alt, url)
SELECT DISTINCT
    circuitId::integer,
    circuitRef,
    name,
    location,
    country,
    lat::numeric,
    lng::numeric,
    alt::integer,
    url
FROM temp.circuits_temp;

\echo 'cargando tabla constructors'
INSERT INTO final.constructors (constructorId, constructorRef, name, nationality, url)
SELECT DISTINCT
    constructorId::integer,
    constructorRef,
    name,
    nationality,
    url
FROM temp.constructors_temp;

\echo 'cargando tabla seasons'
INSERT INTO final.seasons (year, url)
SELECT DISTINCT
    year::integer,
    url
FROM temp.seasons_temp;

\echo 'cargando tabla status'
INSERT INTO final.status (statusId, status)
SELECT DISTINCT
    statusId::integer,
    status
FROM temp.status_temp;

\echo 'cargando tabla drivers'
INSERT INTO final.drivers (driverId, driverRef, number, code, forename, surname, dob, nationality, url)
SELECT DISTINCT
    driverId::integer,
    driverRef,
    CASE WHEN number = '\\N' THEN NULL ELSE number::integer END,
    code,
    forename,
    surname,
    dob::date,
    nationality,
    url
FROM temp.drivers_temp;

\echo 'cargando tabla races'
INSERT INTO final.races (raceId, year, round, circuitId, name, date, time, url, fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, fp3_time, quali_date, quali_time, sprint_date, sprint_time)
SELECT DISTINCT
    raceId::integer,
    year::integer,
    round::integer,
    circuitId::integer,
    name,
    date::date,
    CASE WHEN time = '\\N' THEN NULL ELSE time::time END,
    url,
    CASE WHEN fp1_date = '\\N' THEN NULL ELSE fp1_date::date END,
    CASE WHEN fp1_time = '\\N' THEN NULL ELSE fp1_time::time END,
    CASE WHEN fp2_date = '\\N' THEN NULL ELSE fp2_date::date END,
    CASE WHEN fp2_time = '\\N' THEN NULL ELSE fp2_time::time END,
    CASE WHEN fp3_date = '\\N' THEN NULL ELSE fp3_date::date END,
    CASE WHEN fp3_time = '\\N' THEN NULL ELSE fp3_time::time END,
    CASE WHEN quali_date = '\\N' THEN NULL ELSE quali_date::date END,
    CASE WHEN quali_time = '\\N' THEN NULL ELSE quali_time::time END,
    CASE WHEN sprint_date = '\\N' THEN NULL ELSE sprint_date::date END,
    CASE WHEN sprint_time = '\\N' THEN NULL ELSE sprint_time::time END
FROM temp.races_temp;

\echo 'cargando tabla qualifying'
INSERT INTO final.qualifying (qualifyId, raceId, driverId, constructorId, number, position, q1, q2, q3)
SELECT DISTINCT
    qualifyId::integer,
    raceId::integer,
    driverId::integer,
    constructorId::integer,
    CASE WHEN number = '\\N' THEN NULL ELSE number::integer END,
    position::integer,
    q1,
    q2,
    q3
FROM temp.qualifying_temp;

\echo 'cargando tabla pit_stops'
INSERT INTO final.pit_stops (raceId, driverId, stop, lap, time, duration, milliseconds)
SELECT
    raceId::integer,
    driverId::integer,
    stop::integer,
    lap::integer,
    time::time(3),
    duration,
    milliseconds::bigint
FROM temp.pit_stops_temp;

\echo 'cargando tabla results'
INSERT INTO final.results (resultId, raceId, driverId, constructorId, number, grid, position, positionText, positionOrder, points, laps, time, milliseconds, fastestLap, rank, fastestLapTime, fastestLapSpeed, statusId)
SELECT DISTINCT
    resultId::integer,
    raceId::integer,
    driverId::integer,
    constructorId::integer,
    CASE WHEN number = '\\N' THEN NULL ELSE number::integer END,
    grid::integer,
    CASE WHEN position = '\\N' THEN NULL ELSE position::integer END,
    positionText,
    positionOrder::integer,
    points::numeric,
    laps::integer,
    time,
    CASE WHEN milliseconds = '\\N' THEN NULL ELSE milliseconds::bigint END,
    CASE WHEN fastestLap = '\\N' THEN NULL ELSE fastestLap::integer END,
    CASE WHEN rank = '\\N' THEN NULL ELSE rank::integer END,
    fastestLapTime,
    CASE WHEN fastestLapSpeed = '\\N' THEN NULL ELSE fastestLapSpeed::numeric END,
    statusId::integer
FROM temp.results_temp;

\echo 'cargando tabla lap_times'
INSERT INTO final.lap_times (raceId, driverId, lap, position, time, milliseconds)
SELECT
    raceId::integer,
    driverId::integer,
    lap::integer,
    position::integer,
    time,
    milliseconds::bigint
FROM temp.lap_times_temp;



COMMIT
--ROLLBACK;  -- Cambia a COMMIT; cuando estés listo para aplicar cambios