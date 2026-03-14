# Pprediccion.R: interfaz para guiar al usuario en el proceso de realizar predicciones con los modelos del estudio

prediccion_ui <- fluidPage(
  useShinyjs(),
  
  tags$head(
    tags$style(HTML("
      .wizard-box {
        max-width: 700px;
        margin: 40px auto;
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
    "))
  ),
  
  div(style = "text-align: center; margin-bottom: 20px;",
      h2("Realizar Predicción", style = "font-family: 'Roboto', sans-serif; font-weight: 500; font-size: 28px;")
  ),
  
  div(class = "wizard-box",
      uiOutput("wizard_ui_prediccion"),
      
      div(class = "wizard-buttons",
          conditionalPanel("output.mostrarAnterior_prediccion",
                           actionButton("anterior_prediccion", label = NULL, icon = icon("chevron-left"), class = "volver-btn")),
          conditionalPanel("output.mostrarSiguiente_prediccion",
                           actionButton("siguiente_prediccion", label = NULL, icon = icon("chevron-right"), class = "volver-btn")),
          conditionalPanel("output.mostrarPredecir",
                           actionButton("realizar_prediccion", "Realizar predicción", class = "btn btn-link")),
          conditionalPanel("output.mostrarResetear_prediccion",
                           actionButton("resetear_prediccion", "Realizar otra predicción", class = "btn btn-link"))
      )
  ),
  
  actionButton("volver_prediccion_eligeopcionpanel", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333; padding: 4px;")
)



