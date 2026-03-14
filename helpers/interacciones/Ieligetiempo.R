# Ieligetiempo.R: controla la navegación dentro de la sección de análisis temporal,
# permitiendo acceder a la visualización de variables fisiológicas, diagnósticos
# de infección o al calendario de infecciones, y gestionando el retorno al menú
# principal de análisis.

## PAGINA ELIGE MOVIMIENTO

observeEvent(input$var_tiempo, {
  valores$pagina <- "grafmov"
})

observeEvent(input$diag_tiempo, {
  valores$pagina <- "grafmov2"
})

observeEvent(input$calendario_1, {
  valores$pagina <- "calendario_1"
})



# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_elige_movimiento, {
  valores$pagina <- "movimiento"
})
