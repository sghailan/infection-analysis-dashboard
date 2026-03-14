# Iinteractivos.R: desarrolla la lógica de la sección de gráficos interactivos del estudio.
# Gestiona la navegación entre las distintas visualizaciones exploratorias, controla qué
# gráfico debe mostrarse en cada momento y genera un conjunto amplio de representaciones
# interactivas sobre la frecuencia, distribución y evolución temporal de las infecciones.
# Además, incluye comparaciones por paciente, tipo de infección, mes, estación y día de
# la semana, así como gráficos de apoyo para interpretar patrones generales del estudio.

# BOTON VOLVER
observeEvent(input$volver_interactivos_movimiento, {
  valores$pagina <- "movimiento"
})

## BOTONES GRAFICOS
  grafico_actual <- reactiveVal("")
  
  observeEvent(input$btn0, {
    grafico_actual("grafico0")
  }) 
  
  observeEvent(input$btn1, {
    grafico_actual("grafico1")
  })
  
  observeEvent(input$btn2, {
    grafico_actual("grafico2")
  }) 
  
  observeEvent(input$btn3, {
    grafico_actual("grafico3")
  }) 
  
  observeEvent(input$btn4, {
    grafico_actual("grafico4")
  })  
  
  observeEvent(input$btn5, {
    grafico_actual("grafico5")
  })
  
  observeEvent(input$btn6, {
    grafico_actual("grafico6")
  })
  
  observeEvent(input$btn7, {
    grafico_actual("grafico7")
  })
  observeEvent(input$btn8, {
    grafico_actual("grafico8")
  })
  
  observeEvent(input$btn9, {
    grafico_actual("grafico9")
  })
  observeEvent(input$btn10, {
    grafico_actual("grafico10")
  })
  
  
  # Para que Shiny sepa qué gráfico mostrar (usado en conditionalPanel)
  output$grafico_mostrado <- reactive({
    grafico_actual()
  })
  outputOptions(output, "grafico_mostrado", suspendWhenHidden = FALSE)
  
  ## grafico 10
  
  output$grafico10 <- renderPlotly({
    # Definir orden correcto
    dias_orden <- c("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo")
    tipos_orden <- c("UTI", "ARI", "STI")
    
    # Agrupar, completar y calcular porcentaje
    infecciones_por_dia_tipo <- diagnostics_Q %>%
      mutate(
        dia_semana = wday(date_diagnosis, label = TRUE, abbr = FALSE, week_start = 1),
        dia_semana = recode(as.character(dia_semana),
                            "Monday" = "Lunes",
                            "Tuesday" = "Martes",
                            "Wednesday" = "Miércoles",
                            "Thursday" = "Jueves",
                            "Friday" = "Viernes",
                            "Saturday" = "Sábado",
                            "Sunday" = "Domingo")
      ) %>%
      count(dia_semana, Types_of_Infectious) %>%
      complete(
        dia_semana = dias_orden,
        Types_of_Infectious = tipos_orden,
        fill = list(n = 0)
      ) %>%
      group_by(dia_semana) %>%
      mutate(
        total_dia = sum(n),
        porcentaje = round((n / total_dia) * 100, 1)
      ) %>%
      ungroup() %>%
      mutate(
        dia_semana = factor(dia_semana, levels = dias_orden),
        Types_of_Infectious = factor(Types_of_Infectious, levels = tipos_orden)
      )
    
    # Crear gráfico interactivo
    plot_ly(
      data = infecciones_por_dia_tipo,
      x = ~dia_semana,
      y = ~n,
      color = ~Types_of_Infectious,
      colors = c("ARI" = "#ff7f0e", "STI" = "#2ca02c", "UTI" = "#1f77b4"),
      type = 'bar',
      text = ~paste(
        "Tipo:", Types_of_Infectious,
        "<br>Día:", dia_semana,
        "<br>Casos:", n,
        "<br>Porcentaje del tipo:", porcentaje, "%"
      ),
      hoverinfo = "text",
      textposition = "none"
    ) %>%
      layout(
        barmode = 'stack',
        title = "Infecciones por día de la semana y tipo",
        xaxis = list(title = "Día de la semana"),
        yaxis = list(title = "Número de infecciones"),
        legend = list(title = list(text = "Tipo de infección"))
      )
    
  })
 ## grafico 9 
  output$grafico9 <- renderPlotly({
    # Función para clasificar estaciones (hemisferio norte)
    get_estacion <- function(fecha) {
      mes <- month(fecha)
      case_when(
        mes %in% c(12, 1, 2) ~ "Invierno",
        mes %in% c(3, 4, 5)  ~ "Primavera",
        mes %in% c(6, 7, 8)  ~ "Verano",
        mes %in% c(9, 10, 11) ~ "Otoño"
      )
    }
    
    # Añadir la columna de estación
    diagnostics_Q <- diagnostics_Q %>%
      mutate(estacion = get_estacion(date_diagnosis))
    df_estaciones <- diagnostics_Q %>%
      group_by(estacion, Types_of_Infectious) %>%
      summarise(conteo = n(), .groups = "drop") %>%
      group_by(estacion) %>%
      mutate(
        total_estacion = sum(conteo),
        porcentaje = round(conteo / total_estacion * 100, 1)
      )
    
    plot_ly(
      data = df_estaciones,
      x = ~estacion,
      y = ~conteo,
      type = "bar",
      color = ~Types_of_Infectious,
      colors = c("ARI" = "#ff7f0e", "STI" = "#2ca02c", "UTI" = "#1f77b4"),
      text = ~paste0(
        "Estación: ", estacion, "<br>",
        "Tipo: ", Types_of_Infectious, "<br>",
        "Casos: ", conteo, "<br>",
        "Porcentaje: ", porcentaje, "%<br>",
        "Total en estación: ", total_estacion
      ),
      textposition = "none",
      hoverinfo = "text"
    ) %>%
      layout(
        title = "Infecciones por estación y tipo",
        xaxis = list(title = "Estación"),
        yaxis = list(title = "Número de infecciones"),
        barmode = "stack"
      )
  })
  ## grafico 8 
  output$grafico8 <- renderPlotly({
    # Extraer el mes de la fecha de diagnóstico
    diagnostics_Q <- diagnostics_Q %>%
      mutate(month = format(date_diagnosis, "%m"))
    
    # Contar el número de infecciones por mes
    infection_counts <- diagnostics_Q %>%
      group_by(month) %>%
      summarise(count = n())
    
    # Crear histograma
    ggplot(infection_counts, aes(x = month, y = count)) +
      geom_bar(stat = "identity", fill = "royalblue") +
      labs(title = "Histograma de Infecciones por Mes",
           x = "Mes",
           y = "Número de Infecciones Registradas") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
  })
  
  ## grafico 7
  output$grafico_comparativo_residencias <- renderPlotly({
    plot_ly(
      data = resumen_long,
      x = ~Métrica,
      y = ~Valor,
      color = ~Institution,
      colors = c("Cisneros" = "#1f77b4", "FcoVitoria" = "#ff7f0e"),
      type = "bar",
      text = ~round(Valor, 2),
      hoverinfo = "text",
      textposition = "outside"
    ) %>%
      layout(
        title = "Comparación entre residencias en indicadores clave",
        xaxis = list(title = "", tickangle = -45),
        yaxis = list(title = "Valor"),
        barmode = "group",
        margin = list(b = 100)
      )
  })
  ## f grafico 7
  ## grafico 6
  output$grafico6 <- renderPlotly({
    combinaciones_infeccion <- diagnostics_Q %>%
      group_by(resident_code) %>%
      summarise(
        tipos = paste(sort(unique(Types_of_Infectious)), collapse = ", "),
        .groups = "drop"
      ) %>%
      count(tipos) %>%
      arrange(desc(n))
    
    plot_ly(
      data = combinaciones_infeccion,
      x = ~n,
      y = ~reorder(tipos, n),
      orientation = "h",
      type = "bar",
      text = ~paste0("Pacientes con esta combinación: ", n),
      hoverinfo = "text",
      textposition = "none", 
      marker = list(color = "#1f77b4")
    ) %>%
      layout(
        barmode = "stack",
        yaxis = list(title = "Combinación de infecciones"),
        xaxis = list(title = "Número de pacientes"),
        margin = list(l = 100)
      )
    
  })
  
  ## f grafico 6
