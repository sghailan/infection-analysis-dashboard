# interpolacion.R: genera y completa los datos interpolados para construir el dataset final usado en el análisis y las visualizaciones

# Se realiza una interpolación. Realmente interesa el resultado final, samples_final
caso_uno <- samples_Q %>%
  dplyr::select(Infeccion, body_temp, SPO2.Min, BPM.Avg, EDA.Avg, tmed, sol,presMean) %>%
  filter(Infeccion == 0)

promedios_caso1 <- colMeans(caso_uno[, sapply(caso_uno, is.numeric)], na.rm = TRUE)

minimos_caso1 <- caso_uno %>%
  summarise(across(where(is.numeric), min, na.rm = TRUE))
samples_modificado<-samples_Q
samples_modificado <- samples_modificado %>% dplyr::select(-siguiente) 
interpolar_paciente <- function(df) {
  max_fecha <- max(df$date_samples[df$date_samples < as.Date("2020-08-02")], na.rm = TRUE)
  fechas_nuevas <- seq(min(df$date_samples), max_fecha, by = "30 days")
  

  fechas_nuevas <- fechas_nuevas[!fechas_nuevas %in% df$date_samples]
  
  df_interp <- data.frame(date_samples = fechas_nuevas)
  
  cols_fijas <- c("resident_code", "Institution", "sex", "age", "berthel_index")
  for (col in cols_fijas) {
    df_interp[[col]] <- unique(df[[col]])
  }
  
  vars_interpolar <- c("body_temp", "SPO2.Min", "BPM.Avg", "EDA.Avg", "tmed", "sol", "presMean")
  for (var in vars_interpolar) {
    datos_validos <- !is.na(df[[var]])
    if (sum(datos_validos) >= 2) {
      df_interp[[var]] <- approx(df$date_samples[datos_validos], df[[var]][datos_validos], 
                                 xout = fechas_nuevas, method = "linear")$y
      if (var == "body_temp") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[1]]), minimos_caso1[[1]])  # Rango entre 20 y 45 grados
      }
      if (var == "SPO2.Min") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[2]]), minimos_caso1[[2]]) 
      }
      if (var == "BPM.Avg") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[3]]), minimos_caso1[[3]]) 
      }
      if (var == "EDA.Avg") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[4]]), minimos_caso1[[4]]) 
      }
      if (var == "tmed") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[5]]), minimos_caso1[[5]]) 
      }
      if (var == "sol") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[6]]), minimos_caso1[[6]])   
      }
      if (var == "presMean") {
        df_interp[[var]] <- pmax(pmin(df_interp[[var]], promedios_caso1[[7]]), minimos_caso1[[7]])  
      }
    } else {
      df_interp[[var]] <- NA  
    }
  }
  
  df_interp$Infeccion <- 0
  
  df_interp <- df_interp %>%
    mutate(Año = year(date_samples),
           Mes = month(date_samples),
           dia = day(date_samples))
  
  return(df_interp)
}

samples_interpolados <- samples_modificado %>%
  group_by(resident_code) %>%
  group_split() %>%
  lapply(interpolar_paciente) %>%
  bind_rows()



samples_interpolados$Año<-as.factor(samples_interpolados$Año)

samples_interpolados$Mes<-as.factor(samples_interpolados$Mes)

samples_interpolados$dia<-as.factor(samples_interpolados$dia)

samples_interpolados$Infeccion<-as.factor(samples_interpolados$Infeccion)


samples_final <- bind_rows(samples_modificado, samples_interpolados) %>%
  arrange(resident_code, date_samples)  # Ordenar por paciente y fecha
samples_final <- samples_final %>% 
  arrange(resident_code, date_samples) %>% # Ordenar por paciente y fecha
  
  group_by(resident_code) %>%
  mutate(lapse = as.integer(difftime(date_samples, lag(date_samples), units = "days"))) %>%
  
  mutate(lapse = ifelse(is.na(lapse), 0, lapse)) %>%
  
  ungroup()  
head(samples_final)

tabla2<-samples_final %>%
  dplyr::select(lapse) 

tabla2 <- tabla2 %>% dplyr::slice(-1)

nueva_fila2 <- data.frame(matrix(0, nrow = 1, ncol = ncol(tabla2))) 

colnames(nueva_fila2) <- colnames(tabla2)

tabla2 <- rbind(tabla2, nueva_fila2)

samples_final$siguiente2<-tabla2$lapse


samples_final$lapse<-as.integer(samples_final$lapse)
samples_final$siguiente2<-as.integer(samples_final$siguiente2)

