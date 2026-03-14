# Igrafmov.R: gestiona la navegación desde la selección de variables fisiológicas
# hacia el gráfico de evolución temporal, y permite volver al menú de análisis temporal.

## PÁGINA GRAFMOV
# Cuando das al boton siguiente te vas a gráfico
observeEvent(input$next_button, {
  valores$pagina <- "grafico"
})

# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_grafmov_eligetiempo, {
  valores$pagina <- "eligetiempo"
})
