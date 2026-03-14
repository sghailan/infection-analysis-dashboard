# Imovimiento.R: gestiona la navegación dentro de la sección de análisis exploratorio.
# Permite acceder a distintas herramientas analíticas como visualización temporal de
# infecciones, grafos de transiciones, detección de outliers, análisis de distribuciones,
# gráficos exploratorios y tablas cruzadas. También controla el retorno a las páginas
# principales de la aplicación.


observeEvent(input$grafmov_button, {
  valores$pagina <- "eligetiempo"
})


observeEvent(input$discri_button, {
  valores$pagina <- "discri"
})

observeEvent(input$grafos_button, {
  valores$pagina <- "grafos"
})


# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$outlier_button, {
  valores$pagina <- "outlier"
})


# Evento para cambiar a la interfaz de evolución de pacientes
observeEvent(input$densidad_button, {
  valores$pagina <- "densidad"
})


# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_movimiento_inicio, {
  valores$pagina <- "inicio"
})

observeEvent(input$interactivos, {
  valores$pagina <- "interactivos"
})

observeEvent(input$tabla_cruzada, {
  valores$pagina <- "tabla_cruzada"
})
# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_movimiento_inicio, {
  valores$pagina <- "resultados"
})
