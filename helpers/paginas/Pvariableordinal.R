# Pvariableordinal.R: interfaz para configurar y ajustar un modelo con variable respuesta ordinal (tipo de infección)

variableordinal_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Ajustar Modelo: Tipo de Infección Ordinal", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  tags$head(
    tags$style(HTML("
    .wizard-box {
      max-width: 600px;
      margin: 50px auto;
      padding: 30px;
      border-radius: 12px;
      background-color: #f9f9f9;
      box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }

    .wizard-buttons {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 30px;
    }

    .volver-btn {
      background: none;
      border: none;
      font-size: 26px;
      color: #444;
    }

    .volver-btn:hover {
      color: #007bff;
    }

    .ajustar-btn {
      margin: 0 auto;
      display: block;
    }
  "))
  ),
  
  div(class = "wizard-box",
      uiOutput("encuesta_ui_ordinal"),
      
      div(class = "wizard-buttons",
          # Flecha atrás
          conditionalPanel("output.mostrarAnterior",
                           actionButton("anterior_ordinal", label = NULL, icon = icon("chevron-left"), class = "volver-btn")),
          
          # Botón de ajuste (centrado en paso 3)
          conditionalPanel("output.mostrarAjustar",
                           actionButton("ajustar_modelo_ordinal", "Ajustar modelo", class = "btn btn-link")),
          
          # Flecha siguiente
          conditionalPanel("output.mostrarSiguiente",
                           actionButton("siguiente_ordinal", label = NULL, icon = icon("chevron-right"), class = "volver-btn")),
          
          # Paso 4: botón para reiniciar
          conditionalPanel("output.mostrarReset",
                           actionButton("resetear_ordinal", "Ajustar otro modelo", class = "btn btn-link"))
      )
  ),
  
  
  actionButton("volver_variableordinal_ajustarmodelo", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
)
