SET search_path = final;

\echo '============================================'
\echo '== PARTE 2: TRIGGERS - AUDITORIA GENERAL =='
\echo '============================================'

DROP TABLE IF EXISTS audit_log CASCADE;
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    tabla text NOT NULL,
    operacion char(1) NOT NULL CHECK (operacion IN ('I','U','D')),
    usuario_db text NOT NULL DEFAULT CURRENT_USER,
    fecha_hora timestamptz NOT NULL DEFAULT now(),
    detalle jsonb
);

CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS trigger AS $$
BEGIN
    IF TG_TABLE_NAME IN ('audit_log','driver_total_points') THEN
        RETURN NULL;
    END IF;

    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log(tabla, operacion, detalle)
        VALUES (TG_TABLE_NAME, 'D', to_jsonb(OLD));
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log(tabla, operacion, detalle)
        VALUES (TG_TABLE_NAME, 'U',
                jsonb_build_object('OLD', to_jsonb(OLD),
                                   'NEW', to_jsonb(NEW)));
        RETURN NEW;

    ELSE
        INSERT INTO audit_log(tabla, operacion, detalle)
        VALUES (TG_TABLE_NAME, 'I', to_jsonb(NEW));
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE r record;
BEGIN
    FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='final'
    LOOP
        IF r.tablename IN ('audit_log','driver_total_points') THEN CONTINUE; END IF;

        EXECUTE format('DROP TRIGGER IF EXISTS trg_audit_%1$I ON final.%1$I;
                        CREATE TRIGGER trg_audit_%1$I
                        AFTER INSERT OR UPDATE OR DELETE ON final.%1$I
                        FOR EACH ROW EXECUTE FUNCTION fn_audit_log();',
                        r.tablename);
    END LOOP;
END $$;


\echo '============================================'
\echo '== PARTE 2: TRIGGERS - PUNTOS TOTALES     =='
\echo '============================================'

DROP TABLE IF EXISTS driver_total_points CASCADE;
CREATE TABLE driver_total_points (
    driverId integer PRIMARY KEY REFERENCES drivers(driverId),
    total_points numeric NOT NULL DEFAULT 0
);

INSERT INTO driver_total_points
SELECT d.driverId, COALESCE(SUM(r.points),0)
FROM drivers d
LEFT JOIN results r ON d.driverId=r.driverId
GROUP BY d.driverId
ON CONFLICT (driverId) DO UPDATE SET total_points=EXCLUDED.total_points;

CREATE OR REPLACE FUNCTION fn_update_driver_points()
RETURNS trigger AS $$
DECLARE old_driver int; new_driver int;
BEGIN
    IF TG_OP='DELETE' THEN
        old_driver:=OLD.driverId;
        INSERT INTO driver_total_points VALUES
            (old_driver,(SELECT COALESCE(SUM(points),0) FROM results WHERE driverId=old_driver))
        ON CONFLICT (driverId) DO UPDATE SET total_points=EXCLUDED.total_points;

    ELSIF TG_OP='INSERT' THEN
        new_driver:=NEW.driverId;
        INSERT INTO driver_total_points VALUES
            (new_driver,(SELECT COALESCE(SUM(points),0) FROM results WHERE driverId=new_driver))
        ON CONFLICT (driverId) DO UPDATE SET total_points=EXCLUDED.total_points;

    ELSE
        old_driver:=OLD.driverId;
        new_driver:=NEW.driverId;

        INSERT INTO driver_total_points VALUES
            (old_driver,(SELECT COALESCE(SUM(points),0) FROM results WHERE driverId=old_driver))
        ON CONFLICT (driverId) DO UPDATE SET total_points=EXCLUDED.total_points;

        IF new_driver != old_driver THEN
            INSERT INTO driver_total_points VALUES
                (new_driver,(SELECT COALESCE(SUM(points),0) FROM results WHERE driverId=new_driver))
            ON CONFLICT (driverId) DO UPDATE SET total_points=EXCLUDED.total_points;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_driver_points ON results;
CREATE TRIGGER trg_update_driver_points
AFTER INSERT OR UPDATE OR DELETE ON results
FOR EACH ROW EXECUTE FUNCTION fn_update_driver_points();


\echo '============================================'
\echo '== PRUEBA 1: AUDITORIA (I, U, D)          =='
\echo '============================================'

BEGIN;

INSERT INTO drivers(driverId, driverRef, forename, surname, dob, nationality)
VALUES (99999,'ptest','Prueba','Audit','1990-01-01','Spanish');

SELECT * FROM audit_log ORDER BY id DESC LIMIT 5;

UPDATE drivers SET nationality='Frances'
WHERE driverId=99999;

SELECT * FROM audit_log ORDER BY id DESC LIMIT 5;

DELETE FROM drivers WHERE driverId=99999;

SELECT * FROM audit_log ORDER BY id DESC LIMIT 5;

ROLLBACK;


\echo '============================================'
\echo '== PRUEBA 2: PUNTOS TOTALES AUTOMATICOS   =='
\echo '============================================'

BEGIN;

SELECT * FROM driver_total_points WHERE driverId=1;

INSERT INTO results(resultId, raceId, driverId, constructorId, number, grid, position,
                    positionText, positionOrder, points, laps, statusId)
VALUES (999999, 1, 1, 1, 99, 1, 1, '1', 1, 25, 58, 1);

SELECT * FROM driver_total_points WHERE driverId=1;

DELETE FROM results WHERE resultId=999999;

SELECT * FROM driver_total_points WHERE driverId=1;

ROLLBACK;


\echo '============================================'
\echo '== FIN DE LA EJECUCION DE PARTE 2        =='
\echo '============================================'
