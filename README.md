# Pruebas moleculares COVID-19

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

- Fuente: INS
	- URL: https://datos.ins.gob.pe/organization/covid-19

- Proceso de limpieza simple de datos, con asignación de UBIGEOS a nivel de provincia, y de población al 2020 (estimación INEI)

- Los datos originales descargados al 2020-11-17 están en `orig`
- Datos de población y ubigeos del MINSA/INEI están en `misc`
- Los datos aumentados con ubigeo y población, a nivel de provincia están en `proc`, en formatos CSV, RDS (**R**), y DTA (STATA)
  - También estan los conteos agrupados por fecha, tipo de prueba, resultad, edad, sexo, departamento y provincia, en formatos CSV y XLSX.
  
