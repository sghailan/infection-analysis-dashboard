# Igrafos.R: desarrolla la lógica de la sección de grafos de la aplicación.
# A partir de las transiciones entre tipos de infección, genera una red que puede
# visualizarse tanto a nivel global como para un paciente concreto, mostrando el
# número de transiciones, su orden temporal o los días transcurridos entre ellas.
# Además, calcula distintas métricas de red —como entropía, centralidad de entrada
# y salida, betweenness o closeness— para facilitar la interpretación del patrón
# de infecciones, y gestiona el retorno al menú principal de análisis.

estado_comandos <- reactiveValues(
  show_rapida = FALSE,
  show_media = FALSE,
  show_lenta=FALSE,
  show_in = FALSE,
  show_out = FALSE,
  show_bt = FALSE,
  show_closeness=FALSE,
  show_entropia = FALSE
)
observe({
  req(input$paciente)
  if (input$paciente == "Global") {
    shinyjs::disable("orden")
  } else {
    shinyjs::enable("orden")
  }
})



output$grafo <- renderPlot({
  if(input$orden == "Número de veces de las transiciones"){
    if (input$paciente == "Global") {
      datos <- tabla_transiciones %>%
        filter(!is.na(from)) %>%
        count(from, to, name = "peso")
      titulo <- "Grafo de transiciones entre infecciones (Global)"
    } else {
      datos <- tabla_transiciones %>%
        filter(resident_code == input$paciente, !is.na(from)) %>%
        count(from, to, name = "peso")
      titulo <- paste("Grafo de transiciones - Paciente", input$paciente)
    }
    
    if (nrow(datos) == 0) {
      plot.new()
      title(main = "No hay transiciones para este paciente.")
      return(NULL)
    }
    
    g <- graph_from_data_frame(datos, directed = TRUE)
    layout <- layout_in_circle(g)
    
    E(g)$curved <- 0
    mutuas <- which_mutual(g)
    E(g)$curved[mutuas] <- 0.3
    
    plot(
      g,
      layout = layout,
      edge.arrow.size = 0.4,
      edge.width = 1.5,
      edge.curved = E(g)$curved,
      edge.label = E(g)$peso,
      edge.label.cex = 1,
      edge.label.color = "black",
      edge.color = "steelblue",
      vertex.size = 35,
      vertex.color = "gray30",
      vertex.label.color = "white",
      vertex.label.cex = 1.2,
      main = titulo
    )
  }
  
  
  if (input$paciente != "Global" && input$orden == "Orden de transiciones") {
    req(input$paciente)
    
    # Transiciones individuales + orden temporal
    datos <- tabla_transiciones %>%
      filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
      arrange(date_diagnosis) %>%
      mutate(paso = paste0("Nº ", row_number())) %>%
      group_by(from, to) %>%
      summarise(etiqueta = paste(paso, collapse = ", "), .groups = "drop")
    
    if (nrow(datos) == 0) {
      plot.new()
      title(main = "No hay transiciones para este paciente")
      return(NULL)
    }
    
    # Crear grafo
    g <- graph_from_data_frame(datos, directed = TRUE)
    etiquetas <- datos$etiqueta
    titulo <- paste("Grafo de transiciones - Paciente", input$paciente)
    
    layout <- layout_in_circle(g)
    E(g)$curved <- 0
    mutuas <- which_mutual(g)
    E(g)$curved[mutuas] <- 0.3
    
    plot(
      g,
      layout = layout,
      edge.arrow.size = 0.4,
      edge.width = 1.5,
      edge.curved = E(g)$curved,
      edge.label = etiquetas,
      edge.label.cex = 1,
      edge.label.color = "black",
      edge.color = "steelblue",
      vertex.size = 35,
      vertex.color = "gray30",
      vertex.label.color = "white",
      vertex.label.cex = 1.2,
      main = titulo
    )
  } 
  else if (input$paciente != "Global" && input$orden == "Días transcurridos en cada transición") {
    req(input$paciente)
    
    datos <- tabla_transiciones %>%
      filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
      arrange(date_diagnosis) %>%
      mutate(lapse = as.numeric(lapse)) %>%
      group_by(from, to) %>%
      summarise(etiqueta = paste0(lapse, collapse = ", "), .groups = "drop")
    
    if (nrow(datos) == 0) {
      plot.new()
      title(main = "No hay transiciones para este paciente.")
      return(NULL)
    }
    
    g <- graph_from_data_frame(datos, directed = TRUE)
    etiquetas <- datos$etiqueta
    titulo <- paste("Grafo de transiciones - Paciente", input$paciente)
    
    layout <- layout_in_circle(g)
    E(g)$curved <- 0
    mutuas <- which_mutual(g)
    E(g)$curved[mutuas] <- 0.3
    
    plot(
      g,
      layout = layout,
      edge.arrow.size = 0.4,
      edge.width = 1.5,
      edge.curved = E(g)$curved,
      edge.label = etiquetas,
      edge.label.cex = 1,
      edge.label.color = "black",
      edge.color = "steelblue",
      vertex.size = 35,
      vertex.color = "gray30",
      vertex.label.color = "white",
      vertex.label.cex = 1.2,
      main = titulo
    )
  }
  
  
  
  
})





