# Pgrafico.R: interfaz para visualizar el gráfico interactivo de evolución temporal y la tabla asociada

grafico_ui <- fluidPage(
  
  titlePanel(""),
  
  tags$head(tags$style(HTML("
    .grafico-container {
      display: flex;
      justify-content: center;
      padding-top: 30px;
    }
    .grafico-box {
      width: 90%;
      max-width: 1000px;
      background-color: #f8f9fa;
      padding: 25px;
      border-radius: 10px;
      box-shadow: 0px 4px 8px rgba(0,0,0,0.1);
    }
    .grafico-subtitulo {
      font-size: 18px;
      font-weight: bold;
      margin-bottom: 15px;
    }
  "))),
  
  div(class = "grafico-container",
      div(class = "grafico-box",
          
          div(class = "grafico-subtitulo", ""),
          plotlyOutput("moving_plot", height = "600px"),
          
          uiOutput("no_selection_message"), 
          
          br(),
          
          div(class = "grafico-subtitulo", ""),
          tableOutput("movement_table")
      )
  ),
  
  actionButton("volver_grafico_grafmov", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333;
                        padding: 4px;")
)

