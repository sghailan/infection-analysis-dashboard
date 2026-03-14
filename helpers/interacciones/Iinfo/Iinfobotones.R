# Iinfobotones.R: reúne la lógica asociada a los botones y elementos interactivos
# de la página de información del paciente. Gestiona la apertura de ventanas modales
# con descripciones clínicas y datos contextuales, controla la navegación hacia otras
# secciones de la app y desarrolla el funcionamiento del asistente lateral, incluyendo
# la generación de resúmenes del paciente, la consulta de muestras por fecha y la
# explicación de los distintos tipos de infección registrados en el estudio.

# BOTONES PAGINA INFO

# Eventos para mostrar las descripciones de las infecciones
observeEvent(input$sti_button, {
  showModal(modalDialog(title = "Descripción de STI", "STI (Skin and Soft Tissue Infection) → Muy común en pacientes con heridas, úlceras o infecciones dérmicas.
", easyClose = TRUE,
                        footer = modalButton("Cerrar") ))
})

observeEvent(input$ari_button, {
  showModal(modalDialog(title = "Descripción de ARI", "ARI (Acute Respiratory Infection) → Se usa ampliamente para infecciones respiratorias como neumonía o bronquitis.", easyClose = TRUE,
                        footer = modalButton("Cerrar") ))
})

observeEvent(input$uti_button, {
  showModal(modalDialog(title = "Descripción de UTI", "UTI (Urinary Tract Infection) → Muy típica en pacientes hospitalizados o con problemas urinarios.", easyClose = TRUE,
                        footer = modalButton("Cerrar") ))
})




# Botón dentro del modal para mostrar qué significa el Índice de Barthel
observeEvent(input$barthel_info, {
  showModal(modalDialog(
    title = "¿Qué es el Índice de Barthel?",
    "El Índice de Barthel mide la autonomía en actividades diarias básicas, como alimentación, baño y movilidad.",
    easyClose = TRUE,
    footer = modalButton("Cerrar") 
  ))
})







observeEvent(input$institution_button, {
  institucion_raw <- paciente_info()$institucion
  institucion_formateada <- dplyr::case_when(
    institucion_raw == "FcoVitoria" ~ "Francisco de Vitoria",
    institucion_raw == "Cisneros" ~ "Residencia Cisneros",
    TRUE ~ institucion_raw  # por si acaso hay otros valores
  )
  
  showModal(modalDialog(
    title = "Institución del Paciente",
    paste("El paciente", input$selected_patient, "pertenece a la institución", institucion_formateada),
    easyClose = TRUE,
    footer = modalButton("Cerrar")
  ))
})


observeEvent(input$gender_button, {
  genero_raw <- paciente_info()$genero
  genero <- ifelse(genero_raw == "F", "femenino", "masculino")
  
  showModal(modalDialog(
    title = "Sexo del Paciente",
    paste("El paciente", input$selected_patient, "es de sexo", genero),
    easyClose = TRUE,
    footer = modalButton("Cerrar")
  ))
})


observeEvent(input$age_button, {
  showModal(modalDialog(
    title = "Edad del Paciente",
    paste("La edad del paciente", input$selected_patient, "es de",
          paciente_info()$edad, "años"),
    easyClose = TRUE,
    footer = modalButton("Cerrar")
  ))
})

observeEvent(input$berthel_button, {
  showModal(modalDialog(
    title = "Índice de Barthel",
    paste("El índice de barthel del paciente", input$selected_patient, "es",
          paciente_info()$berthel),
    easyClose = TRUE,
    footer = modalButton("Cerrar")
  ))
})






