# Ivariablebinaria.R: implementa la lógica necesaria para construir y ajustar
# un modelo binario dentro de la aplicación. Permite seleccionar el tipo de
# ajuste, elegir las variables explicativas, definir pendientes aleatorias cuando
# el modelo lo requiere y mostrar tanto la fórmula final como el resumen y las
# métricas principales del ajuste. Además, controla el flujo paso a paso del
# asistente, así como la navegación de regreso al panel de selección de modelos.

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


output$pendiente_selector_binaria <- renderUI({
  if (input$modelo_tipo_binaria == "pendiente") {
    # Filtra las etiquetas para solo mostrar las seleccionadas
    etiquetas_filtradas <- etiquetas[names(etiquetas) %in% names(etiquetas[etiquetas %in% input$vars_binaria])]
    
    checkboxGroupInput(
      "slope_binaria",
      "Selecciona variables para pendientes aleatorias:",
      choices = setNames(etiquetas_filtradas, names(etiquetas_filtradas))
    )
  }
})



observeEvent(input$ajustar_modelo_binaria, {
  req(input$vars_binaria)
  
  # Construcción de fórmula
  vars_text <- paste(input$vars_binaria, collapse = " + ")
  formula_text <- paste("infeccionBinaria ~", vars_text)
  
  if (input$modelo_tipo_binaria == "intercepto") {
    formula_text <- paste0(formula_text, " + (1 | resident_code)")
  } else if (input$modelo_tipo_binaria == "pendiente" && length(input$slope_binaria) > 0) {
    pendientes <- paste(input$slope_binaria, collapse = " + ")
    formula_text <- paste0(formula_text, " + (1 + ", pendientes, " | resident_code)")
  }
  
  
  formula_obj <- as.formula(formula_text)
  
  output$formula_binaria <- renderText({
    paste("Fórmula del modelo:", formula_text)
  })
  
  tryCatch({
    modelo <- if (input$modelo_tipo_binaria == "fijo") {
      glm(formula_obj, data = samples_final, family = binomial)
    } else {
      glmer(formula_obj, data = samples_final, family = binomial)
    }
    
    
    output$resumen_binaria <- renderPrint({
      summary(modelo)
    })
    
    output$metricas_binaria <- renderPrint({
      cat("AIC:", AIC(modelo), "\n")
      cat("BIC:", BIC(modelo), "\n")
      cat("Log-Likelihood:", logLik(modelo), "\n")
      if ("deviance" %in% names(modelo)) {
        cat("Deviance:", deviance(modelo), "\n")
      } else {
        cat("Deviance no disponible para este tipo de modelo\n")
      }
    })
    
    output$error_binaria <- renderText({ "" })
    
  }, error = function(e) {
    output$resumen_binaria <- renderPrint({ NULL })
    output$metricas_binaria <- renderText({ "" })
    output$error_binaria <- renderText({
      paste("Error al ajustar el modelo:", e$message)
    })
  })
})



# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_variablebinaria_ajustarmodelo, {
  valores$pagina <- "ajustar_modelo"
})





observe({
  if (is.null(valores$paso_binaria)) valores$paso_binaria <- 1
})

observeEvent(input$siguiente_binaria, {
  # Paso 2 y modelo NO requiere paso intermedio → saltamos al resumen directamente
  if (valores$paso_binaria == 2 && input$modelo_tipo_binaria != "pendiente") {
    valores$paso_binaria <- 4
  } else {
    valores$paso_binaria <- valores$paso_binaria + 1
  }
})


observeEvent(input$anterior_binaria, {
  if (valores$paso_binaria > 1) valores$paso_binaria <- valores$paso_binaria - 1
})



output$encuesta_ui_binaria <- renderUI({
  paso <- valores$paso_binaria
  
  switch(paso,
         "1" = radioButtons("modelo_tipo_binaria", "Selecciona el modelo que quiere ajustar:",
                            choices = c("Modelo logístico sin efectos individuales" = "fijo",
                                        "Modelo de efectos-mixtos con intercepto aleatorio" = "intercepto",
                                        "Modelo de efectos-mixtos con intercepto y pendiente aleatorias" = "pendiente")),
         "2" = checkboxGroupInput("vars_binaria", "Selecciona las variables explicativas de tu modelo:",
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
         "3" = uiOutput("pendiente_selector_binaria"),  # Solo llega si el modelo es mixto pendiente
         "4" = tagList(
           h4("Resumen del modelo"),
           verbatimTextOutput("formula_binaria"),
           verbatimTextOutput("resumen_binaria"),
           verbatimTextOutput("metricas_binaria"),
           verbatimTextOutput("error_binaria")
         )
  )
})



# Mostrar u ocultar botones
output$mostrarAnterior_binaria <- reactive({
  valores$paso_binaria > 1 && valores$paso_binaria <= 3
})




output$mostrarReset_binaria <- reactive({
  valores$paso_binaria == 4
})
outputOptions(output, "mostrarReset_binaria", suspendWhenHidden = FALSE)

observeEvent(input$resetear_binaria, {
  valores$paso_binaria <- 1
})

outputOptions(output, "mostrarAnterior_binaria", suspendWhenHidden = FALSE)




output$mostrarSiguiente_binaria <- reactive({
  (valores$paso_binaria == 1) || 
    (valores$paso_binaria == 2 && input$modelo_tipo_binaria == "pendiente")
})
outputOptions(output, "mostrarSiguiente_binaria", suspendWhenHidden = FALSE)



output$mostrarAjustar_binaria <- reactive({
  (valores$paso_binaria == 2 && input$modelo_tipo_binaria != "pendiente") ||
    valores$paso_binaria == 3
})
outputOptions(output, "mostrarAjustar_binaria", suspendWhenHidden = FALSE)


# Al hacer clic en "Ajustar modelo", mostrar siguiente paso con resumen
observeEvent(input$ajustar_modelo_binaria, {
  # Aquí haces el ajuste del modelo...
  valores$paso_binaria <- 4
})


