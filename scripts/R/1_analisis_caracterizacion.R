# rm(list=ls())
library(spatstat)
library(sf)
library(terra)
library(tmap)

# Cargando datos preprocesados ----
load('./datos/datos_preprocesados.rds')

#sumario estadistico del point patern
summary(siniestros_ppp)

# Analisis de primera orden de los siniestros viales en posadas ----
# contesta a la pregunta si la probabildiad de ocurrir un siniestro vial es igual en todo el área de estudio
# Es decir: como las ocurrencias de los siniestros viales varian en el espacio. No es de manera homogénea
# Definiendo rango (bandwidth)
raio_diggle <- bw.diggle(siniestros_ppp)
# Calcula densidad de kernel
Kernel_diggle <- density.ppp(
  siniestros_ppp, 
  sigma = raio_diggle
  )
# Plot de la densidad de kernel
plot(Kernel_diggle, main = "raio baseado em Diggle 1989")

# Convertendo kernel para raster ---
Kernel_diggle <- terra::rast(Kernel_diggle)
terra::crs(Kernel_diggle) <- 'EPSG:5349'
names(Kernel_diggle) <- 'Densidad kernel'

# Mapa con el resultado
tm_shape(lim_posadas) +
  tm_borders() +
  tm_shape(Kernel_diggle) +
  tm_raster() +
  tm_shape(lim_posadas) +
  tm_borders() +
  tm_legend(legend.outside = T) +
  tm_graticules(lwd = 0) + 
  tm_title("Siniestros viales (2022-2023")
#tmap_save(filename = "./img/kernel.png")


# Analisis de segunda orden ----
L <- envelope(
  siniestros_ppp, 
  Lest, 
  nsim = 1000, 
  verbose = T)

# Visualizando el resultado
plot(L, .-r~r)

# L-function for IPP
L_inhom <- envelope(siniestros_ppp, Linhom, nsim = 10, verbose = T)
plot(L_inhom, . -r ~ r)
plot(siniestros_ppp)

# Analisis en relacion a los semaforos
