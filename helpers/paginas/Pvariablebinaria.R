# Pvariablebinaria.R: interfaz para configurar y ajustar un modelo con variable respuesta binaria (infección sí/no)

variablebinaria_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Ajustar Modelo: Diagnóstico Infección Si/No", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
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
      uiOutput("encuesta_ui_binaria"),
      
      div(class = "wizard-buttons",
          # Flecha atrás
          conditionalPanel("output.mostrarAnterior_binaria",
                           actionButton("anterior_binaria", label = NULL, icon = icon("chevron-left"), class = "volver-btn")),
          
          # Botón de ajuste (centrado en paso 3)
          conditionalPanel(
            condition = "output.mostrarAjustar_binaria",
            actionButton("ajustar_modelo_binaria", "Ajustar modelo",class = "btn btn-link")
          )
          ,
          
          # Flecha siguiente
          conditionalPanel("output.mostrarSiguiente_binaria",
                           actionButton("siguiente_binaria", label = NULL, icon = icon("chevron-right"), class = "volver-btn")),
          
          # Paso 4: botón para reiniciar
          conditionalPanel("output.mostrarReset_binaria",
                           actionButton("resetear_binaria", "Ajustar otro modelo", class = "btn btn-link"))
      )
  ),
  
  actionButton("volver_variablebinaria_ajustarmodelo", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
)