observeEvent(input$toggle_button, {
  showModal(modalDialog(
    title = "¿Qué debes esperar de cada gráfico?",
    HTML(paste0(
      "<p>• Datos Originales: Este gráfico muestra únicamente los datos reales tal y como fueron registrados en la base de datos. Cada punto representa una medición real tomada en una fecha específica.</p>",
      "<p>• Datos Interpolados: Este gráfico incluye tanto los datos originales como puntos adicionales generados mediante técnicas de interpolación (como <em>spline</em>). Estos puntos interpolados estiman el valor de las variables en fechas donde no hubo medición, permitiendo visualizar tendencias más suaves o continuas.</p>",
      "<p>Los puntos interpolados se muestran con un color distinto para diferenciarlos claramente de los datos reales.</p>",
      "<p>Si deseas saber más sobre cómo se genera esta interpolación, haz clic aquí: ",
      actionLink("go_interpolacion", "ver interpolación", style = "color: #007bff; text-decoration: underline;"),
      ".</p>"
    )),
    easyClose = TRUE,
    footer = modalButton("Cerrar")
  ))
})




observeEvent(input$go_interpolacion, {
  valores$pagina <- "interpolacion" 
})




# Evento para volver a la plataforma (inicio)
observeEvent(input$volver_info_inicio, {
  valores$pagina <- "inicio"
})


observeEvent(input$abrir_chat, {
  shinyjs::toggle(id = "chat-box")
})


chat_mensajes <- reactiveVal(character())  # almacena mensajes como si fuese un historial

observeEvent(input$boton_limpiar_chat, {
  chat_mensajes(character())  # borra todo el historial
})



output$chat_content <- renderUI({
  msgs <- chat_mensajes()
  if (length(msgs) == 0) return(NULL)
  HTML(paste0(paste(msgs, collapse = "<br><br>"), "</div>"))
})

observeEvent(input$boton_resumen, {
  paciente <- paciente_info()
  infecciones <- infecciones_data()
  
  # Extraer datos clave del paciente
  edad <- paciente$edad
  genero <- ifelse(paciente$genero == "F", "una mujer", "un hombre")
  barthel <- paciente$berthel
  
  # Interpretación del índice Barthel
  interpretacion_barthel <- case_when(
    is.na(barthel) ~ "no se dispone de información sobre su nivel de autonomía.",
    barthel >= 85 ~ paste0("tiene un buen nivel de autonomía funcional (Barthel: ", barthel, ")."),
    barthel >= 60 ~ paste0("presenta una autonomía moderada (Barthel: ", barthel, ")."),
    TRUE ~ paste0("presenta una dependencia funcional considerable (Barthel: ", barthel, ").")
  )
  
  # Infecciones activas
  infecciones_validas <- infecciones %>% filter(Infeccion != 0)
  total <- nrow(infecciones_validas)
  
  # Conteo de tipos
  conteo_tipos <- table(factor(infecciones_validas$Infeccion, levels = c(1, 2, 3)))
  
  partes <- c()
  if (conteo_tipos["1"] > 0) partes <- c(partes, paste0(conteo_tipos["1"], " de tipo STI"))
  if (conteo_tipos["2"] > 0) partes <- c(partes, paste0(conteo_tipos["2"], " de tipo ARI"))
  if (conteo_tipos["3"] > 0) partes <- c(partes, paste0(conteo_tipos["3"], " de tipo UTI"))
  tipos_texto <- paste(partes, collapse = ", ")
  
  # Fechas
  fechas <- sort(as.Date(infecciones_validas$date_samples))
  primera <- if (length(fechas) > 0) format(min(fechas), "%d/%m/%Y") else NULL
  ultima <- if (length(fechas) > 0) format(max(fechas), "%d/%m/%Y") else NULL
  intervalo_medio <- if (length(fechas) > 1) round(mean(diff(fechas))) else NA
  
  # Construir mensaje
  resumen <- paste0(
    "El paciente ", input$selected_patient, " es ", genero, " de ", edad, " años. ",
    "En cuanto a su autonomía, ", interpretacion_barthel, "\n\n",
    if (total == 0) {
      "Hasta el momento, no se han registrado episodios de infección."
    } else {
      paste0(
        "Se han documentado ", total, " episodios de infección, distribuidos en: ", tipos_texto, ". ",
        "La primera infección ocurrió el ", primera, " y la más reciente el ", ultima, ". ",
        if (!is.na(intervalo_medio)) {
          paste0("El intervalo promedio entre infecciones ha sido de ", intervalo_medio, " días.")
        } else {
          ""
        }
      )
    }
  )
  
  chat_mensajes(c(chat_mensajes(), resumen))
})



