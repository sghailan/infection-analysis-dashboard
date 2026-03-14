# Pajustarmodelo.R: define la interfaz donde el usuario selecciona el tipo de variable respuesta para el ajuste de modelos

ajustarmodelo_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Selección de variable respuesta", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
  tags$head(tags$style(HTML("
    .inicio-container {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 80vh;
        flex-direction: column;
    }
    .inicio-box {
        width: 400px;
        padding: 20px;
        border-radius: 10px;
        background-color: #f8f9fa;
        box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
        text-align: center;
    }
    .volver-btn {
        margin: 20px;
    }
  "))),
  
  fluidRow(
    column(12, align = "center",
           div(class = "inicio-container",
               div(class = "inicio-box",
                   
                   actionButton("variable_binaria", "Infección Sí / No", 
                                style = "width: 100%; padding: 10px; font-size: 16px;"),
                   
                   br(), br(),
                   
                   actionButton("variable_ordinal", "Tipo de Infección", 
                                style = "width: 100%; padding: 10px; font-size: 16px;")
                   
                   
               )
           )
    )
  ),

  actionButton("volver_ajustar_modelo_eligeopcionpanel", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
)

