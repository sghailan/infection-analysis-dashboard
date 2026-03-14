# Iresultados.R: controla la navegación dentro de la sección de resultados
# del estudio. Permite acceder a los resultados principales obtenidos a
# partir del análisis exploratorio y al documento de análisis detallado,
# así como regresar a la página principal de la aplicación.

observeEvent(input$resultadosimportantes, {
  valores$pagina <- "movimiento"
})

 observeEvent(input$estudio, {
  valores$pagina <- "estudio"
 })


observeEvent(input$volver_resultados_inicio, {
  valores$pagina <- "inicio"
})