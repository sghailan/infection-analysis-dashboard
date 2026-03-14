# Iinicio.R: gestiona la navegación desde la página principal de la aplicación,
# permitiendo acceder a las secciones de información de pacientes, análisis
# exploratorio, explicación de la interpolación y al panel de modelos.

# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$evolucion_button, {
  valores$pagina <- "info"
})

# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$EDA_button, {
  valores$pagina <- "resultados"
})

# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$interpolacion, {
  valores$pagina <- "interpolacion"
})

# 
# # Evento para cambiar a la interfaz de evolución de pacientes
# observeEvent(input$Clustering_button, {
#   valores$pagina <- ""
# })
# 
# 

# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$panel_button, {
  valores$pagina <- "eligeopcionpanel"
})
