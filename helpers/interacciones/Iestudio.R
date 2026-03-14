# Iestudio.R: gestiona la navegación desde la página del informe de estudio,
# permitiendo volver al menú de resultados de la aplicación.

observeEvent(input$volver_estudio_resultados, {
  valores$pagina <- "resultados"
})
