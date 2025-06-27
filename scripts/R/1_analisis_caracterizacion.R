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
tm_shape(Kernel_diggle) +
  tm_raster(
    col = "Densidad kernel",
    col.scale = tm_scale_continuous(
      values = "viridis", 
      midpoint = NA
    ),
    col.legend = tm_legend(reverse = TRUE)
  ) +
  tm_shape(lim_posadas) +
  tm_borders() +
  tm_graticules(lwd = 0) +
  tm_title("Siniestros viales (2022-2023)")
tmap_save(
  filename = "./figs/KernelDensity_siniestros.png",
  dpi = 300
)


# Analisis de segunda orden ----
L <- envelope(
  siniestros_ppp, 
  Lest, 
  nsim = 100, 
  verbose = T)

# Visualizando el resultado
plot(L, .-r~r)

# L-function for IPP
L_inhom <- envelope(siniestros_ppp, Linhom, nsim = 100, verbose = T)

# guardando resultado
png(filename = "./figs/Linhom_siniestros.png", width = 1600, height = 1200, res = 300)
plot(L_inhom, . - r ~ r,
     main = "Interação espacial de los siniestros viales de Posadas",
     xlab = "Distância r",
     ylab = "L(r) - r",
     col = "red",
     shade = c("hi", "lo"),
     legend = FALSE)
dev.off()

# Analisis en relacion a los semaforos ---
# Bivariate Second Order Analysis (Análise de segunda ordem bivariada) ---
# L-function for IPP
raio = 0:500
L_inhom <- envelope(siniestros_semaforos_ppp, Lcross.inhom, nsim = 100, verbose = T, r=raio)
png(filename = "./figs/Linhom_siniestros_semaforos.png", width = 1600, height = 1200, res = 300)
plot(L_inhom, .-r ~ r, legend = FALSE)
dev.off()
