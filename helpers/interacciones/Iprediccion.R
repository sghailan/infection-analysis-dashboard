# Iprediccion.R: desarrolla la lógica de la sección de predicción de la app.
# Permite construir paso a paso un modelo binario, seleccionar las variables
# explicativas, definir si el ajuste incluye efectos fijos o mixtos y generar
# una predicción a partir de los valores introducidos por el usuario. Además,
# gestiona el asistente de navegación entre pasos, muestra información de apoyo
# sobre las variables utilizadas y permite reiniciar el proceso para realizar
# nuevas predicciones dentro de la aplicación.

etiquetas_variables <- c(
  age = "Edad",
  sex = "Sexo",
  body_temp = "Temperatura Corporal (°C)",
  SPO2.Min = "Saturación de Oxígeno Mínima (%)",
  BPM.Avg = "Frecuencia Cardíaca Promedio (lat/min)",
  EDA.Avg = "Actividad Electrodérmica Promedio (μS)",
  tmed = "Temperatura Ambiente Promedio (°C)",
  sol = "Radiación Solar (MJ/m²)",
  presMean_scaled = "Presión Atmosférica Media (hPa)"
)


# REACTIVOS Y ESTADO
modelos_prediccion <- reactiveValues(unico = NULL)

# UI dinámica paso a paso sin almacenamiento múltiple

output$pendientes_dinamicos <- renderUI({
  req(input$vars_modelo_prediccion)
  
  choices_bonitos <- setNames(input$vars_modelo_prediccion,
                              etiquetas_variables[input$vars_modelo_prediccion] %||% input$vars_modelo_prediccion)
  
  checkboxGroupInput("pendientes_modelo_prediccion",
                     "¿Qué variables deseas como pendientes aleatorias?",
                     choices = choices_bonitos)
})


# Predicción directa
observeEvent(input$realizar_prediccion, {
  req(modelos_prediccion$unico)
  modelo_obj <- modelos_prediccion$unico$objeto
  nombre_modelo <- modelos_prediccion$unico$nombre
  
  vars_usadas <- all.vars(formula(modelo_obj))[-1]
  vars_usadas <- setdiff(vars_usadas, "resident_code")
  
  valores_input <- lapply(vars_usadas, function(var) input[[paste0("input_pred_", var)]])
  
  if (any(sapply(valores_input, is.null))) {
    output$resultado_prediccion_ui <- renderUI(tags$p("Faltan valores para realizar la predicción."))
    return()
  }
  
  newdata <- as.data.frame(setNames(valores_input, vars_usadas))
  
  if ("sex" %in% colnames(newdata)) {
    newdata$sex <- factor(newdata$sex, levels = levels(samples_final$sex))
  }
  if ("resident_code" %in% all.vars(formula(modelo_obj))) {
    newdata$resident_code <- samples_final$resident_code[1]  # usar un nivel ya existente
  }
  
  resultado <- tryCatch({
    prob <- predict(modelo_obj, newdata = newdata, type = "response", allow.new.levels = TRUE)
    paste0("Según el modelo ", nombre_modelo, ", un individuo con esas características tiene una probabilidad del ",
           formatC(prob * 100, digits = 2, format = "f"), "% de estar infectado.")
  }, error = function(e) {
    paste("Error en la predicción: ", e$message)
  })
  
  output$resultado_prediccion_ui <- renderUI({
    h4(resultado)
  })
  valores$paso_prediccion <- 4  # ⬅️ ESTA ES LA CLAVE
})

observeEvent(input$volver_prediccion_eligeopcionpanel, {
  valores$pagina <- "eligeopcionpanel"
})


