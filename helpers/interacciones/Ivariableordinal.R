# Ivariableordinal.R: implementa la lógica para construir y ajustar modelos
# ordinales dentro de la aplicación. Permite seleccionar el tipo de ajuste,
# elegir las variables explicativas, definir pendientes aleatorias cuando el
# modelo lo requiere y mostrar la fórmula, el resumen y las métricas principales
# del modelo ajustado. Además, controla el asistente paso a paso y la navegación
# de regreso al panel de ajuste de modelos.

etiquetas <- c(
  "Edad" = "age",
  "Sexo" = "sex",
  "Temperatura Corporal (°C)" = "body_temp",
  "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
  "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
  "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
  "Temperatura Ambiente Promedio (°C)" = "tmed",
  "Radiación Solar (MJ/m²)" = "sol",
  "Presión Atmosférica Media (hPa)" = "presMean_scaled"
)


output$pendiente_selector_ordinal <- renderUI({
  if (input$modelo_tipo_ordinal == "pendiente") {
    # Filtra las etiquetas para solo mostrar las seleccionadas
    etiquetas_filtradas <- etiquetas[names(etiquetas) %in% names(etiquetas[etiquetas %in% input$vars_ordinal])]
    
    checkboxGroupInput(
      "slope_ordinal",
      "Selecciona variables para pendientes aleatorias:",
      choices = setNames(etiquetas_filtradas, names(etiquetas_filtradas))
    )
  }
})


observeEvent(input$ajustar_modelo_ordinal, {
  req(input$vars_ordinal)
  
  fixed <- paste(input$vars_ordinal, collapse = " + ")
  formula_text <- paste("Infeccion_ordinal ~", fixed)
  
  if (input$modelo_tipo_ordinal == "intercepto") {
    formula_text <- paste0(formula_text, " + (1 | resident_code)")
  } else if (input$modelo_tipo_ordinal == "pendiente" && length(input$slope_ordinal) > 0) {
    random_slopes <- paste(input$slope_ordinal, collapse = " + ")
    formula_text <- paste0(formula_text, " + (1 + ", random_slopes, " | resident_code)")
  }
  
  formula_obj <- as.formula(formula_text)
  
  output$formula_ordinal <- renderText({
    paste("Fórmula del modelo:", formula_text)
  })
  
  tryCatch({
    modelo <- if (input$modelo_tipo_ordinal == "fijo") {
      clm(formula_obj, data = samples_final,
          control = clm.control(maxIter = 100, gradTol = 1e-4))
    } else {
      clmm(formula_obj, data = samples_final, link = "logit")
    }
    
    
    output$resumen_ordinal <- renderPrint({
      summary(modelo)
    })
    
    output$metricas_ordinal <- renderPrint({
      cat("AIC:", AIC(modelo), "\n")
      cat("BIC:", BIC(modelo), "\n")
      cat("Log-Likelihood:", logLik(modelo), "\n")
    })
    
    output$error_ordinal <- renderText({ "" })
    
  }, error = function(e) {
    output$resumen_ordinal <- renderPrint({ NULL })
    output$metricas_ordinal <- renderText({ "" })
    output$error_ordinal <- renderText({
      paste("Error al ajustar el modelo:", e$message)
    })
  })
})


# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_variableordinal_ajustarmodelo, {
  valores$pagina <- "ajustar_modelo"
})




observe({
  if (is.null(valores$paso_ordinal)) valores$paso_ordinal <- 1
})


observeEvent(input$siguiente_ordinal, {
  # Paso 2 y modelo NO requiere paso intermedio → saltamos al resumen directamente
  if (valores$paso_ordinal == 2 && input$modelo_tipo_ordinal != "pendiente") {
    valores$paso_ordinal <- 4
  } else {
    valores$paso_ordinal <- valores$paso_ordinal + 1
  }
})


observeEvent(input$anterior_ordinal, {
  if (valores$paso_ordinal > 1) valores$paso_ordinal <- valores$paso_ordinal - 1
})



output$encuesta_ui_ordinal <- renderUI({
  paso <- valores$paso_ordinal
  
  switch(paso,
         "1" = radioButtons("modelo_tipo_ordinal", "Selecciona el modelo que quiere ajustar:",
                            choices = c("Modelo de efectos fijos" = "fijo",
                                        "Modelo de efectos-mixtos con intercepto aleatorio" = "intercepto",
                                        "Modelo de efectos-mixtos con intercepto y pendiente aleatorias" = "pendiente")),
         "2" = checkboxGroupInput("vars_ordinal", "Selecciona las variables explicativas de tu modelo:",
                                  choices = c(
                                    "Edad" = "age",
                                    "Sexo" = "sex",
                                    "Temperatura Corporal (°C)" = "body_temp",
                                    "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
                                    "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
                                    "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
                                    "Temperatura Ambiente Promedio (°C)" = "tmed",
                                    "Radiación Solar (MJ/m²)" = "sol",
                                    "Presión Atmosférica Media (hPa)" = "presMean_scaled"
                                  )
         ),
         "3" = uiOutput("pendiente_selector_ordinal"),  # Solo llega si el modelo es mixto pendiente
         "4" = tagList(
           h4("Resumen del modelo"),
           verbatimTextOutput("formula_ordinal"),
           verbatimTextOutput("resumen_ordinal"),
           verbatimTextOutput("metricas_ordinal"),
           verbatimTextOutput("error_ordinal")
         )
  )
})



# Mostrar u ocultar botones
output$mostrarAnterior <- reactive({
  valores$paso_ordinal > 1 && valores$paso_ordinal <= 3
})




output$mostrarReset <- reactive({
  valores$paso_ordinal == 4
})
outputOptions(output, "mostrarReset", suspendWhenHidden = FALSE)

observeEvent(input$resetear_ordinal, {
  valores$paso_ordinal <- 1
})

outputOptions(output, "mostrarAnterior", suspendWhenHidden = FALSE)



output$mostrarSiguiente <- reactive({
  (valores$paso_ordinal == 1) || 
    (valores$paso_ordinal == 2 && input$modelo_tipo_ordinal== "pendiente")
})
outputOptions(output, "mostrarSiguiente", suspendWhenHidden = FALSE)



output$mostrarAjustar <- reactive({
  (valores$paso_ordinal == 2 && input$modelo_tipo_ordinal != "pendiente") ||
    valores$paso_ordinal == 3
})
outputOptions(output, "mostrarAjustar", suspendWhenHidden = FALSE)


# Al hacer clic en "Ajustar modelo", mostrar siguiente paso con resumen
observeEvent(input$ajustar_modelo_ordinal, {
  # Aquí haces el ajuste del modelo...
  valores$paso_ordinal <- 4
})