observeEvent(input$btn_rapida, {
  estado_comandos$show_rapida <- !estado_comandos$show_rapida
})

observeEvent(input$btn_lenta, {
  estado_comandos$show_lenta <- !estado_comandos$show_lenta
})

observeEvent(input$btn_media, {
  estado_comandos$show_media <- !estado_comandos$show_media
})
observeEvent(input$btn_in, {
  estado_comandos$show_in <- !estado_comandos$show_in
})

observeEvent(input$btn_out, {
  estado_comandos$show_out <- !estado_comandos$show_out
})

observeEvent(input$btn_bt, {
  estado_comandos$show_bt <- !estado_comandos$show_bt
})

observeEvent(input$btn_closeness, {
  estado_comandos$show_closeness <- !estado_comandos$show_closeness
})
observeEvent(input$btn_entropia, {
  estado_comandos$show_entropia <- !estado_comandos$show_entropia
})



output$info_entropia <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_entropia)
  
  datos <- tabla_transiciones %>%
    filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
    count(from, to)
  
  if (nrow(datos) == 0) {
    return("No hay transiciones para este paciente.")
  }
  
  total <- sum(datos$n)
  probs <- datos$n / total
  entropia <- -sum(probs * log2(probs))
  
  cat(round(entropia, 3), "\n\n")
  
  #if (entropia < 1) {
   # cat(" El patrón de transiciones es muy repetitivo y predecible.")
  #} else if (entropia >= 1 && entropia < 2) {
    #cat(" El paciente tiene un patrón moderadamente diverso de transiciones.")
  #} else {
    #cat(" El patrón de transiciones es muy diverso y clínicamente complejo.")
  #}
  
})

output$info_closeness <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_closeness)
  
  datos <- tabla_transiciones %>%
    filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
    dplyr::select(from, to, lapse)
  
  if (nrow(datos) == 0) {
    return("No se disponen de datos suficientes para abordar el problema")
  }
  
  g <- graph_from_data_frame(datos, directed = TRUE)
  E(g)$weight <- datos$lapse
  
  # Calculamos closeness y controlamos posibles errores
  clos <- tryCatch({
    closeness(g, mode = "out", weights = E(g)$weight, normalized = TRUE)
  }, error = function(e) {
    return(rep(NA, length(V(g))))
  })
  
  # Si todos son NA o NaN → no se puede calcular closeness
  if (all(is.na(clos)) || all(is.nan(clos))) {
    return("️ No se puede calcular closeness porque no hay caminos válidos entre todos los nodos del grafo.")
  }
  
  top <- names(clos)[which.max(clos)]
  val <- round(max(clos, na.rm = TRUE), 4)
  
  cat( top, "(valor =", val, ")")
})




output$info_in <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_in)
  
  datos <- tabla_transiciones %>% 
    filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
    count(from, to, name = "peso")
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  g <- graph_from_data_frame(datos, directed = TRUE)
  grados <- degree(g, mode = "in")
  top <- names(which.max(grados))
  
  cat( top, "(", grados[top], "entradas )")
})

output$info_out <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_out)
  
  datos <- tabla_transiciones %>% 
    filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
    count(from, to, name = "peso")
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  g <- graph_from_data_frame(datos, directed = TRUE)
  grados <- degree(g, mode = "out")
  top <- names(which.max(grados))
  
  cat( top, "(", grados[top], "salidas )")
})

output$info_bt <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_bt)
  
  datos <- tabla_transiciones %>% 
    filter(resident_code == as.numeric(input$paciente), !is.na(from)) %>%
    count(from, to, name = "peso")
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  g <- graph_from_data_frame(datos, directed = TRUE)
  bt <- betweenness(g)
  
  if (all(bt == 0)) {
    cat("Ninguna infección")
  } else {
    top <- names(which.max(bt))
    cat(top, "\nValor:", round(bt[top], 2))
  }
})


output$info_rapida <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_rapida)
  
  datos <- tabla_transiciones %>%
    filter(resident_code == as.numeric(input$paciente), !is.na(lapse), !is.na(from)) %>%
    arrange(date_diagnosis)
  
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  
  trans <- datos %>% filter(lapse == min(lapse)) %>% dplyr::slice(1)
  cat(paste0("   ", trans$from, " → ", trans$to, " (En ", trans$lapse, " días)"))
})


output$info_lenta <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_lenta)
  
  datos <- tabla_transiciones %>%
    filter(resident_code == as.numeric(input$paciente), !is.na(lapse), !is.na(from)) %>%
    arrange(date_diagnosis)
  
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  
  trans <- datos %>% filter(lapse == max(lapse)) %>% dplyr::slice(1)
  cat(paste0("   ", trans$from, " → ", trans$to, " (En ", trans$lapse, " días)"))
})


output$info_media <- renderPrint({
  req(input$paciente != "Global")
  req(estado_comandos$show_media)
  
  datos <- tabla_transiciones %>%
    filter(resident_code == as.numeric(input$paciente), !is.na(lapse), !is.na(from))
  
  if (nrow(datos) == 0) return("No se disponen de datos suficientes para abordar el problema")
  
  media_lapse <- round(mean(datos$lapse), 2)
  cat(paste0("   ", media_lapse, " días"))
})




# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_grafos_movimiento, {
  valores$pagina <- "movimiento"
})