output$wizard_ui_prediccion <- renderUI({
  paso <- valores$paso_prediccion
  
  switch(paso,
         "1" = tagList(
           textInput("nombre_modelo_prediccion", "¿Cómo deseas llamar a este modelo?", value = "modelo_1"),
           radioButtons("tipo_modelo_prediccion", "¿Qué tipo de modelo deseas ajustar?",
                        choices = c("Modelo logístico sin efectos individuales" = "fijo",
                                    "Modelo mixto con intercepto aleatorio" = "intercepto",
                                    "Modelo mixto con intercepto y pendientes aleatorias" = "pendiente"))
      ),
         "2" = tagList(
           checkboxGroupInput("vars_modelo_prediccion", "¿Qué variables explicativas deseas incluir?",
                              choices = c(
                                "Edad" = "age",
                                "Sexo" = "sex",
                                "Temperatura Corporal (°C)" = "body_temp",
                                "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
                                "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
                                "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
                                "Temperatura Ambiente Promedio (°C)" = "tmed",
                                "Radiación Solar (MJ/m²)" = "sol",
                                "Presión Atmosférica Media (hPa)" = "presMean_scaled")),
           conditionalPanel(
             condition = "input.tipo_modelo_prediccion == 'pendiente'",
             uiOutput("pendientes_dinamicos")
           )
         ),
      "3" = {
        req(modelos_prediccion$unico)
        
        modelo <- modelos_prediccion$unico$objeto
        vars_usadas <- all.vars(formula(modelo))[-1]
        vars_usadas <- setdiff(vars_usadas, "resident_code")
        
        tagList(
          h4("Introduce los valores para las variables explicativas:"),
          lapply(vars_usadas, function(var) {
            resumen <- summary(samples_final[[var]])
            resumen_texto <- paste0("Min: ", round(resumen["Min."], 2),
                                    " | Media: ", round(resumen["Mean"], 2),
                                    " | Máx: ", round(resumen["Max."], 2))
            id_boton <- paste0("mostrar_summary_", var)
            id_texto <- paste0("summary_text_", var)
            
            if (var == "sex") {
              fluidRow(
                column(12,
                       selectInput(paste0("input_pred_", var),
                                   etiquetas_variables[[var]] %||% var,
                                   choices = levels(samples_final$sex))
                )
              )
            } else {
              fluidRow(
                column(10,
                       numericInput(paste0("input_pred_", var),
                                    label = etiquetas_variables[[var]] %||% var,
                                    value = round(resumen["Mean"], 2))
                ),
                column(2,
actionButton(id_boton, label = NULL,
             icon = icon("question-circle"),
             style = "border: none; background-color: transparent; font-size: 22px; color: #007bff;")
                ),
                column(12,
                       hidden(
                         div(id = id_texto,
                             style = "margin-top: 10px; background-color: #f5f5f5; border: 1px solid #ccc; border-radius: 6px; padding: 8px; color: #333;",
                             resumen_texto
                         )
                       )
                )
              )
            }
          })
        )
      },
      "4" = uiOutput("resultado_prediccion_ui")
  )
})

observe({
  req(modelos_prediccion$unico)
  modelo <- modelos_prediccion$unico$objeto
  vars <- all.vars(formula(modelo))[-1]
  vars <- setdiff(vars, "resident_code")
  
  lapply(vars, function(var) {
    if (var != "sex") {
      local({
        v <- var
        observeEvent(input[[paste0("mostrar_summary_", v)]], {
          shinyjs::toggle(id = paste0("summary_text_", v))
        }, ignoreInit = TRUE)
      })
    }
  })
})


observeEvent(input$siguiente_prediccion, {
  if (valores$paso_prediccion == 2) {
    req(input$nombre_modelo_prediccion, input$vars_modelo_prediccion)
    
    tipo <- input$tipo_modelo_prediccion
    nombre <- input$nombre_modelo_prediccion
    vars <- input$vars_modelo_prediccion
    pendientes <- input$pendientes_modelo_prediccion
    
    if (length(vars) == 0) {
      showModal(modalDialog("Debes seleccionar al menos una variable explicativa."))
      return()
    }
    
    fixed <- paste("infeccionBinaria ~", paste(vars, collapse = " + "))
    random <- ""
    
    if (tipo == "intercepto") {
      random <- "+ (1 | resident_code)"
    } else if (tipo == "pendiente" && length(pendientes) > 0) {
      random <- paste0(" + (1 + ", paste(pendientes, collapse = " + "), " | resident_code)")
    }
    
    formula_txt <- paste0(fixed, random)
    formula_obj <- as.formula(formula_txt)
    
    modelo <- tryCatch({
      if (tipo == "fijo") {
        glm(formula_obj, data = samples_final, family = binomial)
      } else {
        glmer(formula_obj, data = samples_final, family = binomial,
              control = glmerControl(optimizer = "bobyqa"))
      }
    }, error = function(e) e)
    
    if (inherits(modelo, "error")) {
      showModal(modalDialog(title = "Error al ajustar el modelo", modelo$message))
      return()
    }
    
    modelos_prediccion$unico <- list(objeto = modelo, nombre = nombre)
  }
  
  valores$paso_prediccion <- valores$paso_prediccion + 1
})



observe({
  if (is.null(valores$paso_prediccion)) valores$paso_prediccion <- 1
})

observeEvent(input$resetear_prediccion, {
  valores$paso_prediccion <- 1
  modelos_prediccion$unico <- NULL
})


output$mostrarAnterior_prediccion <- reactive({
  valores$paso_prediccion > 1 && valores$paso_prediccion < 4
})
outputOptions(output, "mostrarAnterior_prediccion", suspendWhenHidden = FALSE)

output$mostrarSiguiente_prediccion <- reactive({
  valores$paso_prediccion %in% c(1, 2)
})
outputOptions(output, "mostrarSiguiente_prediccion", suspendWhenHidden = FALSE)

output$mostrarPredecir <- reactive({
  valores$paso_prediccion == 3
})
outputOptions(output, "mostrarPredecir", suspendWhenHidden = FALSE)

output$mostrarResetear_prediccion <- reactive({
  valores$paso_prediccion == 4
})
outputOptions(output, "mostrarResetear_prediccion", suspendWhenHidden = FALSE)



observeEvent(input$anterior_prediccion, {
  if (valores$paso_prediccion > 1) {
    valores$paso_prediccion <- valores$paso_prediccion - 1
  }
})



