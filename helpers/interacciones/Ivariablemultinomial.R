# Ivariablemultinomial.R: contiene la estructura prevista para la implementación
# de modelos multinomiales dentro de la aplicación. Incluye el diseño para
# seleccionar variables explicativas, definir posibles efectos aleatorios y
# ajustar modelos tanto de efectos fijos como mixtos. Actualmente la mayor parte
# del código se mantiene comentada como desarrollo futuro, mientras que el
# script gestiona la navegación de regreso al panel de ajuste de modelos.

# # REACTIVO PARA MODELO MULTINOMIAL
# output$pendiente_selector_multinomial <- renderUI({
#   if (input$modelo_tipo_multinomial == "pendiente") {
#     checkboxGroupInput("slope_multinomial", "Selecciona variables para pendientes aleatorias:",
#                        choices = input$vars_multinomial)
#   }
# })
# 
# observeEvent(input$ajustar_modelo_multinomial, {
#   req(input$vars_multinomial)
#   
#   # Asegurar que la variable de respuesta es factor
#   samples_final$Infeccion <- factor(samples_final$Infeccion)
#   
#   fixed <- paste(input$vars_multinomial, collapse = " + ")
#   formula_text <- paste("Infeccion ~", fixed)
#   
#   if (input$modelo_tipo_multinomial == "intercepto") {
#     formula_text <- paste0(formula_text, " + (1 | resident_code)")
#   } else if (input$modelo_tipo_multinomial == "pendiente" && length(input$slope_multinomial) > 0) {
#     random_slopes <- paste(input$slope_multinomial, collapse = " + ")
#     formula_text <- paste0(formula_text, " + (1 + ", random_slopes, " | resident_code)")
#   }
#   
#   formula_obj <- as.formula(formula_text)
#   
#   # Mostrar fórmula construida
#   output$formula_multinomial <- renderText({
#     paste("Fórmula del modelo:", formula_text)
#   })
#   
#   # Ajustar el modelo
#   tryCatch({
#     
#     if (input$modelo_tipo_multinomial == "fijo") {
#       
#       modelo <- nnet::multinom(formula_obj, data = samples_final, trace = FALSE)
#       
#       output$resumen_multinomial <- renderPrint({
#         summary(modelo)
#       })
#       
#       output$metricas_multinomial <- renderPrint({
#         cat("AIC:", AIC(modelo), "\n")
#         cat("BIC:", BIC(modelo), "\n")
#         cat("Log-Likelihood:", logLik(modelo), "\n")
#       })
#       
#     } else {
#       
#       # Asegurar que resident_code es factor
#       if (!"resident_code" %in% names(samples_final)) {
#         stop("La variable resident_code no está presente en los datos.")
#       }
#       samples_final$resident_code <- factor(samples_final$resident_code)
#       
#       modelo <- brms::brm(
#         formula = formula_obj,
#         data = samples_final,
#         family = categorical(link = "logit"),
#         chains = 2, iter = 2000, warmup = 500,
#         refresh = 0,
#         backend = "cmdstanr"
#       )
#       
#       output$resumen_multinomial <- renderPrint({
#         summary(modelo)
#       })
#       
#       output$metricas_multinomial <- renderPrint({
#         cat("WAIC:", tryCatch(waic(modelo)$estimates["waic", "Estimate"], error = function(e) NA), "\n")
#         cat("LOO:", tryCatch(loo(modelo)$estimates["looic", "Estimate"], error = function(e) NA), "\n")
#         cat("Log-Likelihood:", logLik(modelo), "\n")
#       })
#     }
#     
#     output$error_multinomial <- renderText({ "" })
#     
#   }, error = function(e) {
#     output$resumen_multinomial <- renderPrint({ NULL })
#     output$metricas_multinomial <- renderText({ "" })
#     output$error_multinomial <- renderText({
#       paste("Error al ajustar el modelo:", e$message)
#     })
#   })
# })



# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_variablemultinomial_ajustarmodelo, {
  valores$pagina <- "ajustar_modelo"
})
