# Pvariablemultinomial.R: interfaz para seleccionar variables y ajustar un modelo multinomial

variablemultinomial_ui <- fluidPage(
  titlePanel("Variable Multinomial: Ajuste del Modelo"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("modelo_tipo_multinomial", "Tipo de modelo:",
                   choices = c("Efectos fijos" = "fijo",
                               "Mixto (intercepto aleatorio)" = "intercepto",
                               "Mixto (intercepto y pendiente aleatoria)" = "pendiente")),
      
      checkboxGroupInput("vars_multinomial", "Variables explicativas:",
                         choices = c("age", "sex", "body_temp", "SPO2.Min", 
                                     "BPM.Avg", "EDA.Avg", "tmed", "sol", "presMean_scaled")),
      
      uiOutput("pendiente_selector_multinomial"),
      
      actionButton("ajustar_modelo_multinomial", "Ajustar modelo")
    ),
    
    mainPanel(
      verbatimTextOutput("formula_multinomial"),
      verbatimTextOutput("resumen_multinomial"),
      verbatimTextOutput("metricas_multinomial"),
      verbatimTextOutput("error_multinomial"),
    )
  ),
  actionButton("volver_variablemultinomial_ajustarmodelo", "",  
               align = "left",
               icon = icon("arrow-left"),  
               class = "volver-btn")
)
