# Igrafico.R: genera el gráfico interactivo de evolución temporal de las variables
# fisiológicas para el paciente seleccionado. Permite visualizar la dinámica de
# las variables a lo largo del tiempo, marcando además los momentos en los que se
# registran infecciones. También controla la navegación de vuelta al menú de
# selección de variables.

# Mapeo de nombres técnicos a etiquetas amigables
nombre_bonito <- c(
  "body_temp" = "Temperatura Corporal",
  "SPO2.Min" = "Saturación de Oxígeno Mínima",
  "BPM.Avg" = "Frecuencia Cardíaca Promedio",
  "EDA.Avg" = "Actividad Electrodérmica Promedio",
  "tmed" = "Temperatura Ambiente Promedio",
  "sol" = "Radiación Solar",
  "presMean" = "Presión Atmosférica Media"
)




output$moving_plot <- renderPlotly({
  
  paciente_data <- paciente_data()
  selected_vars <- input$selected_variables
  
  # Líneas de infección (discontinuas)
  lineas_infeccion <- lapply(infecciones_data()$date_samples, function(fecha) {
    list(
      type = "line",
      x0 = fecha, x1 = fecha,
      y0 = 0, y1 = 1,
      xref = "x", yref = "paper",
      line = list(color = "red", width = 2, dash = "dot")
    )
  })
  
  
  # Validar número de variables seleccionadas
  if (length(selected_vars) < 1) {
    output$no_selection_message <- renderUI({
      tags$div(
        h3("Por favor, selecciona al menos una variable para comparar su evolución temporal.")
      )
    })
    return(NULL)
  } else {
    output$no_selection_message <- renderUI({ NULL })  # Oculta mensaje si todo está bien
  }
  
  # Construcción del gráfico (como ya lo tienes)
  plot_data <- paciente_data %>%
    dplyr::select(date_samples, all_of(selected_vars)) %>%
    pivot_longer(cols = selected_vars, names_to = "var", values_to = "value") %>%
    filter(!is.na(value)) %>%
    mutate(var_bonita = nombre_bonito[var])
  
  # Función de acumulación para animación
  accumulate_by <- function(dat, var) {
    var <- lazyeval::f_eval(var, dat)
    lvls <- plotly:::getLevels(var)
    dats <- lapply(seq_along(lvls), function(x) {
      cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
    })
    dplyr::bind_rows(dats)
  }
  
  plot_data <- plot_data %>% accumulate_by(~date_samples)
  
  fig <- plot_data %>% plot_ly(
    x = ~date_samples,
    y = ~value,
    frame = ~frame,
    type = 'scatter',
    mode = 'markers',
    color = ~var_bonita,
    text = ~paste("Day: ", date_samples , "<br>Variable: ",  var_bonita, "<br>Value: ", value),
    hoverinfo = 'text',
    marker = list(size = 8)
  ) %>%
    layout(
      yaxis = list(
        title = "Valor de la Variable",
        range = c(min(plot_data$value, na.rm = TRUE)-50, max(plot_data$value, na.rm = TRUE)+50)
      ),
      xaxis = list(
        title = "Fecha",
        type = "date",
        tickformat = "%Y-%m-%d",
        range = c("2018-01-01", "2020-01-01"),
        showgrid = TRUE
      ),
      legend = list(
        title = list(text = "Variables"),
        x = 0.8, y = 0.9
      ),
      updatemenus = list(
        list(
          type = "buttons",
          x = 0.1, y = -0.15,
          buttons = list(
            list(method = "animate", label = "Pause",
                 args = list(NULL, list(frame = list(duration = 100, redraw = TRUE), mode = "immediate", fromcurrent = TRUE)))
          )
        )
      ),
      shapes = lineas_infeccion
    ) %>%
    animation_opts(frame = 100, transition = 0, redraw = FALSE) %>%
    animation_slider(currentvalue = list(prefix = "Día "))
  
  fig
})



# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_grafico_grafmov, {
  valores$pagina <- "grafmov"
})
