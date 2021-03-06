load('muestra40.RData')
library(dplyr)
#El fichero tiene 339685 filas y 3 columnas

muestra40 <- muestra40 %>% 
  rename('nif' = 'var1',
         'nombre' = 'var2',
         'genero' = 'var3')

# Analizo el NIF ----------------------------------------------------------
formato_correcto <- grepl('[[:digit:]]{8}[[:alpha:]]{1}', muestra40$nif)
formato_correcto
formato_correcto1 <- which(formato_correcto == T)
df_nice <- muestra40[formato_correcto1, ]

# Analizo el g�nero -------------------------------------------------------

muestra40$nombre <- toupper(muestra40$nombre)
muestra40[muestra40$genero %in% c('', 'X', 'E'),3] <- NA
unique(muestra40$genero)

datos_genero <- muestra40 %>% 
  split(.$genero)
datos_chicas <- datos_genero[[1]]
datos_chicos <- datos_genero[[2]]

frecuencia_chicos <- datos_chicos %>% 
  group_by(nombre) %>% 
  tally()
frecuencia_chicos <- frecuencia_chicos %>% 
  rename('n_M' = 'n')

frecuencia_chicas <- datos_chicas %>% 
  group_by(nombre) %>% 
  tally()
frecuencia_chicas <- frecuencia_chicas %>% 
  rename('n_V' = 'n')

frecuencias_totales <- frecuencia_chicos %>% 
  right_join(frecuencia_chicas, by = 'nombre')
frecuencias_totales[is.na(frecuencias_totales)] <- 0

tabla_final <- muestra40 %>% 
  left_join(frecuencias_totales, by = 'nombre')

tabla_final$genero_imputado[tabla_final$n_M>tabla_final$n_V] <- 'M'
tabla_final$genero_imputado[tabla_final$n_V>tabla_final$n_M] <- 'V'
tabla_final <- tabla_final[,-c(4,5)]

tabla_final <- tabla_final[!is.na(tabla_final$genero_imputado),]
#Como no podemos imputar el g�nero en determinadas situaciones, es mejor eliminar
#esos registros

