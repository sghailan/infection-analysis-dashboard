# Pinicio.R: interfaz de la página principal desde la que se accede a las distintas secciones de la aplicación

inicio_ui <- fluidPage(
  div(style = "text-align: center; margin-bottom: 20px;",
      h1("Plataforma de Seguimiento Clínico")
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
        "))),
    
    fluidRow(
      column(12, align = "center",
             div(class = "inicio-container",
                 div(class = "inicio-box",
                     actionButton("evolucion_button", " Información Pacientes", 
                                  style = "width: 100%; padding: 10px; font-size: 16px;"),
                     
                     br(), br(),
                     actionButton("EDA_button", " Análisis Exploratorio", 
                                  style = "width: 100%; padding: 10px; font-size: 16px;"),
                     
                     br(), br(),
                     actionButton("interpolacion", "Interpolación", 
                                  style = "width: 100%; padding: 10px; font-size: 16px;"),
                     
                     br(), br(),
                     actionButton("panel_button", " Datos de Panel", 
                                  style = "width: 100%; padding: 10px; font-size: 16px;"),
                     
                     
                    
                     br(), br(),
                     
                 )
             )
      )
    )
  )
  
  

  
  