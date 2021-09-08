#!/bin/bash
# Asignación de variables
csv_in=cv19_municipio-asignacion_casos.csv
csv_out=cv19_municipio-asignacion_casos-iso.csv
sql3_out=covidepican.sql3
# Descargar datos
# wget "https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos.csv" -O ${csv_in}
# Convertir fecha de DD/MM/AAAA a AAAA-MM-DD
cat ${csv_in} | sed -e "s/\([0-9]\+\)\/\([0-9]\+\)\/\([0-9]\+\)/\3-\2-\1/g" > ${csv_out}
# Importar CSV en sqlite3
sqlite3 << __EOF__
.mode csv
.import ${csv_out} covidepican
CREATE VIEW tiempos AS
    SELECT *, julianday(fecha_fallecido) - julianday(fecha_caso) AS tiempo_fallecido,
        julianday(fecha_curado) - julianday(fecha_caso) AS tiempo_alta
    FROM covidepican;
.save ${sql3_out}
__EOF__
# Ejecutar el cuaderno de Jupyter y convertir a HTML
jupyter nbconvert --execute --to html covidepican.ipynb