## grafico 5
  output$grafico5 <- renderPlotly({
    df_tipo <- diagnostics_Q %>%
      count(Types_of_Infectious, name = "Frecuencia") %>%
      mutate(
        Porcentaje = round(100 * Frecuencia / sum(Frecuencia), 1)
      ) %>%
      arrange(desc(Frecuencia))
    
    plot_ly(
      data = df_tipo,
      labels = ~Types_of_Infectious,
      values = ~Frecuencia,
      type = "pie",
      textinfo = "label+percent",
      marker = list(colors = c("UTI" = "#1f77b4", "STI" = "#2ca02c", "ARI" = "#ff7f0e"))
    ) %>%
      layout(
        title = "Distribución de tipos de infección",
        legend = list(x = 0.8, y = 0.9)
      )
  })
  ## f grafico5
  ## GRAFICO 3
  output$grafico3 <- renderPlotly({
    conteo_residentes <- diagnostics_Q %>%
      count(resident_code, name = "total_infecciones")
    
    g <- ggplot(conteo_residentes, aes(x = "Infecciones", y = total_infecciones)) +
      geom_boxplot(width = 0.3, fill = "#1f77b4", alpha = 0.7, color = "black", outlier.color = "red") +
      geom_hline(yintercept = mean(conteo_residentes$total_infecciones), 
                 linetype = "dashed", color = "darkred", linewidth = 0.7) +
      labs(
        title = "Distribución del número de infecciones por paciente",
        x = NULL,
        y = "Total de infecciones"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_blank())
    
    ggplotly(g)
  })
  

  output$resumen_grafico3 <- renderPrint({
    conteo_residentes <- diagnostics_Q %>%
      count(resident_code, name = "total_infecciones")
    
    summary(conteo_residentes$total_infecciones)
  })
