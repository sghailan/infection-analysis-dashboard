# Pgrafos.R: interfaz para explorar el grafo de transiciones entre infecciones y consultar métricas asociadas

grafos_ui <- fluidPage(
    useShinyjs(),
    div(
      style = "text-align: center; margin-bottom: 20px;",
      h2("Grafo de transiciones entre infecciones", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
    ),
    
    sidebarLayout(
      sidebarPanel(
        selectInput("paciente", "Selecciona paciente:",
                    choices = c("Global", as.character(sort(unique(diagnostics_Q$resident_code)))),
                    selected = "Global"),
        
        selectInput("orden", "Aristas con:",
                    choices = c("Número de veces de las transiciones", "Orden de transiciones", "Días transcurridos en cada transición"),
                    selected = "Número de veces de las transiciones"),
        br(),
        
        conditionalPanel(
          condition = "input.paciente != 'Global'",
          bsCollapse(id = "comandos", open = NULL,
                     bsCollapsePanel("Comandos", 
                                     actionButton("btn_rapida", "Transición más rápida", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_rapida"),
                                     br(),
                                     
                                     actionButton("btn_lenta", "Transición más lenta", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_lenta"),
                                     br(),
                                     
                                     actionButton("btn_media", "Media días entre transiciones", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_media"),
                                     br(),
                                     
                                     actionButton("btn_in", "Infección más receptora (grado entrada)", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_in"),
                                     br(),
                                     
                                     actionButton("btn_out", "Infección más emisora (grado salida)", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_out"),
                                     br(),
                                     
                                     actionButton("btn_bt", "Infección puente (betweenness)", class = "btn btn-primary"),
                                     br(), verbatimTextOutput("info_bt"),
                                     br(),
                                     actionButton("btn_closeness", "Infección más accesible (closeness)", class = "btn btn-primary"),
                                     verbatimTextOutput("info_closeness"),
                                     br(),
                                     actionButton("btn_entropia", "Entropía de transiciones", class = "btn btn-primary"),
                                     verbatimTextOutput("info_entropia")
                                     
                                     
                     )
          )
        )
      ),
      
      mainPanel(
        plotOutput("grafo"),
        br()
      )
    ),
    
    actionButton("volver_grafos_movimiento", label = NULL,
                 icon = icon("chevron-left"),
                 style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
    
  )

