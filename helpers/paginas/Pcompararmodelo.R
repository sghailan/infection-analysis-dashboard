# Pcompararmodelo.R: interfaz para guiar al usuario en la selección y comparación de distintos modelos

compararmodelo_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Comparar modelos", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  tags$head(
    tags$style(HTML("
    .wizard-box {
      max-width: 800px;
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

    .btn-link:hover {
      color: #0056b3;
      text-decoration: none;
    }
  "))
  ),
  
  
  div(class = "wizard-box",
      uiOutput("wizard_ui_comparar"),
      
      div(class = "wizard-buttons",
          conditionalPanel("output.mostrarAnterior_comparar",
                           actionButton("anterior_comparar", label = NULL, icon = icon("chevron-left"), class = "volver-btn")),
          
          conditionalPanel("output.mostrarSiguiente_comparar",
                           actionButton("siguiente_comparar", label = NULL, icon = icon("chevron-right"), class = "volver-btn")),
          
          conditionalPanel("output.mostrarComparar",
                           actionButton("comparar_modelos", "Comparar modelos",class = "btn btn-link"))
      )
  ),
  
  actionButton("volver_comparar_modelo_eligeopcionpanel", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333; padding: 4px;")
)

