# Pgrafmov2.R: interfaz para visualizar la línea temporal de diagnósticos de infección por paciente

grafmov2_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Visualización Temporal de los Diagnósticos de Infección", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  tags$head(tags$style(HTML("
    .grafmov-container {
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding-top: 30px;
    }
    .grafmov-box {
      width: 90%;
      max-width: 1000px;
      background-color: #f8f9fa;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
    }
    .grafmov-select {
      margin-bottom: 20px;
    }
  "))),
  
  div(class = "grafmov-container",
      div(class = "grafmov-box",
          fluidRow(
            column(12,
                   selectInput("residente_select", "Selecciona pacientes:",
                               choices = setNames(resumen_infecciones$resident_code, resumen_infecciones$label),
                               selected = NULL,
                               multiple = TRUE,
                               width = "100%")
            )
          ),
          fluidRow(
            column(12,
                   plotlyOutput("timeline_plot")
            )
          )
      )
  ),
  
  # Botón de volver
  actionButton("volver_grafmov2_eligetiempo", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333;
                        padding: 4px;")
)

