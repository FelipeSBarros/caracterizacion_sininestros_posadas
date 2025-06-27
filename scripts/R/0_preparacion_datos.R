# Script dedicado a las organización de los datos

# Instalacion de librerias ----
# install.packages('sf')
# install.packages('tmap')

# carga de librerias ----
library(sf)
library(dplyr)
library(spatstat)

# Organizacion de datos ----

# Limite ciudad Posadas
lim_posadas <- sf::read_sf('./datos/Municipios_Misiones_2023.gpkg') %>% 
  dplyr::filter(mun==59) %>% # filtra municipio de Posadas
  st_transform(crs = 5348) # proyecta a POSGAR 2007 faja 6
plot(st_geometry(lim_posadas))

# Siniestros viales
siniestros <- sf::read_sf('./datos/siniestros_viales_Misiones_2022-2023.gpkg') %>% 
  dplyr::filter(Lugar == "Posadas") %>% # filtra siniestro de posadas
  st_transform(crs = 5348) %>% # proyecta a POSGAR 2007 faja 6
  st_filter(lim_posadas)
plot(st_geometry(siniestros))

plot(st_geometry(lim_posadas))
plot(st_geometry(siniestros), add=T)

# Semaforos
semaforos <- sf::read_sf('./datos/semaforos_Posadas.gpkg') %>% 
  st_transform(crs = 5348) # proyecta a POSGAR 2007 faja 6
plot(st_geometry(semaforos))

# Preparando los datos a spp (spatial point pattern)
posadas_win <- as.owin(lim_posadas)

# Siniestros a clase ppp
siniestros_ppp <- as.ppp(
  siniestros,
  W = posadas_win)

# Siniestro a la clase ppp marcada junto con los semaforos
semaforos_ppp <- as.ppp(
  semaforos,
  W = posadas_win)

# juntando semaforos y siniestros
marks(siniestros_ppp) <- factor("Siniestros")
marks(semaforos_ppp) <- factor("Semaforos")
siniestros_semaforos_ppp <- superimpose(siniestros_ppp, semaforos_ppp)

plot(siniestros_semaforos_ppp)

# Crea rds ----
save.image('./datos/datos_preprocesados.rds')