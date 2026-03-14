# Pinteractivos.R: interfaz para explorar distintas preguntas del estudio mediante gráficos interactivos

interactivos_ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .titulo-principal {
        text-align: center;
        font-family: 'Roboto', sans-serif;
        font-weight: 500;
        font-size: 30px;
        margin-top: 20px;
        margin-bottom: 30px;
        color: #333;
      }
      .btn-pregunta {
        margin-bottom: 10px;
        font-size: 14px;
        text-align: left;
        background-color: #f8f9fa;
        border: 1px solid #ddd;
        box-shadow: 0px 2px 4px rgba(0,0,0,0.05);
        padding: 10px;
        border-radius: 6px;
      }
    "))
  ),
  
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Análisis mediante gráficos", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      lapply(0:10, function(i) {
        if (i != 7) {  # saltamos btn7 si no existe
          btn_id <- paste0("btn", i)
          preguntas <- c(
            "¿Qué paciente se infecta más?",
            "¿Cómo se distribuyen los tipos de infección en los pacientes? ¿Hay algún paciente que durante todo el estudio y de manera recurrente sólo se infecta de un solo tipo?",
            "A lo largo de los 2 años del estudio, ¿cómo se han repartido las infecciones?",
            "Distribución del número de infecciones por paciente",
            "¿Puede el número de infecciones por paciente modelarse con una distribución de Poisson?",
            "¿La infección del tipo UTI es realmente la más común?",
            "¿Qué combinaciones de infecciones son las más comunes entre los pacientes?",
            NA,  # salto btn7
            "¿En qué mes hay más infecciones?",
            "¿Hay más infecciones en verano que en invierno?",
            "¿Cuántas infecciones ocurren por día de la semana?"
          )
          actionButton(btn_id,
                       HTML(paste0("<div style='white-space: normal;'>", preguntas[i + 1], "</div>")),
                       width = "100%",
                       class = "btn-pregunta")
        }
      })
    ),
    
    mainPanel(
      uiOutput("seleccion_grafico"),
      
      conditionalPanel("output.grafico_mostrado == 'grafico0'", plotlyOutput("grafico0")),
      conditionalPanel("output.grafico_mostrado == 'grafico1'", plotlyOutput("grafico1")),
      conditionalPanel("output.grafico_mostrado == 'grafico2'", plotlyOutput("grafico2")),
      conditionalPanel("output.grafico_mostrado == 'grafico3'", 
                       plotlyOutput("grafico3"),
                       verbatimTextOutput("resumen_grafico3")),
      conditionalPanel("output.grafico_mostrado == 'grafico4'",
                       sliderInput("lambda", "Selecciona el valor de λ:", min = 1, max = 7, value = 3.51, step = 0.1),
                       helpText("λ representa el número medio de infecciones por paciente"),
                       plotlyOutput("grafico4"),
                       br(),
                       p("En este ejercicio, el valor por defecto de λ es 3.51, que corresponde a la media empírica observada en el estudio. No obstante, el parámetro puede modificarse para comparar con otras distribuciones de Poisson teóricas y ver cómo varía el ajuste.")),
      conditionalPanel("output.grafico_mostrado == 'grafico5'", plotlyOutput("grafico5")),
      conditionalPanel("output.grafico_mostrado == 'grafico6'", plotlyOutput("grafico6")),
      conditionalPanel("output.grafico_mostrado == 'grafico8'", plotlyOutput("grafico8")),
      conditionalPanel("output.grafico_mostrado == 'grafico9'", plotlyOutput("grafico9")),
      conditionalPanel("output.grafico_mostrado == 'grafico10'", plotlyOutput("grafico10"))
    )
  ),
  
  actionButton("volver_interactivos_movimiento", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333;
                        padding: 4px;")
)


