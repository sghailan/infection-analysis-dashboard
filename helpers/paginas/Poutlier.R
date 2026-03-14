# Poutlier.R: interfaz para acceder a las herramientas de detección de valores atípicos en los datos

outlier_ui<- fluidPage(
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
                   actionButton("boxplot_button", "Boxplot para detección de outliers", 
                                style = "width: 100%; padding: 10px; font-size: 16px;"),
                   br(), br(),
                   actionButton("modelo_outlier_button", "Modelo de detección (Próximamente)", 
                                style = "width: 100%; padding: 10px; font-size: 16px;",  disabled = TRUE),
                   
               )
           )
    )
  ),

  
  actionButton("volver_outlier_movimiento", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
  
)