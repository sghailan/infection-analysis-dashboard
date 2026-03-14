# Icompararmodelo.R: contiene la lógica necesaria para construir, ajustar y comparar varios modelos
# dentro de la aplicación. Permite definir de forma dinámica el tipo de variable respuesta,
# el número de modelos a evaluar, las variables explicativas y la estructura de cada ajuste.
# Además, calcula métricas de rendimiento, muestra los resultados en una tabla comparativa
# y gestiona la navegación paso a paso del asistente de comparación.

variables_disponibles <- c("age", "sex", "body_temp", "SPO2.Min", 
                          "BPM.Avg", "EDA.Avg", "tmed", "sol", "presMean_scaled")


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

# UI dinámica para formularios de cada modelo
output$modelo_inputs <- renderUI({
  n <- input$n_modelos
  req(n)
  
  lapply(1:n, function(i) {
    wellPanel(
      textInput(paste0("nombre_modelo_", i), paste("Nombre del modelo", i), 
                value = paste0("modelo_", i)),
      
      radioButtons(paste0("tipo_modelo_", i), "Tipo de modelo:",
                   choices = c("Modelo de efectos fijos" = "fijo",
                               "Modelo de efectos-mixtos con intercepto aleatorio" = "intercepto",
                               "Modelo de efectos-mixtos con intercepto y pendiente aleatorias" = "pendiente")),
      
      checkboxGroupInput(paste0("vars_modelo_", i), "Variables explicativas:",
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
                         )),
      
      conditionalPanel(
        condition = paste0("input.tipo_modelo_", i, " == 'pendiente'"),
        uiOutput(paste0("pendientes_ui_", i))
      )
      
    )
  })
})

# Acción para comparar modelos
observeEvent(input$comparar_modelos, {
  req(input$n_modelos)
  resultados <- list()
  errores <- c()
  
  for (i in 1:input$n_modelos) {
    nombre <- input[[paste0("nombre_modelo_", i)]]
    tipo <- input[[paste0("tipo_modelo_", i)]]
    vars <- input[[paste0("vars_modelo_", i)]]
    pendiente <- input[[paste0("pendiente_modelo_", i)]]
    
    if (is.null(nombre) || is.null(vars) || length(vars) == 0) {
      errores <- c(errores, paste("Faltan datos para el modelo", i))
      next
    }
    
    y_var <- if (input$tipo_variable_comparar == "binaria") {
      "infeccionBinaria"
    } else {
      "Infeccion_ordinal"
    }
    
    formula_txt <- paste(y_var, "~", paste(vars, collapse = " + "))
    
    if (tipo == "intercepto") {
      formula_txt <- paste0(formula_txt, " + (1 | resident_code)")
    } else if (tipo == "pendiente" && !is.null(pendiente) && length(pendiente) > 0) {
      pendientes_txt <- paste(pendiente, collapse = " + ")
      formula_txt <- paste0(formula_txt, " + (1 + ", pendientes_txt, " | resident_code)")
    }
    
    
    formula_obj <- as.formula(formula_txt)
    
    # Ajustar modelo
    modelo <- tryCatch({
      if (input$tipo_variable_comparar == "binaria") {
        if (tipo == "fijo") {
          glm(formula_obj, data = samples_final, family = binomial)
        } else {
          glmer(formula_obj, data = samples_final, family = binomial)
        }
      } else {
        if (tipo == "fijo") {
          clm(formula_obj, data = samples_final)
        } else {
          clmm(formula_obj, data = samples_final, link = "logit")
        }
      }
    }, error = function(e) e)
    
    if (inherits(modelo, "error")) {
      errores <- c(errores, paste("Modelo", nombre, ":", modelo$message))
    } else {
      # Inicialización de métricas
      accuracy <- NA
      pseudo_r2 <- NA
      n_obs <- tryCatch(nobs(modelo), error = function(e) NA)
      n_param <- tryCatch(length(coef(modelo)), error = function(e) NA)
      r2_marginal <- NA
      r2_condicional <- NA
    
      specificity <- NA
      sensitivity <- NA
      
      
      # Accuracy y pseudo-R² solo para binaria
      if (input$tipo_variable_comparar == "binaria") {
        try({
          preds <- predict(modelo, type = "response")
          pred_class <- ifelse(preds > 0.1, 1, 0)
          real <- samples_final$infeccionBinaria
          tp <- sum(real == 1 & pred_class == 1, na.rm = TRUE)
          tn <- sum(real == 0 & pred_class == 0, na.rm = TRUE)
          fp <- sum(real == 0 & pred_class == 1, na.rm = TRUE)
          fn <- sum(real == 1 & pred_class == 0, na.rm = TRUE)
          
          accuracy <- (tp + tn) / (tp + tn + fp + fn)
          specificity <- tn / (tn + fp)
          sensitivity <- tp / (tp + fn)
          
          
          modelo_nulo <- glm(infeccionBinaria ~ 1, data = samples_final, family = binomial)
          pseudo_r2 <- 1 - as.numeric(logLik(modelo)) / as.numeric(logLik(modelo_nulo))
        }, silent = TRUE)
      }
      
      # R² marginal y condicional (solo para glmer)
      if (inherits(modelo, "merMod")) {
        try({
          r2_vals <- MuMIn::r.squaredGLMM(modelo)
          r2_marginal <- r2_vals[1, "R2m"]
          r2_condicional <- r2_vals[1, "R2c"]
        }, silent = TRUE)
      }
      
      resultados[[nombre]] <- list(
        AIC = round(AIC(modelo), 2),
        BIC = round(BIC(modelo), 2),
        LogLik = round(as.numeric(logLik(modelo)), 2),
        Deviance = ifelse("deviance" %in% names(modelo), round(deviance(modelo), 2), "No disponible"),
        Accuracy = ifelse(!is.na(accuracy), round(accuracy, 5), "No disponible"),
        Specificity = ifelse(!is.na(specificity), round(specificity, 3), "No disponible"),
        Recall = ifelse(!is.na(sensitivity), round(sensitivity, 3), "No disponible")
      )
    }
  }
  
  # Mostrar errores si los hay
  if (length(errores) > 0) {
    output$error_comparar_modelos <- renderText({
      paste(errores, collapse = "\n")
    })
  } else {
    output$error_comparar_modelos <- renderText("")
  }
  
  # Mostrar tabla si hay modelos válidos
  if (length(resultados) > 0) {
    tabla <- do.call(rbind, lapply(names(resultados), function(n) {
      cbind(Modelo = n, as.data.frame(resultados[[n]]))
    }))
    output$tabla_comparacion <- renderTable(tabla, rownames = FALSE)
  }
})


# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_comparar_modelo_eligeopcionpanel, {
  valores$pagina <- "eligeopcionpanel"
})

observe({
  n <- input$n_modelos
  req(n)
  
  for (i in 1:n) {
    local({
      idx <- i
      output[[paste0("pendientes_ui_", idx)]] <- renderUI({
        vars_seleccionadas <- input[[paste0("vars_modelo_", idx)]]
        if (is.null(vars_seleccionadas) || length(vars_seleccionadas) == 0) return(NULL)
        
        # Usar etiquetas amigables
        etiquetas_filtradas <- etiquetas[names(etiquetas) %in% names(etiquetas[etiquetas %in% vars_seleccionadas])]
        
        checkboxGroupInput(
          inputId = paste0("pendiente_modelo_", idx),
          label = "Variables para pendiente aleatoria:",
          choices = setNames(etiquetas_filtradas, names(etiquetas_filtradas))
        )
      })
    })
  }
})








observe({ if (is.null(valores$paso_comparar)) valores$paso_comparar <- 1 })

observeEvent(input$siguiente_comparar, {
  valores$paso_comparar <- valores$paso_comparar + 1
})

observeEvent(input$anterior_comparar, {
  if (valores$paso_comparar > 1) valores$paso_comparar <- valores$paso_comparar - 1
})

observeEvent(input$comparar_modelos, {
  valores$paso_comparar <- 4
})



output$wizard_ui_comparar <- renderUI({
  paso <- valores$paso_comparar
  
  switch(paso,
         "1" = radioButtons("tipo_variable_comparar", "¿Qué variable respuesta quieres comparar en los distintos modelos?",
                            choices = c("Infección Sí / No" = "binaria", "Tipo de Infección" = "ordinal")),
         
         "2" = numericInput("n_modelos", "¿Cuántos modelos quieres comparar?",
                            value = 2, min = 1, max = 4),
         
         "3" = uiOutput("modelo_inputs"),  # Igual que antes, renderizado según n_modelos
         
         "4" = tagList(
           h4("Tabla comparativa de modelos:"),
           div(
             style = "overflow-x: auto; max-width: 100%;",
             tableOutput("tabla_comparacion")
           ),
           verbatimTextOutput("error_comparar_modelos"),
           br(),
           actionButton("resetear_comparar", "Comparar otros modelos", class = "btn btn-link")
         )
  )
})

observeEvent(input$resetear_comparar, {
  valores$paso_comparar <- 1
  output$tabla_comparacion <- renderTable(NULL)
  output$error_comparar_modelos <- renderText("")
})


output$mostrarAnterior_comparar <- reactive({
  valores$paso_comparar > 1 && valores$paso_comparar <= 3
})
outputOptions(output, "mostrarAnterior_comparar", suspendWhenHidden = FALSE)

output$mostrarSiguiente_comparar <- reactive({
  valores$paso_comparar %in% c(1, 2)
})
outputOptions(output, "mostrarSiguiente_comparar", suspendWhenHidden = FALSE)

output$mostrarComparar <- reactive({
  valores$paso_comparar == 3
})
outputOptions(output, "mostrarComparar", suspendWhenHidden = FALSE)

