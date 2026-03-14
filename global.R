# global.R: carga librerías, importa los datasets y realiza el preprocesamiento inicial necesario para la app

# ---- librerias ----
source("helpers/librerias.R", local = TRUE)

# ---- carga diagnos ----
diagnostics_Q <- readxl::read_excel("diagnostics_Q_2.xlsx",.name_repair = "minimal")

colnames(diagnostics_Q)[colnames(diagnostics_Q) == "Types of Infectious"] <- "Types_of_Infectious"
diagnostics_Q <- diagnostics_Q[, -1]
diagnostics_Q <- diagnostics_Q %>% distinct()

diagnostics_Q$resident_code <- as.factor(diagnostics_Q$resident_code)
diagnostics_Q$Institution <- as.factor(diagnostics_Q$Institution)
diagnostics_Q$Types_of_Infectious<-as.factor(diagnostics_Q$Types_of_Infectious)
diagnostics_Q$date_diagnosis <- as.Date(diagnostics_Q$date_diagnosis, format = "%d/%m/%Y")


diagnostics_Q <- diagnostics_Q %>%
  arrange(resident_code, date_diagnosis) %>%  
  group_by(resident_code) %>%
  mutate(
    lapse_inf = as.integer(date_diagnosis - lag(date_diagnosis, default = first(date_diagnosis))),
    lapse_inf = replace(lapse_inf, row_number() == 1, 0) 
  ) %>%
  ungroup()

diagnostics_Q <- as.data.frame(diagnostics_Q)

# ---- carga samples ----
samples_Q<- read_excel("samplesfinal.xlsx")

colnames(samples_Q)[colnames(samples_Q) == "SPO2 Min"] <- "SPO2.Min"
colnames(samples_Q)[colnames(samples_Q) == "BPM Avg"] <- "BPM.Avg"
colnames(samples_Q)[colnames(samples_Q) == "EDA Avg"] <- "EDA.Avg"

df.uni<- diagnostics_Q %>%
  distinct(resident_code, Institution, .keep_all = TRUE) %>%
  dplyr::select(resident_code, Institution)
samples_Q$resident_code<- as.factor(samples_Q$resident_code)
samples_Q <- samples_Q %>%
  left_join(df.uni, by = "resident_code")
samples_Q <- samples_Q %>%
  dplyr::select(resident_code,Institution, everything())

samples_Q$sex<-as.factor(samples_Q$sex)
samples_Q$date_samples <- as.Date(samples_Q$date_samples, format = "%Y-%m-%d %H:%M:%S.%OS")
samples_Q$Año<-as.factor(samples_Q$Año)
samples_Q$Mes<-as.factor(samples_Q$Mes)
samples_Q$dia<-as.factor(samples_Q$dia)
samples_Q$Infeccion<-as.factor(samples_Q$Infeccion)

samples_Q <- as.data.frame(samples_Q)
tabla<-samples_Q %>%
  dplyr::select(lapse) 
tabla <- tabla %>% dplyr::slice(-1)
nueva_fila <- data.frame(matrix(0, nrow = 1, ncol = ncol(tabla))) 
colnames(nueva_fila) <- colnames(tabla)
tabla <- rbind(tabla, nueva_fila)
samples_Q$siguiente<-tabla$lapse
samples_Q$lapse<-as.integer(samples_Q$lapse)
samples_Q$siguiente<-as.integer(samples_Q$siguiente)

# ---- carga interp ----
source("helpers/interpolacion.R", local = TRUE)

