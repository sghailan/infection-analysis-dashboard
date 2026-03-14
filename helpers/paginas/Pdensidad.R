# Pdensidad.R: interfaz para visualizar curvas de densidad por grupo y realizar un test de Wilcoxon sobre la variable seleccionada

densidad_ui<- fluidPage(
  div(
  style = "text-align: center; margin-bottom: 20px;",
  h2("Curvas de densidad por grupo", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
),
  sidebarLayout(
    sidebarPanel(
      selectInput("grouping", "Agrupar por:", 
                  choices = c("Sexo" = "sex", 
                              "Residencia" = "Institution", 
                              "Edad" = "grupo_edad")),
      selectInput("variable", "Selecciona la variable:",
                  choices = c(
                    "Temperatura Corporal (°C)" = "body_temp",
                    "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
                    "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
                    "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
                    "Temperatura Ambiente Promedio (°C)" = "tmed",
                    "Radiación Solar (MJ/m²)" = "sol",
                    "Presión Atmosférica Media (hPa)" = "presMean"
                  ), selected = "body_temp"),
      actionButton("test_button", "Realizar test de Wilcoxon")
    ),
    mainPanel(
      plotOutput("densityPlot"),
      hr(),
      verbatimTextOutput("testResult")
    )
  ),

  actionButton("volver_densidad_movimiento", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
  
)