caso_dos_tipo1 <- samples_Q %>%
  dplyr::select(Infeccion, body_temp, SPO2.Min, BPM.Avg, EDA.Avg, tmed, sol,presMean) %>%
  filter(Infeccion == 1)

caso_dos_tipo2 <- samples_Q %>%
  dplyr::select(Infeccion, body_temp, SPO2.Min, BPM.Avg, EDA.Avg, tmed, sol,presMean) %>%
  filter(Infeccion == 2)

caso_dos_tipo3 <- samples_Q %>%
  dplyr::select(Infeccion, body_temp, SPO2.Min, BPM.Avg, EDA.Avg, tmed, sol,presMean) %>%
  filter(Infeccion == 3)

promedios_caso2_tipo1 <- colMeans(caso_dos_tipo1[, sapply(caso_dos_tipo1, is.numeric)], na.rm = TRUE)
promedios_caso2_tipo2 <- colMeans(caso_dos_tipo2[, sapply(caso_dos_tipo2, is.numeric)], na.rm = TRUE)
promedios_caso2_tipo3 <- colMeans(caso_dos_tipo3[, sapply(caso_dos_tipo3, is.numeric)], na.rm = TRUE)

minimos_caso2_tipo1 <- caso_dos_tipo1 %>%
  summarise(across(where(is.numeric), ~quantile(.x, 0.25, na.rm = TRUE)))
minimos_caso2_tipo2 <- caso_dos_tipo2 %>%
  summarise(across(where(is.numeric), ~quantile(.x, 0.25, na.rm = TRUE)))
minimos_caso2_tipo3 <- caso_dos_tipo3 %>%
  summarise(across(where(is.numeric), ~quantile(.x, 0.25, na.rm = TRUE)))


interpolar_nulos_infeccion <- function(df) {
  
  vars_interpolar <- c("body_temp", "SPO2.Min", "BPM.Avg", "EDA.Avg", "tmed", "sol", "presMean")
  
  if (df$Infeccion[1] == 1) {
    minimos <- minimos_caso2_tipo1
    promedios <- promedios_caso2_tipo1
  } else if (df$Infeccion[1] == 2) {
    minimos <- minimos_caso2_tipo2
    promedios <- promedios_caso2_tipo2
  } else {
    minimos <- minimos_caso2_tipo3
    promedios <- promedios_caso2_tipo3
  }
  
  for (var in vars_interpolar) {
    if (any(is.na(df[[var]]))) {
      datos_validos <- !is.na(df[[var]])
      
      if (sum(datos_validos) >= 2) {  
        interpolados <- spline(df$date_samples[datos_validos], df[[var]][datos_validos], 
                               xout = df$date_samples[is.na(df[[var]])], method = "natural")$y
        
        interpolados <- pmax(pmin(interpolados, promedios[var]), minimos[[var]])
        
        df[[var]][is.na(df[[var]])] <- interpolados
      }
    }
  }
  
  return(df)
}
samples_final_completado <- samples_final %>%
  group_by(resident_code) %>%
  group_split() %>%
  lapply(interpolar_nulos_infeccion) %>%
  bind_rows() %>%
  arrange(resident_code, date_samples)

samples_final <- samples_final_completado




## ajuste de modelos se añade:
samples_final$infeccionBinaria <- ifelse(samples_final$Infeccion == 0, 0, 1)

samples_final$infeccionBinaria <- factor(samples_final$infeccionBinaria)

samples_final <- samples_final %>%
  arrange(resident_code, date_samples) %>%          
  group_by(resident_code) %>%                
  mutate(observacion = row_number()) %>%  
  ungroup()

samples_final$sex<-as.factor(samples_final$sex)

samples_final$date_samples <- as.Date(samples_final$date_samples, format = "%Y-%m-%d %H:%M:%S.%OS")


samples_final$presMean_scaled <- (samples_final$presMean - mean(samples_final$presMean)) / sd(samples_final$presMean)

samples_final$resident_code <- as.factor(samples_final$resident_code)


samples_final <- samples_final |> mutate(
  Infeccion_ordinal = case_when(
    Infeccion == 1 ~ 1,  # STI
    Infeccion == 3 ~ 2,  # UTI
    Infeccion == 2 ~ 3,  # ARI
    Infeccion == 0 ~ 0  
  )
)

samples_final$Infeccion_ordinal <- as.factor(samples_final$Infeccion_ordinal)

samples_final$Infeccion_ordinal <- factor(samples_final$Infeccion_ordinal,
                                          levels = c("0", "1", "2", "3"),
                                          ordered = TRUE)

samples_final$Infeccion <- factor(samples_final$Infeccion)

as.data.frame(samples_final)
