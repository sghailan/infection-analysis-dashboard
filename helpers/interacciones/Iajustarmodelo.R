# Iajustarmodelo.R: gestiona la navegación desde la selección del tipo de modelo hacia sus páginas correspondientes y el regreso al panel de opciones

observeEvent(input$variable_binaria, {
  valores$pagina <- "variable_binaria"
})
observeEvent(input$variable_ordinal, {
  valores$pagina <- "variable_ordinal"
})
observeEvent(input$variable_multinomial, {
  valores$pagina <- "variable_multinomial"
})


# Evento a opciones de analisis exploratorio 
observeEvent(input$volver_ajustar_modelo_eligeopcionpanel, {
  valores$pagina <- "eligeopcionpanel"
})