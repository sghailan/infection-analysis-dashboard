# Ptablacruzada.R: interfaz para generar tablas cruzadas entre variables de los datasets de muestras o diagnósticos

tabla_cruzada_ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .titulo-principal {
        text-align: center;
        font-family: 'Roboto', sans-serif;
        font-weight: 500;
        font-size: 28px;
        color: #333;
        margin-top: 20px;
        margin-bottom: 30px;
      }
      .panel-lateral {
        font-size: 14px;
      }
      .boton-volver {
        position: fixed;
        bottom: 20px;
        left: 20px;
        border: none;
        background: none;
        font-size: 24px;
        color: #333;
        padding: 4px;
      }
    "))
  ),
  
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Tabla cruzada entre variables", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  sidebarLayout(
    sidebarPanel(
      class = "panel-lateral",
      
      radioButtons("dataset", " Selecciona el conjunto de datos:",
                   choices = c("Muestras" = "samples", "Diagnósticos" = "diagnostics"),
                   selected = "samples"),
      
      uiOutput("select_var1"),
      uiOutput("select_var2")
    ),
    
    mainPanel(
      tags$div(
        style = "margin-bottom: 20px; font-size: 15px; color: #555;",
        textOutput("explicacion")
      ),
      DTOutput("tabla_cruzada")
    )
  ),
  
  actionButton("volver_tablacruzada_movimiento", label = NULL,
               icon = icon("chevron-left"),
               class = "boton-volver")
)




