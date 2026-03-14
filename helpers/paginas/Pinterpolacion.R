# Pinterpolacion.R: interfaz que explica el procedimiento de interpolación aplicado a los datos del estudio

interpolacion_ui <- fluidPage(
  div(
    style = "text-align: center; margin-bottom: 30px;",
    h2("¿Cómo se ha realizado la interpolación en nuestro estudio?", 
       style = "font-family: 'Roboto', sans-serif; font-weight: 500; font-size: 30px;")
  ),
  
  div(
    style = "margin: 20px auto; max-width: 1000px; padding: 25px; border: 1px solid #ccc; border-radius: 10px; background-color: #fdfdfd;",
    
    h3("¿Por qué ha sido necesaria la interpolación?"),
    p("En el análisis longitudinal de muestras clínicas, nos encontramos con dos problemas clave que limitan la interpretación completa de los datos:"),
    
    tags$ul(
      tags$li(strong("1. Vacíos temporales entre muestras:"),
              " Algunos pacientes presentan espacios de hasta varios meses sin registro de muestras, dificultando el análisis temporal continuo. Para solucionarlo, se generan nuevas muestras cada 30 días sin solaparse con las fechas originales, y se interpolan las variables fisiológicas relevantes."),
      
      tags$li(strong("2. Infecciones sin datos fisiológicos:"),
              " Muchas infecciones carecen de variables como temperatura corporal, saturación de oxígeno, frecuencia cardíaca, entre otras. Estas son esenciales para analizar el contexto de las infecciones, por lo que se requiere estimar sus valores mediante interpolación.")
    ),
    
    br(),
    h3("¿Cuántas infecciones están afectadas?"),
    p("Total de infecciones registradas:"),
    verbatimTextOutput("total_infecciones"),
    p("De estas, solo 38 tienen datos fisiológicos registrados. Las restantes (108) fueron completadas mediante interpolación."),
    
    hr(),
    h3("Métodos de interpolación utilizados"),
    tags$ul(
      tags$li(strong("Caso 1 - Interpolación lineal (para muestras sin infección):"),
              " Se aplicó interpolación lineal para generar valores intermedios entre mediciones reales, ya que se espera un cambio progresivo entre observaciones sin eventos clínicos bruscos."),
      p(em("Justificación matemática:"),
        "La interpolación lineal asume que el cambio entre dos puntos consecutivos es constante, ideal para periodos sin infecciones donde el comportamiento fisiológico tiende a ser estable."),
     
      
      tags$li(strong("Caso 2 - Interpolación por splines de segundo grado (para muestras con infección):"),
              " Esta técnica proporciona una curva suave ajustada a los valores conocidos, lo que permite una estimación realista incluso en situaciones clínicas más dinámicas como las infecciones."),
      p(em("Justificación matemática:"),
        "Los splines cuadráticos permiten una interpolación no lineal que se ajusta mejor a la evolución esperada de las variables fisiológicas en presencia de infecciones."),
      
    ),
    
    hr(),
    h3("Control de calidad en la interpolación"),
    p("Para evitar estimaciones fisiológicamente imposibles (como una temperatura corporal de 60°C), se establecieron límites para cada variable interpolada."),
    
    tags$ul(
      tags$li(strong("Caso 1 - Límites generales para pacientes sin infección:")),
      p("Se utilizaron los promedios y mínimos observados en pacientes sin infección como límites razonables."),
     
      
      tags$li(strong("Caso 2 - Límites por tipo de infección:")),
      p("Para cada tipo de infección (1, 2 o 3), se definieron rangos específicos basados en estadísticas propias del grupo (cuartiles y medias). Esto garantiza que los valores interpolados sean consistentes con el perfil fisiológico observado en ese tipo de infección.")
    ),
    
    hr(),
    
    
    h3("Normas generales en el proceso"),
    tags$ul(
      tags$li("No se interpolan muestras que ya contengan datos reales registrados por el personal médico."),
      tags$li("Las nuevas muestras generadas cada 30 días se etiquetan como sin infección y su origen se identifica visualmente en la app."),
      tags$li("Se recalculan variables derivadas como el 'lapse' y el tiempo hasta la siguiente muestra ('siguiente2') para mantener coherencia temporal en el análisis.")
    )
  ),
  
  actionButton("volver_interexpli_info", label = NULL,
               icon = icon("chevron-left"),
               style = "position: fixed; bottom: 20px; left: 20px;
                      border: none; background: none;
                      font-size: 24px; color: #333;
                      padding: 4px;")
)


