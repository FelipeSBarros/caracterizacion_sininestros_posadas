# Caracterización de los siniestros viales ocurridos en Posadas (2022-2023)

Repositorio creado para gestionar los análisis de caracterización de los siniestros viales ocurridos en Posadas.

## Al respecto de los datos
Los datos fueron generados por un proceso de Geocoding o Georreferenciación manual a aparitr de notícias publicadas en el diário Primera Edición, [trabajo desarrollado por Claudia Vargas](https://tusigyt.github.io/lit/proyectos/) como Proyecto de Intervención de la Tecnicatura Universitária en Sistemas de Información Geográfica y Teledetección (TUSIGyT) de la Facultad de Ciencias Forestales (FCF) de la Universidad Nacional de Misiones (UNaM).

Más allá de la ubicación geográfica, el conjunto de datos dispone de una table de atributos con la siguientes informaciones:  
- Fecha de publicación: Fecha de la publicación de la notícia de siniestro vial;
- Lugar: Texto de la ciudad;
- Ubicación: Texto de la ubicación; 
- Vehiculos: Tipo de vehiculo(s) involucrado(s);
- Decesos: Valor numerico de la cantidad de fallecidos reportados en la noticia
- Lesionados: Valor numerico de la cantidad de lesionados reportados en la notícia;
- Incertidumbre: Nível de incertidumbre de la georreferenciación ("Baja", "Media", "Alta");
- Herramienta: Herramienta usada para la georeferenciación ("Geocoding" o "Manual")
- URL de la noticia;

# Otros Datos
- [IDE Posadas](https://www.ide.posadas.gob.ar/):
  - 
- [IDE Misiones](https://ide.ordenamientoterritorial.misiones.gob.ar/):
  - Límite Municipal 2023;
## Objetivos
Realizar un análisis exploratório usando técnicas y estadśiticas espaciales para caracterizar los siniestro viales reportados y georreferenciados en Posadas;

Algunas preguntas disparadoras y posibles análisis a usar:
- Los siniestros ocurridos suelen ocurrir a qué distancia uno de los otros?
  - Análisis de segunda orden (Función k-Ripley)
- Los siniestros viales seuelen ocurrir cerca a semáforos? Sería una pregunta proxy para identificar si suelen ocurrir en cruce;
  - Análisis bu-variada de segunda orden (Función k-ripley entre siniestros y [semaforos](https://www.ide.posadas.gob.ar/layers/ideposadas_data:geonode:Semaforos);

# Scripts y análisis
0. [Preparación y preprocesamiento de datos](./scripts/R/0_preparacion_datos.R): Script creado para filtrar y organizar datos para el procesamiento, generando un `.rda` a ser cargado en los scripts subsecuentes;
1. [Análisis de caracterizaciónd e los siniestros viales](./scripts/R/1_analisis_caracterizacioin.R): Realiza la caracterización de primera y segunda orden;
