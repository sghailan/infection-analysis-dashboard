# navegacion.R: prepara los datos, filtros reactivos y funciones auxiliares que alimentan las visualizaciones y la navegación de la app

# ---- necesidades ----
## Necesidades para ciertos graficos

### Necesario para grafico temporal de infecciones con lineas temporales
resumen_infecciones <- diagnostics_Q %>%
  group_by(resident_code) %>%
  summarise(num = n(), .groups = "drop") %>%
  mutate(label = paste0(resident_code, " (", num, ifelse(num == 1, " infección", " infecciones"), ")"))


### Necesario para gráfico grafos
tabla_transiciones <- diagnostics_Q %>%
  arrange(resident_code, date_diagnosis) %>%
  group_by(resident_code) %>%
  mutate(
    lapse = as.numeric(date_diagnosis - lag(date_diagnosis)),
    from = lag(Types_of_Infectious),
    to = Types_of_Infectious
) %>%
ungroup()

### necesario para boxplot
vars_fisiologicas <- c("body_temp", "SPO2.Min", "BPM.Avg", "EDA.Avg", "tmed", "sol", "presMean")

df_long <- samples_Q %>%
  pivot_longer(cols = all_of(vars_fisiologicas),
               names_to = "variable",
               values_to = "valor")


### necesario para wilcoxin
# Preprocesado de los datos
samples_base <- samples_Q %>%
  mutate(
    sex = as.factor(sex),
    Institution = as.factor(Institution)
  ) %>%
  filter(!is.na(sex) | !is.na(Institution)) %>%
  dplyr::select(resident_code, sex, Institution, all_of(vars_fisiologicas))


# ---- filtrados ----
## Filtrar datos para generalizaciones de los graficos

### Filtrar datos según el paciente seleccionado en samples_Q (original)
paciente_data <- reactive({
  samples_Q %>%
    filter(as.numeric(as.character(resident_code)) == input$selected_patient) %>%
    arrange(date_samples)
})

### Filtrar datos según el paciente seleccionado en samples_final (interpolado)
paciente_data2 <- reactive({
  samples_final %>%
    filter(as.numeric(as.character(resident_code)) == input$selected_patient) %>%
    arrange(date_samples)
})

### Obtener solo las infecciones del paciente
infecciones_data <- reactive({
  paciente_data() %>%
    filter(Infeccion != 0) %>%
    mutate(tooltip_text = paste("Fecha:", date_samples, "<br>Tipo:", Infeccion))
})

### Obtener información específica del paciente
paciente_info <- reactive({
  paciente <- paciente_data()
  if (nrow(paciente) == 0) {
    return(NULL)
  }
  list(
    edad = unique(paciente$age),
    genero = unique(paciente$sex),
    institucion = unique(paciente$Institution),
    berthel = unique(paciente$berthel_index)
  )
})


### Necesario para calendario 
# Datos base
infecciones_por_dia <- diagnostics_Q %>%
  mutate(fecha = as.Date(date_diagnosis)) %>%
  group_by(fecha) %>%
  summarise(
    n = n(),
    tipos = paste(unique(Types_of_Infectious), collapse = ", "),
    residentes = paste(unique(resident_code), collapse = ", ")
  ) %>%
  ungroup()

mes_nombre_es <- function(mes) {
  c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
    "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")[mes]
}

crear_calendario_cuadricula <- function(mes, anio, datos) {
  fecha_inicio <- as.Date(sprintf("%s-%02d-01", anio, mes))
  fecha_fin <- as.Date(sprintf("%s-%02d-%02d", anio, mes, days_in_month(fecha_inicio)))
  dias_mes <- seq(fecha_inicio, fecha_fin, by = "day")
  
  df <- data.frame(
    fecha = dias_mes,
    dia_semana = wday(dias_mes, week_start = 1),
    semana = as.integer((day(dias_mes) + wday(floor_date(dias_mes, "month"), week_start = 1) - 2) / 7) + 1
  ) %>%
    left_join(datos, by = "fecha")
  
  df$hover <- paste0(" Día: ", day(df$fecha),
                     "<br> Infecciones: ", ifelse(is.na(df$n), 0, df$n),
                     "<br> Tipos: ", ifelse(is.na(df$tipos), "-", df$tipos),
                     "<br> Residentes: ", ifelse(is.na(df$residentes), "-", df$residentes))
  
  plot_ly(
    data = df,
    x = ~dia_semana,
    y = ~-semana,
    type = "scatter",
    mode = "text+markers",
    text = ~day(fecha),
    textposition = "middle center",
    marker = list(
      size = 17,
      color = ifelse(is.na(df$n), "#f0f0f0", "#ff6666"),
      line = list(color = "#cccccc", width = 1)
    ),
    hoverinfo = "text",
    textfont = list(color = "black"),
    customdata = ~as.character(fecha),  # << clave para detectar día
    hovertext = ~hover,
    source = paste0("mes_", mes)
  ) %>%
    layout(
      title = list(text = paste0(mes_nombre_es(mes)), x = 0.5),
      xaxis = list(
        title = "",
        tickmode = "array",
        tickvals = 1:7,
        ticktext = c("Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"),
        showgrid = FALSE,
        zeroline = FALSE,
        showticklabels = TRUE,
        ticks = "outside",
        tickangle = 0,
        side = "top",
        tickfont = list(size = 8)
      ),
      yaxis = list(
        title = "",
        showgrid = FALSE,
        zeroline = FALSE,
        showticklabels = FALSE
      ),
      margin = list(t = 40, b = 10, l = 5, r = 5),
      showlegend = FALSE
    )
}



