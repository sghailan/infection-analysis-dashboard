# Idensidad.R: implementa la lógica del análisis de densidad por grupos.
# Genera el gráfico de distribución para la variable seleccionada, permite agrupar
# por características como sexo, residencia o grupo de edad, y calcula un test de
# Wilcoxon para evaluar diferencias entre los grupos. También gestiona la navegación
# de vuelta al menú de análisis.

nombre_bonito <- c(
  "body_temp"   = "Temperatura Corporal (°C)",
  "SPO2.Min"    = "Saturación de Oxígeno Mínima (%)",
  "BPM.Avg"     = "Frecuencia Cardíaca Promedio (lat/min)",
  "EDA.Avg"     = "Actividad Electrodérmica Promedio (μS)",
  "tmed"        = "Temperatura Ambiente Promedio (°C)",
  "sol"         = "Radiación Solar (MJ/m²)",
  "presMean"    = "Presión Atmosférica Media (hPa)"
)


selected_var <- reactive({ input$variable })
selected_group <- reactive({ input$grouping })
  
output$densityPlot <- renderPlot({
  var <- selected_var()
  group <- selected_group()
  
  nombre_bonito_var <- nombre_bonito[[var]]
  nombre_grupo_bonito <- c(
    "sex" = "Sexo",
    "Institution" = "Residencia",
    "grupo_edad" = "Edad"
  )
  legend_title <- nombre_grupo_bonito[[group]]
  
  p <- ggplot(samples_base, aes_string(x = var, fill = group)) +
    geom_density(alpha = 0.5, na.rm = TRUE) +
    labs(
      title = paste("Distribución de", nombre_bonito_var, "por", legend_title),
      x = nombre_bonito_var,
      y = "Densidad"
    ) +
    theme_minimal()
  
  # Añadir leyenda según el grupo
  if (group == "sex") {
    p <- p + scale_fill_manual(values = c("#e41a1c", "#377eb8"), name = legend_title)
  } else {
    p <- p + scale_fill_brewer(palette = "Set2", name = legend_title)
  }
  
  p
})

  observeEvent(input$test_button, {
    var <- selected_var()
    group <- selected_group()
    
    
    datos <- samples_base %>%
      filter(!is.na(.data[[var]]), !is.na(.data[[group]])) %>%
      dplyr::select(grupo = all_of(group), valor = all_of(var))
    
    if (length(unique(datos$grupo)) < 2) {
      output$testResult <- renderPrint({
        cat(" Solo hay un grupo presente. No se puede realizar el test.")
      })
      return()
    }
    
    test <- wilcox.test(valor ~ grupo, data = datos)
    
    medias <- datos %>%
      group_by(grupo) %>%
      summarise(media = round(mean(valor, na.rm = TRUE), 2), .groups = "drop")
    
    p_value <- signif(test$p.value, 4)
    
    output$testResult <- renderPrint({
      cat(" Test de Wilcoxon para:", nombre_bonito[[var]], "\n\n")
      for (i in 1:nrow(medias)) {
        cat("Media del grupo", as.character(medias$grupo[i]), ": ", medias$media[i], "\n")
      }
      cat("\nValor-p:", p_value, "\n")
    })
  })
  
  
  # Evento para volver a la plataforma (inicio)
  observeEvent(input$volver_densidad_movimiento, {
    valores$pagina <- "movimiento"
  })

