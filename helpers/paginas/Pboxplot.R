# Pboxplot.R: interfaz para visualizar boxplots de variables fisiológicas y detectar posibles outliers

boxplot_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Boxplot para detección de outliers", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("var_sel", "Selecciona variable:", choices = c(
        "Temperatura Corporal (°C)" = "body_temp",
        "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
        "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
        "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
        "Temperatura Ambiente Promedio (°C)" = "tmed",
        "Radiación Solar (MJ/m²)" = "sol",
        "Presión Atmosférica Media (hPa)" = "presMean"
      ))
    ),
    
    mainPanel(
      plotlyOutput("plot_var"),
      br()
    )
  ),

  actionButton("volver_boxplot_outlier", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333; padding: 4px;")
  
)
