# Pestudio.R: interfaz para mostrar el informe de análisis exploratorio embebido en la aplicación

estudio_ui <- fluidPage(
  
  # Botón volver fijo arriba
  fluidRow(
    column(12,
           div(style = "margin-top: 10px; margin-left: 10px;",
               
               actionButton("volver_estudio_resultados", label = NULL,
                            icon = icon("chevron-left"),
                            style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;"))           
           
           
    )
  ),
  
  # Contenido largo: el informe
  tags$iframe(
    src = "AnalisisExploratorioDatosPrueba.html",
    width = "100%",
    height = "1200px",
    frameborder = 0
  )
)
