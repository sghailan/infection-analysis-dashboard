# Iinfomain.R: desarrolla la lógica principal de la página de información del paciente.
# Gestiona la selección de infecciones, construye la tabla de detalle asociada a cada
# episodio y genera el gráfico interactivo con la evolución temporal de las variables
# fisiológicas, tanto con datos originales como interpolados. Además, integra los
# botones y componentes auxiliares definidos en otros scripts de esta sección.

output$infection_selector <- renderUI({
  infecciones <- infecciones_data()
  
  if (nrow(infecciones) == 0) {
    return(NULL)  # Si no hay infecciones, no mostrar nada
  }
  
  # Mapear los tipos de infección a texto
  tipo_labels <- c("1" = "STI", "2" = "ARI", "3" = "UTI")
  tipos_convertidos <- tipo_labels[as.character(infecciones$Infeccion)]
  
  selectInput(
    "selected_infection", 
    "Seleccionar Infección:",
    choices = setNames(
      format(infecciones$date_samples, "%Y-%m-%d"),
      paste("Fecha:", format(infecciones$date_samples, "%Y-%m-%d"), "| Tipo:", tipos_convertidos)
    ),
    selected = NULL, 
    multiple = FALSE
  )
})



output$infection_table <- renderUI({
  infecciones <- infecciones_data()
  selected_fecha <- input$selected_infection
  
  if (is.null(selected_fecha) || nrow(infecciones) == 0) {
    return(HTML("<p>No hay infecciones registradas para este paciente.</p>"))
  }
  
  # Convertir la fecha seleccionada a Date para hacer la comparación
  selected_fecha <- as.Date(selected_fecha)
  
  # Filtrar la infección seleccionada
  infeccion_filtrada <- infecciones %>% filter(date_samples == selected_fecha)
  
  if (nrow(infeccion_filtrada) == 0) {
    return(HTML("<p>No se ha encontrado la infección seleccionada.</p>"))
  }
  
  tipo_labels <- c("1" = "STI", "2" = "ARI", "3" = "UTI")
  
  tabla <- infeccion_filtrada %>%
    mutate(
      `Tipo de Infección` = tipo_labels[as.character(Infeccion)],
      Fecha = format(date_samples, "%Y-%m-%d")
    ) %>%
    dplyr::select(
      Fecha,
      `Tipo de Infección`,
      `Días desde muestra anterior` = lapse,
      `Días hasta muestra siguiente` = siguiente
    )
  
  htmlTable::htmlTable(
    tabla,
    align = "lccc",
    rnames = FALSE,
    css.cell = "padding: 6px; border: 1px solid #ddd;",
    css.table = "width:100%; border-collapse: collapse; margin-top:10px;"
  )
})





##Grafico info pacientes
nombre_variable_amigable <- c(
  "body_temp"   = "Temperatura Corporal (°C)",
  "SPO2.Min"    = "Saturación de Oxígeno Mínima (%)",
  "BPM.Avg"     = "Frecuencia Cardíaca Promedio (lat/min)",
  "EDA.Avg"     = "Actividad Electrodérmica Promedio (μS)",
  "tmed"        = "Temperatura Ambiente Promedio (°C)",
  "sol"         = "Radiación Solar (MJ/m²)",
  "presMean"    = "Presión Atmosférica Media (hPa)"
)

