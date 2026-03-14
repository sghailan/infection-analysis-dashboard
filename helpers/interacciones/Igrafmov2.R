# Igrafmov2.R: genera la visualización temporal de los diagnósticos de infección
# para los pacientes seleccionados. Muestra líneas de tiempo con el periodo entre
# la primera y la última infección registrada, así como los puntos individuales
# donde se producen los diagnósticos. También gestiona la navegación de vuelta
# al menú de visualización temporal.

datos_filtrados <- reactive({
  req(input$residente_select)

  
  
# Resumen por residente
  resumen <- diagnostics_Q %>%
    filter(resident_code %in% input$residente_select) %>%
    group_by(resident_code) %>%
    summarise(
      primera = min(date_diagnosis),
      ultima = max(date_diagnosis),
      num_infecciones = n(),
      .groups = "drop"
    )
  
  # Puntos de infección
  puntos <- diagnostics_Q %>%
    filter(resident_code %in% input$residente_select) %>%
    dplyr::select(resident_code, date_diagnosis)
  
  list(resumen = resumen, puntos = puntos)
})

output$timeline_plot <- renderPlotly({
  datos <- datos_filtrados()
  
  fig <- plot_ly()
  
  # Líneas de tiempo
  fig <- fig %>%
    add_segments(
      data = datos$resumen,
      x = ~primera,
      xend = ~ultima,
      y = ~as.factor(resident_code),
      yend = ~as.factor(resident_code),
      mode = 'lines',
      line = list(color = 'gray'),
      hoverinfo = 'text',
      name = "Líneas temporales", 
      text = ~paste("<b>Periodo de infección</b>",
                    "<br>Paciente:", resident_code,
                    "<br>Infecciones:", num_infecciones,
                    "<br>Duración:", as.numeric(ultima - primera), "días")
      
    )
  
  # Puntos de infección
  fig <- fig %>%
    add_markers(
      data = datos$puntos,
      x = ~date_diagnosis,
      y = ~as.factor(resident_code),
      marker = list(color = 'red', size = 6),
      hoverinfo = 'text',
      name = "Infecciones", 
      text = ~paste("Paciente:", resident_code,
                    "<br>Fecha de infección:", date_diagnosis)
    )
  
  fig <- fig %>%
    layout(
      title = "Líneas temporales de infecciones por residente",
      xaxis = list(title = "Fecha"),
      yaxis = list(title = "Paciente", categoryorder = "total ascending"),
      legend = list(title = list(text = "Elementos del gráfico"))  # 👈 Título para la leyenda
    )
  
  fig
})


# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_grafmov2_eligetiempo, {
  valores$pagina <- "eligetiempo"
})


