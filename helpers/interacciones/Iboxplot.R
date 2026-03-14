# Iboxplot.R: contiene la lógica que genera el boxplot interactivo de la variable seleccionada.
# El gráfico muestra la distribución de cada variable fisiológica según el estado de infección,
# permitiendo identificar posibles valores atípicos. También gestiona el botón de navegación
# para volver al menú de detección de outliers dentro de la aplicación.

nombre_bonito <- c(
  "body_temp"   = "Temperatura Corporal (°C)",
  "SPO2.Min"    = "Saturación de Oxígeno Mínima (%)",
  "BPM.Avg"     = "Frecuencia Cardíaca Promedio (lat/min)",
  "EDA.Avg"     = "Actividad Electrodérmica Promedio (μS)",
  "tmed"        = "Temperatura Ambiente Promedio (°C)",
  "sol"         = "Radiación Solar (MJ/m²)",
  "presMean"    = "Presión Atmosférica Media (hPa)"
)


output$plot_var <- renderPlotly({
  df_filtrado <- df_long %>%
    filter(variable == input$var_sel)
  
  nombre_bonito_var <- nombre_bonito[[input$var_sel]]
  
  p <- ggplot(df_filtrado, aes(x = as.factor(Infeccion), y = valor, fill = as.factor(Infeccion))) +
    geom_boxplot(outlier.color = "red", alpha = 0.7) +
    labs(
      title = paste("Distribución de", nombre_bonito_var, "por estado de infección"),
      x = "Infección", y = "Valor", fill = "Infección"
    ) +
    theme_minimal()
  
  ggplotly(p)
})



# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_boxplot_outlier, {
  valores$pagina <- "outlier"
})