## FGRAFICO 3
  
## GRAFICO 4
  output$grafico4 <- renderPlotly({
    conteo_residentes <- diagnostics_Q %>%
      count(resident_code, name = "total_infecciones")
    
    datos_reales <- conteo_residentes %>%
      count(total_infecciones, name = "observado") %>%
      complete(total_infecciones = 0:max(total_infecciones), fill = list(observado = 0))
    
    generar_datos_poisson <- function(lambda, n) {
      tibble(
        infecciones = 0:10,
        esperado = round(dpois(0:10, lambda) * n, 2)
      )
    }
    
    datos_poisson <- generar_datos_poisson(input$lambda, nrow(conteo_residentes))
    
    datos_plot <- datos_reales %>%
      full_join(datos_poisson, by = c("total_infecciones" = "infecciones"))
    
    plot_ly(datos_plot, x = ~total_infecciones) %>%
      add_bars(y = ~observado, name = "Observado", marker = list(color = "#1f77b4")) %>%
      add_lines(y = ~esperado, name = "Esperado (Poisson)", line = list(color = "#d62728", width = 2)) %>%
      layout(
        title = paste("Comparación con Poisson (λ =", input$lambda, ")"),
        xaxis = list(title = "Número de infecciones por paciente"),
        yaxis = list(title = "Frecuencia"),
        barmode = "overlay"
      )
  })
## FGRAFICO 4

