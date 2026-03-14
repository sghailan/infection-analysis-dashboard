# Pdiscri.R: interfaz para presentar el análisis discriminante y permitir explorar los resultados por categoría de infección

discri_ui<- fluidPage(
    titlePanel("Análisis Discriminante"),
    
    # Botón para volver
    actionButton("volver_discri_movimiento", "",   
                 align = "left",
                 icon = icon("arrow-left"),   
                 class = "volver-btn"),
    
    # Texto explicativo sobre el análisis discriminante
    div(style = "margin: 20px; padding: 15px; border: 1px solid #ddd; border-radius: 10px; background-color: #f9f9f9;",
        h3("¿En qué consiste el análisis discriminante?"),
        p("El análisis discriminante se ha realizado utilizando un conjunto de variables seleccionadas que permiten clasificar a los pacientes en diferentes grupos según su estado de infección."),
        p("Se ha empleado un modelo de análisis discriminante lineal (LDA) para encontrar las combinaciones óptimas de variables que maximizan la separación entre los grupos."),
        p("Los pacientes han sido clasificados en cuatro categorías: No infectados, Infección 1, Infección 2 e Infección 3."),
        p("Seleccione una de las siguientes opciones para visualizar los resultados por categoría:")
    ),
    
    # Contenedor con los 4 botones grandes
    div(style = "display: flex; flex-direction: column; justify-content: center; align-items: center; height: 70vh; gap: 20px;",
        
        actionButton("no_infectados", "Pacientes no INFECTADOS", 
                     style = "width: 80%; height: 15%; font-size: 24px;"),
        
        actionButton("infeccion_1", "Pacientes con la infección 1", 
                     style = "width: 80%; height: 15%; font-size: 24px;"),
        
        actionButton("infeccion_2", "Pacientes con la infección 2", 
                     style = "width: 80%; height: 15%; font-size: 24px;"),
        
        actionButton("infeccion_3", "Pacientes con la infección 3", 
                     style = "width: 80%; height: 15%; font-size: 24px;")
    )
  )
