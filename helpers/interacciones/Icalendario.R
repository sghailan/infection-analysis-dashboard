# Icalendario.R: desarrolla la lógica del calendario interactivo de infecciones.
# Genera la vista mensual por cuadrícula, actualiza los gráficos según el año
# seleccionado y muestra el detalle de cada día al hacer clic sobre una fecha.
# Además, gestiona la navegación de vuelta al menú de visualización temporal.

output$grid_meses <- renderUI({
  tagList(
    div(style = "display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px;",
        lapply(1:12, function(m) {
          plotlyOutput(paste0("mes_plot_", m), height = "200px")
        })
    )
  )
})

observe({
  for (m in 1:12) {
    local({
      mes_local <- m
      output[[paste0("mes_plot_", mes_local)]] <- renderPlotly({
        crear_calendario_cuadricula(mes_local, input$anio, infecciones_por_dia)
      })
    })
  }
})

observe({
  lapply(1:12, function(m) {
    observeEvent(event_data("plotly_click", source = paste0("mes_", m)), {
      showModal(modalDialog(
        title = HTML(paste0("<div style='text-align:center;'>", mes_nombre_es(m), "</div>")),
        size = "l",
        easyClose = TRUE,
        footer = modalButton("Cerrar"),
        tagList(
          renderPlotly({ crear_calendario_cuadricula(m, input$anio, infecciones_por_dia) }),
          hr(),
          verbatimTextOutput("detalle_dia_modal")
        )
      ))
      
      observeEvent(event_data("plotly_click", source = paste0("mes_", m)), {
        info_dia <- event_data("plotly_click", source = paste0("mes_", m))
        if (!is.null(info_dia)) {
          fecha_clic <- as.Date(info_dia$customdata)
          datos_detalle <- infecciones_por_dia %>% filter(fecha == fecha_clic)
          
          output$detalle_dia_modal <- renderText({
            if (nrow(datos_detalle) == 0) {
              paste("Fecha:", fecha_clic, "\nSin registros de infección.")
            } else {
              paste0(
                "Fecha: ", fecha_clic, "\n",
                "Número de infecciones: ", datos_detalle$n, "\n",
                "Tipos: ", datos_detalle$tipos, "\n",
                "Residentes: ", datos_detalle$residentes
              )
            }
          })
        }
      })
    })
  })
})


# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_calendario_eligetiempo, {
  valores$pagina <- "eligetiempo"
})
