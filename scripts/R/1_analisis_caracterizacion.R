# rm(list=ls())
library(spatstat)
library(sf)
library(terra)
library(tmap)
library(dbscan)

# Cargando datos preprocesados ----
load('./datos/datos_preprocesados.rds')

# Sumario estadistico de los procesos puntuales de siniestros viales
summary(siniestros_ppp)

# Analisis de primera orden de los siniestros viales en posadas ----
# contesta a la pregunta si la probabilidad de ocurrir un siniestro vial es igual en todo el área de estudio
# Es decir: ¿Cómo las ocurrencias de los siniestros viales varian en el espacio?

# Definiendo rango (bandwidth)
raio_diggle <- bw.diggle(siniestros_ppp)
# Calcula densidad de kernel
Kernel_diggle <- density.ppp(
  siniestros_ppp, 
  sigma = raio_diggle
  )

# Convertiendo kernel de im a raster ---
Kernel_diggle <- terra::rast(Kernel_diggle)
terra::crs(Kernel_diggle) <- 'EPSG:5348'
names(Kernel_diggle) <- 'Densidad estimada'

# Mapa con el resultado
tm_shape(Kernel_diggle) +
  tm_raster(
    col = 'Densidad estimada',
    col.scale = tm_scale_continuous(
      values = "viridis", 
      midpoint = NA
    ),
    col.legend = tm_legend(reverse = TRUE)
  ) +
  tm_shape(lim_posadas) +
  tm_borders() +
  tm_graticules(lwd = 0) +
  tm_title("Densidad de siniestros viales (2022-2023)")
tmap_save(
  filename = "./figs/KernelDensity_siniestros.png",
  dpi = 300
)


# Analisis de segunda orden ----
raio = 0:500
L <- envelope(
  siniestros_ppp, 
  Lest, 
  nsim = 100, 
  verbose = T, 
  r=raio
)

# Visualizando el resultado
plot(L, 
     . - r ~ r,
     main = "Interação espacial de los siniestros viales de Posadas acorde hipotesis homegenea",
     xlab = "Distância r",
     ylab = "L(r) - r",
     # col = "red",
     shade = c("hi", "lo"),
     legend = FALSE)

# L-function for IPP
L_inhom <- envelope(
  siniestros_ppp, 
  Linhom, 
  nsim = 100, 
  verbose = T, 
  r=raio)

# guardando resultado
png(filename = "./figs/Linhom_siniestros.png", width = 1600, height = 1200, res = 300)
plot(L_inhom, 
     . - r ~ r,
     main = "Interação espacial de los siniestros viales de Posadas",
     xlab = "Distância r",
     ylab = "L(r) - r",
     # col = "red",
     shade = c("hi", "lo"),
     legend = FALSE)
dev.off()

# Analisis de agrupacion con dbscan ----
(siniestros_dbscan <- dbscan::dbscan(
  st_coordinates(siniestros),
  eps = 500,
  minPts = 5
))

siniestros <- siniestros %>%
  dplyr::mutate(cluster_dbscan_500_5 = siniestros_dbscan$cluster)

siniestros <- siniestros %>%
  dplyr::filter(cluster_dbscan_500_5 != 0)

siniestros <- siniestros %>%
  dplyr::mutate(
    cluster_dbscan_500_5 = paste0("cluster_", cluster_dbscan_500_5),
    cluster_dbscan_500_5 = as.factor(cluster_dbscan_500_5)
  )

tm_shape(lim_posadas) +
  tm_borders() +
  tm_shape(siniestros) +
  tm_dots(
    col = "cluster_dbscan_500_5",
    # col.scale = tm_scale_categorical(values = "brewer.dark2"),
    # col.legend = tm_legend(title = ""),
    palette = "brewer.dark2",
  ) +
  tm_graticules(lwd = 0) +
  tm_title("Agrupaciones de siniestros viales (2022-2023)")
  # tm_legend(title = "")

tmap_save(
  filename = "./figs/Agrupaciones_500_5_siniestros.png",
  dpi = 300
)
# st_write(siniestros, "./datos/siniestros_agrupacion.gpkg")

# DBScan con pesos ----

# Lesionados
siniestros <- siniestros %>%
  dplyr::mutate(
    Lesionados = 
      ifelse(
        Lesionados == "Varios", "3", Lesionados
        ),
    Lesionados_ = as.numeric(Lesionados)
  )
(siniestros_dbscan_lesionados <- dbscan::dbscan(
  st_coordinates(siniestros),
  eps = 500,
  minPts = 5,
  weights = siniestros$Lesionados_
))

siniestros <- siniestros %>%
  dplyr::mutate(cluster_dbscan_les_500_5 = siniestros_dbscan_lesionados$cluster)

siniestros <- siniestros %>%
  dplyr::filter(cluster_dbscan_les_500_5 != 0)

siniestros <- siniestros %>%
  dplyr::mutate(
    cluster_dbscan_les_500_5 = paste0("cluster_", cluster_dbscan_les_500_5),
    cluster_dbscan_les_500_5 = as.factor(cluster_dbscan_les_500_5)
  )

tm_shape(lim_posadas) +
  tm_borders() +
  tm_shape(siniestros) +
  tm_dots(
    col = "cluster_dbscan_les_500_5",
    # col.scale = tm_scale_categorical(values = "brewer.dark2"),
    # col.legend = tm_legend(title = ""),
    palette = "brewer.dark2",
  ) +
  tm_graticules(lwd = 0) +
  tm_title("Agrupaciones de siniestros viales (2022-2023)")

tmap_save(
  filename = "./figs/Agrupaciones_500_5_siniestros_lesionados.png",
  dpi = 300
)

# Decesos
dbscan::dbscan(
  st_coordinates(siniestros),
  eps = 500,
  minPts = 5,
  weights = siniestros$Decesos
)

# Analisis en relacion a los semaforos ---
# Bivariate Second Order Analysis (Análise de segunda ordem bivariada) ---
# L-function for IPP
L_inhom_bivar <- envelope(
  siniestros_semaforos_ppp, 
  Lcross.inhom, 
  nsim = 100, 
  verbose = T, 
  r=raio)
png(filename = "./figs/Linhom_siniestros_semaforos.png", width = 1600, height = 1200, res = 300)
plot(
  L_inhom_bivar, 
  . - r ~ r,
  main = "Interação espacial de los siniestros viales de Posadas",
  xlab = "Distância r",
  ylab = "L(r) - r",
  # col = "red",
  shade = c("hi", "lo"),
  legend = FALSE)
dev.off()
