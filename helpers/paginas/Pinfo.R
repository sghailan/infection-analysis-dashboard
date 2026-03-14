# Pinfo.R: interfaz para consultar la información de cada paciente, visualizar sus variables y explorar detalles de infección

info_ui <- fluidPage(
  useShinyjs(),
  
  div(
    style = "text-align: center; margin-bottom: 20px;",
    h2("Información Pacientes", style = "font-family: 'Roboto', sans-serif; font-weight: 400; font-size: 28px;")
  ),
  
    # Estilos CSS para el efecto borroso y la posición del gráfico en la esquina inferior izquierda
    tags$head(
      tags$style(HTML("
    .blur-effect {
      filter: blur(8px);
      transition: filter 0.5s ease-in-out;
      cursor: pointer;
    }
    .blur-effect:hover {
      filter: blur(0px);
    }
    .floating-graph {
      position: fixed;
      bottom: 10px;
      left: 10px;
      width: 300px;
      height: auto;
      background-color: rgba(255, 255, 255, 0.8);
      padding: 3px;
      border-radius: 8px;
      box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
      z-index: 1000;
    }
    
    #chat-box {
    font-family: 'Roboto', serif;
  }
  "))
    ),

    sidebarLayout(
      sidebarPanel(
        # Selector de paciente
        selectInput("selected_patient", "Seleccionar Paciente:",
                    choices = sort(as.numeric(as.character(unique(samples_Q$resident_code)))), 
                    selected = min(as.numeric(as.character(unique(samples_Q$resident_code))))),
        
        # Selector de variable a graficar
        selectInput("selected_variable", "Seleccionar Variable:",
                    choices = c(
                      "Temperatura Corporal (°C)" = "body_temp",
                      "Saturación de Oxígeno Mínima (%)" = "SPO2.Min",
                      "Frecuencia Cardíaca Promedio (lat/min)" = "BPM.Avg",
                      "Actividad Electrodérmica Promedio (μS)" = "EDA.Avg",
                      "Temperatura Ambiente Promedio (°C)" = "tmed",
                      "Radiación Solar (MJ/m²)" = "sol",
                      "Presión Atmosférica Media (hPa)" = "presMean"
                    ),
                    selected = "body_temp"
        ),
        
        # Selector para resaltar una infección específica
        uiOutput("infection_selector"),
        
        # Botones de información debajo de los filtros
        actionButton("institution_button", 
                     label = tagList(icon("building"), "Institución"),
                     style = "margin-bottom: 5px; width: 100%; text-align: left; font-weight: bold;"),
        actionButton("gender_button", 
                     label = tagList(icon("venus-mars"), "Sexo"),
                     style = "margin-bottom: 5px; width: 100%; text-align: left; font-weight: bold;"),
        actionButton("age_button", 
                     label = tagList(icon("birthday-cake"), "Edad"),
                     style = "margin-bottom: 5px; width: 100%; text-align: left; font-weight: bold;"),
        actionButton("berthel_button", 
                     label = tagList(icon("walking"), "Índice Barthel"),
                     style = "margin-bottom: 5px; width: 100%; text-align: left; font-weight: bold;")
        
      ),
      
      mainPanel(
        div(
          style = "display: flex; justify-content: center; align-items: center; margin-bottom: 10px;",
          div(
            style = "text-align: center;",
            selectInput("selected_grafico", "Visualización de datos:",
                        choices = c("Datos Originales" = "Original",
                                    "Datos Interpolados" = "Interpolado"),
                        selected = "Original", width = "300px")
            
          )
        ),
        plotlyOutput("plot"),
        
        # Botón de ayuda sobre el gráfico
        tags$div(
          style = "position: absolute; top: 70px; right: 40px; z-index: 1000;",
          actionButton("toggle_button", label = NULL, icon = icon("circle-question"),
                       style = "border: none; background-color: transparent; font-size: 22px; color: #007bff;")
        ),
        
        br(),
        
        bsCollapse(id = "collapse_infecciones", open = NULL,
                   bsCollapsePanel(
                     "Ver detalles de infección seleccionada ",
                     tableOutput("infection_table"),
                     style = "default"
                   )
        )
      )
    ),
    
    # BOTÓN flotante estilo chat en esquina inferior derecha
    tags$div(
      id = "chat-launcher",
      style = "position: fixed; bottom: 20px; right: 20px; z-index: 9999;",
      actionButton("abrir_chat", label = NULL, icon = icon("comments"),
                   style = "border-radius: 50%; width: 60px; height: 60px;
                        background-color: #007bff; color: white;
                        box-shadow: 0 4px 8px rgba(0,0,0,0.2);")
    ),
    
    # CUADRO DE CHAT oculto inicialmente
    tags$div(
      id = "chat-box",
      style = "display: none; position: fixed; bottom: 90px; right: 20px;
           width: 350px; max-height: 400px; background-color: white;
           border: 1px solid #ccc; border-radius: 8px; padding: 10px;
           box-shadow: 0 4px 12px rgba(0,0,0,0.3); overflow-y: auto;
           z-index: 9999;",
      
      # Cabecera del chat
      tags$div(
        style = "font-weight: bold; margin-bottom: 10px;"," Asistente de Análisis"
      ),
      
      # Mensajes dinámicos
      uiOutput("chat_content"),
      
      # Botones de acción dentro del chat
    
      tags$div(
        style = "margin-top: 10px; display: flex; gap: 8px; flex-wrap: wrap; justify-content: center;",
        
        # Cada botón va en su contenedor para que se respete tamaño y espaciado
        tags$div(style = "min-width: 160px;",
                 actionButton("boton_resumen", "Perfil clínico",
                              class = "btn btn-light border rounded-pill shadow-sm w-100")),
        
        tags$div(style = "min-width: 160px;",
                 actionButton("boton_tipos_infeccion", "Tipos de infección",
                              class = "btn btn-light border rounded-pill shadow-sm w-100")),
        
        tags$div(style = "min-width: 160px;",
                 actionButton("mostrar_selector_fecha", "Ver datos de muestra",
                              class = "btn btn-light border rounded-pill shadow-sm w-100")),
        
        # Botón de papelera más pequeño a la derecha
        tags$div(style = "flex: 0 0 auto; align-self: flex-start;",
                 actionButton(
                   "boton_limpiar_chat",
                   label = NULL,
                   icon = icon("trash-alt"),
                   style = "
               background-color: transparent;
               border: none;
               color: #888;
               font-size: 18px;
               margin-top: 2px;"
                 )),
        
        # Selector de fecha dinámico debajo
        uiOutput("selector_fecha_ui")
      )
      
    ),
    
    
    actionButton("volver_info_inicio", label = NULL,
                 icon = icon("chevron-left"),
                 style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
    
)