## TABLAS CRUZADAS 

# Campos disponibles por dataset
vars_samples <- c("Código de residente" = "resident_code",
                  "Sexo" = "sex",
                  "Edad" = "age",
                  "Índice de Barthel" = "berthel_index",
                  "Año de muestra" = "Año",
                  "Mes" = "Mes",
                  "Día" = "Día",
                  "Tipo de infección" = "Infeccion")

vars_diagnostics <- c("Código de residente" = "resident_code",
                      "Institución" = "Institution",
                      "Tipo de infección diagnosticada" = "Types_of_Infectious",
                      "Fecha de diagnóstico" = "date_diagnosis")




## grafico diferencias el 7
resumen_general <- diagnostics_Q %>%
  group_by(Institution) %>%
  summarise(
    total_pacientes = n_distinct(resident_code),
    total_diagnosticos = n(),
    primera_fecha = min(date_diagnosis),
    ultima_fecha = max(date_diagnosis),
    duracion_meses = as.numeric(difftime(ultima_fecha, primera_fecha, units = "days")) / 30.44,
    .groups = "drop"
  ) %>%
  mutate(
    diagn_por_paciente = total_diagnosticos / total_pacientes,
    diagn_por_mes = total_diagnosticos / duracion_meses
  )

diagnosticos_por_paciente <- diagnostics_Q %>%
  group_by(Institution, resident_code) %>%
  summarise(n_diagnosticos = n(), .groups = "drop") %>%
  group_by(Institution) %>%
  summarise(
    max_nro_diag_paciente = max(n_diagnosticos),
    .groups = "drop"
  )

lapse_stats <- diagnostics_Q %>%
  group_by(Institution) %>%
  summarise(
    media_lapse = mean(lapse_inf, na.rm = TRUE),
    .groups = "drop"
  )

resumen_completo <- resumen_general %>%
  left_join(diagnosticos_por_paciente, by = "Institution") %>%
  left_join(lapse_stats, by = "Institution")

plazas_reales <- data.frame(
  Institution = c("Cisneros", "FcoVitoria"),
  plazas_reales = c(129, 526)
)

resumen_completo <- resumen_general %>%
  left_join(diagnosticos_por_paciente, by = "Institution") %>%
  left_join(lapse_stats, by = "Institution") %>%
  left_join(plazas_reales, by = "Institution") %>%
  mutate(
    cobertura_dataset = total_pacientes / plazas_reales,
    diagn_por_plaza = total_diagnosticos / plazas_reales,
    diagn_por_mes_plaza = diagn_por_mes / plazas_reales
  )


resumen_long <- resumen_completo %>%
  dplyr::select(Institution, 
                `Diagnósticos por paciente` = diagn_por_paciente,
                `Diagnósticos por mes` = diagn_por_mes,
                `Diagnósticos por mes y plaza` = diagn_por_mes_plaza,
                `Diagnósticos por plaza` = diagn_por_plaza,
                `Cobertura del dataset` = cobertura_dataset,
                `Lapse medio entre infecciones` = media_lapse,
                `Máx. diagnósticos en un paciente` = max_nro_diag_paciente
  ) %>%
  pivot_longer(-Institution, names_to = "Métrica", values_to = "Valor")

### edad discriminacion 
samples_base <- samples_Q %>%
  filter(!is.na(age)) %>%
  mutate(
    grupo_edad = ifelse(age > 85, "+85", "-85"),
    grupo_edad = factor(grupo_edad, levels = c("-85", "+85"))
  ) %>%
  dplyr::select(resident_code, sex, Institution, grupo_edad, all_of(vars_fisiologicas))