# Renderizar el gráfico interactivo
output$plot <- renderPlotly({
  paciente <- paciente_data()
  interpolados <- paciente_data2()
  infecciones <- infecciones_data()
  
  # Calculamos los valores mínimos y máximos para los ejes X e Y
  min_date <- min(c(paciente$date_samples, interpolados$date_samples), na.rm = TRUE)
  max_date <- max(c(paciente$date_samples, interpolados$date_samples), na.rm = TRUE)
  
  # Destacar la infección seleccionada por el usuario
  selected_infection <- input$selected_infection
  if (!is.null(selected_infection)) {
    selected_infection <- as.Date(selected_infection)
  }
  
  ### Crear el gráfico dinámico
  infecciones$color_tipo <- if (!is.null(selected_infection)) {
    ifelse(infecciones$date_samples == selected_infection, "Seleccionada", "Infección")
  } else {
    rep("Infección", nrow(infecciones))
  }
  
  p <- if(input$selected_grafico == "Original") {
    ggplot(paciente, aes(x = date_samples, y = .data[[input$selected_variable]])) +
      geom_line(color = "blue", linewidth = 0.5, alpha = 0.7) +  # Línea de la variable seleccionada
      
      # Puntos diferenciando infecciones con tooltip
      geom_point(aes(
        color = factor(case_when(
          Infeccion != 0 ~ "Infección",
          TRUE ~ "Normal"
        )),
        text = paste0(
          "Fecha muestra: ", format(date_samples, "%Y-%m-%d"), "\n",
          "Valor: ", .data[[input$selected_variable]], "\n",
          "Estado: ", factor(case_when(
            Infeccion != 0 ~ "Infectado",
            TRUE ~ "No Infectado")),"\n",
          "Días desde la anterior muestra: ", as.character(lapse),"\n",
          "Días para la siguiente muestra: ", as.character(unlist(siguiente))
        )
      ), size = 2) +
      
      # Marcar infecciones con líneas interactivas
      geom_segment(data = infecciones, 
                   aes(x = date_samples, xend = date_samples, 
                       y = min(paciente[[input$selected_variable]], na.rm = TRUE) - 1, 
                       yend = max(paciente[[input$selected_variable]], na.rm = TRUE) + 1, 
                       text = tooltip_text,
                       color = color_tipo),   
                   linetype = "dashed", linewidth = 0.6)
  } else {
    # Para los datos interpolados, combinamos los datos originales y los interpolados
    paciente$source <- "Original"  # Etiquetamos los datos originales
    interpolados$source <- "Interpolado"  # Etiquetamos los datos interpolados
    
    # Combina los datos de paciente e interpolados en un solo dataframe
    combined_data <- bind_rows(paciente, interpolados)
    
    ggplot(combined_data, aes(x = date_samples, y = .data[[input$selected_variable]], color = source)) +
      geom_line(color = "blue", linewidth = 0.5, alpha = 0.7) +  # Línea de la variable seleccionada
      
      # Puntos diferenciando infecciones con tooltip
      geom_point(aes(
        text = paste0(
          "Fecha muestra: ", format(date_samples, "%Y-%m-%d"), "\n",
          "Valor : ", .data[[input$selected_variable]], "\n",
          "Estado: ", factor(case_when(
            Infeccion != 0 ~ "Infectado",
            TRUE ~ "No Infectado")),"\n",
          "Días desde la anterior muestra: ", as.character(lapse),"\n",
          "Punto: ", source
        )
      ), size = 2) +
      
      # Marcar infecciones con líneas interactivas
      geom_segment(data = infecciones, 
                   aes(x = date_samples, xend = date_samples, 
                       y = min(combined_data[[input$selected_variable]], na.rm = TRUE) - 1, 
                       yend = max(combined_data[[input$selected_variable]], na.rm = TRUE) + 1, 
                       text = tooltip_text,
                       color = color_tipo),   
                   linetype = "dashed", linewidth = 0.6)
  }
  
  # Personalizar colores
  p <- p +
    scale_color_manual(values = c("Normal" = "blue", "Infección" = "orange", "Seleccionada" = "red", "Original" = "blue", "Interpolado" = "lightblue")) + 
    
    # Ajustar formato del eje X
    scale_x_date(limits = c(min_date, max_date), date_breaks = "1 month", date_labels = "%b %Y") + 
    
    # Etiquetas y formato
    labs(
      title = paste("Evolución de", nombre_variable_amigable[input$selected_variable]),
      x = "Fecha de la muestra", 
      y = nombre_variable_amigable[input$selected_variable],
      color = "Tipo de Datos"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Convertir en gráfico interactivo con plotly
  ggplotly(p, tooltip = "text")
})


source("helpers/interacciones/Iinfo/Iinfobotones.R", local = TRUE)

















