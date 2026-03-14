# Itablacruzada.R: implementa la lógica de la tabla cruzada entre variables
# de los conjuntos de datos de muestras y diagnósticos. Permite seleccionar
# dinámicamente dos variables, genera la tabla de contingencia correspondiente
# y muestra una explicación contextual sobre el tipo de datos analizados.
# También gestiona la navegación de regreso a la sección de análisis exploratorio.

output$select_var1 <- renderUI({
  vars <- if (input$dataset == "samples") vars_samples else vars_diagnostics
  selectInput("var1", "Variable 1:", choices = vars)
})

output$select_var2 <- renderUI({
  vars <- if (input$dataset == "samples") vars_samples else vars_diagnostics
  selectInput("var2", "Variable 2:", choices = vars)
})

# Mostrar explicación según dataset
output$explicacion <- renderText({
  if (input$dataset == "samples") {
    "Has seleccionado el conjunto de muestras. Aquí puede haber valores repetidos por residente, ya que se toman múltiples muestras por paciente. La tabla cruzada refleja la distribución según frecuencia de aparición en las muestras."
  } else {
    "Has seleccionado el conjunto de diagnósticos. Cada fila representa un diagnóstico confirmado de infección. La tabla muestra cómo se distribuyen los diagnósticos entre las variables seleccionadas."
  }
})

# Renderizar la tabla cruzada
output$tabla_cruzada <- renderDT({
  req(input$var1, input$var2)
  
  df <- if (input$dataset == "samples") samples_Q else diagnostics_Q
  var1 <- input$var1
  var2 <- input$var2
  
  # Tabla cruzada como matriz
  tabla <- table(as.factor(df[[var1]]), as.factor(df[[var2]]))
  
  datatable(
    as.data.frame.matrix(tabla),
    options = list(pageLength = 10, autoWidth = TRUE),
    caption = htmltools::tags$caption(
      style = 'caption-side: top; text-align: center; font-weight: bold;',
      paste("Tabla cruzada de", var1, "y", var2)
    )
  )
})


observeEvent(input$volver_tablacruzada_movimiento, {
  valores$pagina <- "movimiento"
})