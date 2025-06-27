# Script dedicado a las organización de los datos

# Instalacion de librerias ----
#install.packages('sf')
# install.packages('tmap')

# carga de librerias ----
library(sf)
library(dplyr)
library(spatstat)

# Organizacion de datos ----

# Limite ciudad Posadas
lim_posadas <- sf::read_sf('./datos/Municipios_Misiones_2023.gpkg') %>% 
  dplyr::filter(mun==59) %>% # filtra municipio de Posadas
  st_transform(crs = 5349) # proyecta a POSGAR 2007 faja 7
plot(st_geometry(lim_posadas))

# Siniestros viales
siniestros <- sf::read_sf('./datos/siniestros_viales_Misiones_2022-2023.gpkg') %>% 
  dplyr::filter(Lugar == "Posadas") %>% # filtra siniestro de posadas
  st_transform(crs = 5349) %>% # proyecta a POSGAR 2007 faja 7
  st_filter(lim_posadas)
plot(st_geometry(siniestros))

plot(st_geometry(lim_posadas))
plot(st_geometry(siniestros), add=T)

# Preparando los datos a spp (spatial point pattern)
posadas_win <- as.owin(lim_posadas)

# de sf a classe sp
siniestros_ppp <- as.ppp(
  siniestros,
  W = posadas_win) # avisos de que hay siniestro afuera del limite de posadas. No hay problema

# Crea rds ----
save.image('./datos/datos_preprocesados.rds')
