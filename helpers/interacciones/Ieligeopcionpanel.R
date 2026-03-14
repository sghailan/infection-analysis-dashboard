# Ieligeopcionpanel.R: gestiona la navegación desde el panel de opciones de modelos,
# permitiendo acceder a las secciones de ajuste de modelos, comparación de modelos
# y predicción. También controla el botón de regreso a la página principal de la app.

observeEvent(input$ajustar_modelo, {
  valores$pagina <- "ajustar_modelo"
})

observeEvent(input$comparar_modelo, {
  valores$pagina <- "comparar_modelo"
})

observeEvent(input$prediccion, {
  valores$pagina <- "prediccion"
})
# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_eligeopcionpanel_inicio, {
  valores$pagina <- "inicio"
})