## GRAFICO O
  output$grafico0 <-  renderPlotly({
    datos_residentes <- diagnostics_Q %>%
      count(resident_code, name = "total_infecciones") %>%
      mutate(
        porcentaje = round(100 * total_infecciones / sum(total_infecciones), 1)
      ) %>%
      arrange(desc(total_infecciones))
    
    plot_ly(
      data = datos_residentes,
      x = ~reorder(as.factor(resident_code), -total_infecciones),
      y = ~total_infecciones,
      type = "bar",
      text = ~paste0("Residente: ", resident_code,
                     "<br>Total infecciones: ", total_infecciones,
                     "<br>Representa el ", porcentaje, "% de infecciones totales"),
      textposition = "none",
      hoverinfo = "text",
      marker = list(color = "#1f77b4")
    ) %>%
      layout(
        title = "Número de infecciones detectadas a cada paciente",
        xaxis = list(title = "Código de residente", tickangle = -90),
        yaxis = list(title = "Número de infecciones")
      )
  })

  ## FGRAFICO 0
  
## GRAFICO 1
  output$grafico1 <- renderPlotly({
    
    df_residente_tipo <- diagnostics_Q %>%
      group_by(resident_code, Types_of_Infectious) %>%
      summarise(conteo = n(), .groups = "drop") %>%
      group_by(resident_code) %>%
      mutate(
        total_paciente = sum(conteo),
        porcentaje = round(conteo / total_paciente * 100, 1)
      )
    
    plot_ly(
      data = df_residente_tipo,
      x = ~as.factor(resident_code),
      y = ~conteo,
      type = "bar",
      color = ~Types_of_Infectious,
      colors = c("ARI" = "#ff7f0e", "STI" = "#2ca02c", "UTI" = "#1f77b4"),
      text = ~paste0(
        "Residente: ", resident_code, "<br>",
        "Tipo de infección: ", Types_of_Infectious, "<br>",
        conteo, " de ", total_paciente, " totales del paciente", "<br>",
        "Corresponde a un ", porcentaje, "% de sus infecciones"
      ),
      hoverinfo = "text"
    ) %>%
      layout(
        title = "Número y tipo de infecciones por residente",
        xaxis = list(title = "Código de residente", tickangle = -45),
        yaxis = list(title = "Número de infecciones"),
        barmode = "stack"
      )
  })
  
## FGRAFICO 1

  ## GRAFICO 2
  
  output$grafico2 <- renderPlotly({
    # Paso 1: calcular totales y porcentajes
    df_plot <- diagnostics_Q %>%
      mutate(mes = floor_date(date_diagnosis, "month")) %>%
      group_by(mes, Types_of_Infectious) %>%
      summarise(conteo = n(), .groups = "drop") %>%
      group_by(mes) %>%
      mutate(
        total_mes = sum(conteo),
        porcentaje = round(conteo / total_mes * 100, 1)
      )
    
    # Paso 2: gráfico interactivo
    plot_ly(
      data = df_plot,
      x = ~mes,
      y = ~conteo,
      type = "bar",
      color = ~Types_of_Infectious,
      colors = c("ARI" = "#ff7f0e", "STI" = "#2ca02c", "UTI" = "#1f77b4"),
      text = ~paste0(
        format(mes, "%b %Y"), "<br>",
        "Tipo de infección: ", Types_of_Infectious, "<br>",
        "Casos de este tipo: ", conteo, "<br>",
        "Porcentaje de este tipo: ", porcentaje, "%<br>",
        "Total de infecciones mensuales: ", total_mes
      ),
      hoverinfo = "text"
    ) %>%
      layout(
        title = "Infecciones por mes y tipo (con totales y %)",
        xaxis = list(title = "Mes", tickformat = "%b %Y"),
        yaxis = list(title = "Número de infecciones"),
        barmode = "stack"
      )
  })
  
  ## FGRAFICO 2

  
  