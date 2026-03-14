# Pcalendario.R: interfaz para visualizar un calendario interactivo con las infecciones registradas por día

calendario_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Calendario Infecciones", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  div(style = "display: flex; justify-content: center; margin: 20px 0;",
      div(
        style = "text-align: center;",
        selectInput("anio", "Selecciona el año:",
                    choices = c(2018, 2019),
                    selected = 2018,
                    width = "200px")
      )
  ),
  
  br(),
  
  uiOutput("grid_meses"),
  
  uiOutput("detalle_dia_global"),
  
  br(), br(),
  
  actionButton("volver_calendario_eligetiempo", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                        border: none; background: none;
                        font-size: 24px; color: #333; padding: 4px;")
)