mostrar_selector <- reactiveVal(FALSE)

observeEvent(input$mostrar_selector_fecha, {
  toggle <- !mostrar_selector()
  mostrar_selector(toggle)
  
  if (!toggle) {
    updateDateInput(inputId = "fecha_muestra_chat", value = NULL)
  }
})


output$selector_fecha_ui <- renderUI({
  if (!mostrar_selector()) return(NULL)
  
  tagList(
    br(),
    dateInput("fecha_muestra_chat", "Seleccionar fecha de muestra:", value = Sys.Date(), format = "yyyy-mm-dd"),
    actionButton("ver_muestra_chat", "Buscar", class = "btn btn-primary btn-sm")
  )
})

observeEvent(input$ver_muestra_chat, {
  paciente <- paciente_data()
  fecha_seleccionada <- input$fecha_muestra_chat
  
  datos_dia <- paciente %>% filter(as.Date(date_samples) == as.Date(fecha_seleccionada))
  
  if (nrow(datos_dia) == 0) {
    fechas_disponibles <- range(as.Date(paciente$date_samples), na.rm = TRUE)
    mensaje <- paste0(
      "No se encontraron datos para el ", format(fecha_seleccionada, "%d/%m/%Y"),
      " en el paciente ", input$selected_patient, ".\n",
      "Te recomiendo buscar dentro del rango de fechas disponibles: ",
      format(fechas_disponibles[1], "%d/%m/%Y"), " a ",
      format(fechas_disponibles[2], "%d/%m/%Y"), "."
    )
  }
  
  else {
    nombres_fisios <- c(
      "body_temp"   = "Temperatura Corporal",
      "SPO2.Min"    = "Saturación de Oxígeno Mínima",
      "BPM.Avg"     = "Frecuencia Cardíaca Promedio",
      "EDA.Avg"     = "Actividad Electrodérmica Promedio",
      "tmed"        = "Temperatura Ambiente Promedio",
      "sol"         = "Radiación Solar",
      "presMean"    = "Presión Atmosférica Media"
    )
    
    valores <- purrr::map_chr(names(nombres_fisios), function(var) {
      valor <- datos_dia[[var]]
      nombre <- nombres_fisios[[var]]
      paste0("<p>•", nombre, ":</b> ", ifelse(is.na(valor), "no disponible", round(valor, 2)), "</p>")
    })
    mensaje <- paste0(
      " Datos del ", format(fecha_seleccionada, "%d/%m/%Y"), " para el paciente ", input$selected_patient, ":</b>",
      paste(valores, collapse = "")
    )
    
  }
  
  chat_mensajes(c(chat_mensajes(), mensaje))
})


observeEvent(input$boton_tipos_infeccion, {
  mensaje <- paste0(
    "<p> Tipos de infección registrados:</strong></p>",
    "<p> STI (Skin and Soft Tissue Infection): Afecta piel y tejidos blandos, muy común en pacientes con heridas, úlceras o infecciones dérmicas.</p>",
    "<p> ARI (Acute Respiratory Infection): Incluye bronquitis, neumonía u otras infecciones pulmonares. Frecuente en personas mayores o inmunodeprimidas.</p>",
    "<p> UTI (Urinary Tract Infection): Infección urinaria, habitual en pacientes con sondas o movilidad reducida.</p>",
    "</div>"
  )
  
  chat_mensajes(c(chat_mensajes(), mensaje))
})





