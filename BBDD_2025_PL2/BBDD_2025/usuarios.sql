-- PARTE 3: CREACIÓN DE USUARIOS Y PERMISOS - PECL2 2025-26

SET search_path TO final;

-- 1. Administrador: puede hacer literalmente TODO
CREATE ROLE admin_f1 LOGIN PASSWORD 'admin123';
GRANT ALL PRIVILEGES ON SCHEMA final TO admin_f1;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA final TO admin_f1;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA final TO admin_f1;
ALTER ROLE admin_f1 CREATEDB CREATEROLE;

-- 2. Gestor de competiciones: puede modificar datos pero NO estructura
CREATE ROLE gestor_f1 LOGIN PASSWORD 'gestor123';
GRANT USAGE ON SCHEMA final TO gestor_f1;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA final TO gestor_f1;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA final TO gestor_f1;
-- Le quitamos capacidad de crear/alterar estructura
REVOKE CREATE ON SCHEMA final FROM gestor_f1;

-- 3. Analista: solo lectura completa
CREATE ROLE analista_f1 LOGIN PASSWORD 'analista123';
GRANT USAGE ON SCHEMA final TO analista_f1;
GRANT SELECT ON ALL TABLES IN SCHEMA final TO analista_f1;

-- 4. Invitado: solo datos públicos (carreras, resultados, pilotos, equipos, circuitos, temporadas)
CREATE ROLE invitado_f1 LOGIN PASSWORD 'invitado123';
GRANT USAGE ON SCHEMA final TO invitado_f1;
GRANT SELECT ON TABLE races, results, drivers, constructors, circuits, seasons TO invitado_f1;

-- Explícitamente prohibimos acceso a datos sensibles para el invitado
REVOKE ALL ON TABLE pit_stops FROM invitado_f1;
REVOKE ALL ON TABLE lap_times FROM invitado_f1;
REVOKE ALL ON TABLE audit_log FROM invitado_f1;
REVOKE ALL ON TABLE driver_total_points FROM invitado_f1;

-- Mensaje final y comprobación
\echo ''
\echo '=================================================================='
\echo 'PARTE 3 COMPLETADA - USUARIOS CREADOS CORRECTAMENTE'
\echo '=================================================================='
\echo 'Roles creados: admin_f1, gestor_f1, analista_f1, invitado_f1'
\echo ''

-- Lista todos los roles para que veas que están creados
\du