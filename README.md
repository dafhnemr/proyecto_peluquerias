Requisitos: PostgreSQL local, DB `pelu`, usuario `postgres`.
1) Crear DB:
   - Abrir “SQL Shell (psql)”
   - Server: Enter | Database: postgres (Enter) | Port: 5432 (Enter) | Username: postgres (Enter)
     Password: (tu clave)
   - Ejecutar:  CREATE DATABASE pelu;  \q
2) Abrir notebooks/01_run_proyecto2.ipynb
3) Ejecutar:
   - run_sql("database/create_database.sql")
   - run_sql("database/views.sql")
   - Consultas Q1 y Q2 (pueden devolver 0 filas si no hay datos)
  
Para la documentación:
- [ER (PDF)](docs/er_peluqueria.pdf)
- [ER (draw.io)](docs/er_peluqueria.drawio)
- [Diccionario de datos](docs/dictionary_peluqueria.pdf)

