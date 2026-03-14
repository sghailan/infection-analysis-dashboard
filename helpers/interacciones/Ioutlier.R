# Ioutlier.R: controla la navegación dentro de la sección de detección de outliers.
# Permite acceder al análisis mediante boxplots para identificar valores atípicos
# en las variables del estudio y gestionar el regreso a la sección principal de
# análisis exploratorio. Incluye también la estructura preparada para futuros
# métodos de detección basados en modelos.


observeEvent(input$boxplot_button, {
  valores$pagina <- "boxplot"
})


#observeEvent(input$modelo_outlier_button, {
#  valores$pagina <- "modelo_outlier"
#})



# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_outlier_movimiento, {
  valores$pagina <- "movimiento"
})
