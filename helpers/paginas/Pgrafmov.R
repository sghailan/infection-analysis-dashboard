# Pgrafmov.R: interfaz para seleccionar el paciente y las variables fisiológicas a visualizar en el análisis temporal

grafmov_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Visualización Temporal de las Variables Fisiológicas", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  tags$head(tags$style(HTML("
    .grafmov-container {
      display: flex;
      justify-content: center;
      padding-top: 30px;
    }
    .grafmov-box {
      width: 90%;
      max-width: 800px;
      background-color: #f8f9fa;
      padding: 25px;
      border-radius: 10px;
      box-shadow: 0px 4px 8px rgba(0,0,0,0.1);
    }
    .grafmov-title {
      font-weight: bold;
      margin-bottom: 15px;
      font-size: 18px;
    }
  "))),
  
  div(class = "grafmov-container",
      div(class = "grafmov-box",
          
          fluidRow(
            column(12,
                   div(class = "grafmov-title", "Seleccione un paciente:"),
                   selectInput("selected_patient", NULL,
                               choices = sort(as.numeric(as.character(unique(samples_Q$resident_code)))),
                               selected = min(as.numeric(as.character(unique(samples_Q$resident_code)))),
                               width = "100%")
            )
          ),
          
          br(),
          
          fluidRow(
            column(12,
                   div(class = "grafmov-title", "Elige la/s variable/s a analizar:"),
                   checkboxGroupInput("selected_variables", NULL,
                                      choices =    c(
                                        "Temperatura Corporal (°C)" = "body_temp",
                                        "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
                                        "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
                                        "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
                                        "Temperatura Ambiente Promedio (°C)" = "tmed",
                                        "Radiación Solar (MJ/m²)" = "sol",
                                        "Presión Atmosférica Media (hPa)" = "presMean"
                                      ),
                                      inline = FALSE)
            )
          ),
          
          br(),
          
          fluidRow(
            column(12,
                   actionButton("next_button", "Siguiente",
                                style = "width: 100%; padding: 12px; font-size: 16px; background-color: #007bff; color: white; border: none; border-radius: 6px;")
            )
          )
      )
  ),
  
  actionButton("volver_grafmov_eligetiempo", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333;
                        padding: 4px;")
)

