import sys
import psycopg2

class portException(Exception): pass


def ask_port(msg):
    """
        ask for a valid TCP port
        ask_port :: String -> IO Integer | Exception
    """
    try:
        answer = input(msg)
        port = int(answer)
        if (port < 1024) or (port > 65535):
            raise ValueError
    except ValueError:
        raise portException
    return port                      # return port

def ask_conn_parameters():
    """
        ask_conn_parameters:: () -> IO String
        pide los parámetros de conexión
        TODO: cada estudiante debe introducir los valores para su base de datos
    """
    host = 'localhost'                                                          # 
    port = ask_port('TCP port number: ')                                        # pide un puerto TCP
    user = 'admin_f1'                                                                   # TODO
    password = 'admin123'                                                               # TODO
    database = 'f1'                                                               # TODO
    return (host, port, user, password, database)

def main():
    """
        main :: () -> IO None
    """
    try:
        (host, port, user, password, database) = ask_conn_parameters()          #
        connstring = f'host={host} port={port} user={user} password={password} dbname={database}' 
        conn    = psycopg2.connect(connstring)                                  #                                                                 
        cur     = conn.cursor()                                                 # instacia un cursor
        query   = """
            SELECT c.name AS circuito, COUNT(r.raceId) AS num_grandes_premios
            FROM final.circuits c
            JOIN final.races r ON c.circuitId = r.circuitId
            GROUP BY c.circuitId, c.name
            ORDER BY num_grandes_premios DESC, c.name;
        """                                        # prepara una consulta
        cur.execute(query)                                                      # ejecuta la consulta
        for record in cur.fetchall():                                           # fetchall devuelve todas las filas de la consulta
            print(record)                                                       # imprime las filas
        cur.close()                                                              # cierra el cursor
        conn.close ()                                                             # cierra la conexion
    except portException:
        print("The port is not valid!")
    except KeyboardInterrupt:
        print("Program interrupted by user.")
    finally:
        print("Program finished")

if __name__ == "__main__":                                                      # Es el modula principal?
    if '--test' in sys.argv:                                                    # chequea el argumento cmdline buscando el modo test
        import doctest                                                          # importa la libreria doctest
        doctest.testmod()                                                       # corre los tests
    else:                                                                       # else
        main()                                                                  # ejecuta el programa principal
