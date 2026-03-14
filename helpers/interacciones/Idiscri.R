# Idiscri.R: gestiona las interacciones de la sección de análisis discriminante,
# mostrando mensajes informativos según la categoría de infección seleccionada
# y controlando la navegación de vuelta al menú de análisis.

## PAGINA DISCRI(CREAR NUEVAS PAGINAS PROX)

observeEvent(input$no_infectados, {
  showModal(modalDialog("Mostrando pacientes NO INFECTADOS"))
})

observeEvent(input$infeccion_1, {
  showModal(modalDialog("Mostrando pacientes con INFECCIÓN 1"))
})

observeEvent(input$infeccion_2, {
  showModal(modalDialog("Mostrando pacientes con INFECCIÓN 2"))
})

observeEvent(input$infeccion_3, {
  showModal(modalDialog("Mostrando pacientes con INFECCIÓN 3"))
})



# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_discri_movimiento, {
  valores$pagina <- "movimiento"
})