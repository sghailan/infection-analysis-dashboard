# Iinterpolacion.R: implementa la lógica de la página que explica el proceso de
# interpolación utilizado en el estudio. Muestra información descriptiva sobre
# los métodos aplicados, estadísticas básicas de las muestras sin infección y
# ejemplos de la estructura de los datos. También gestiona la navegación de
# regreso a la página principal de la aplicación.

# Total de infecciones
output$total_infecciones <- renderPrint({
  dim(samples_Q %>% filter(Infeccion != 0))[1]
})

output$explicacion_caso1 <- renderUI({
  tags$div(
    tags$p(strong("¿Por qué interpolación lineal?")),
    tags$p("La interpolación lineal se utiliza cuando se parte de puntos de datos conocidos y se busca estimar valores intermedios bajo la suposición de un cambio progresivo y constante entre ellos."),
    tags$p("Este tipo de interpolación es ideal para pacientes sin infección porque se espera que su fisiología sea estable, sin alteraciones bruscas."),
    tags$p(em("Justificación matemática: La interpolación lineal asume que el cambio entre observaciones es constante y directo, por lo que no introduce curvaturas ni suposiciones de comportamiento clínico complejo."))
  )
})

output$explicacion_caso2 <- renderUI({
  tags$div(
    tags$p(strong("¿Por qué splines de segundo grado?")),
    tags$p("En el caso de las muestras con infección, se espera una mayor variabilidad fisiológica. Por tanto, se necesita una técnica que no imponga una transición lineal, sino que permita cambios suaves, progresivos y no necesariamente constantes."),
    tags$p("Se utilizó interpolación por splines cuadráticos (de segundo grado), que ajustan una curva a los puntos disponibles y permiten estimar de forma más realista los valores perdidos."),
    tags$p(em("Justificación matemática: Los splines permiten unir múltiples polinomios de segundo grado de manera suave (continuidad de primer orden), generando una curva que se adapta mejor a comportamientos no lineales."))
  )
})

# Explicación del caso 2 (puedes modificar el contenido si necesitas algo más detallado)
output$explicacion_caso2 <- renderText({
  "La interpolación cuadrática (o splines de segundo grado) se elige porque proporciona una curva suave entre los puntos de datos, evitando cambios bruscos y permitiendo un mejor ajuste en situaciones donde los valores pueden tener comportamientos no lineales."
})

# Promedios de las variables en muestras sin infección
output$promedios_caso1 <- renderTable({
  print(promedios_caso1)
})

# Valores mínimos de las variables en muestras sin infección
output$minimos_caso1 <- renderTable({
  print(minimos_caso1)
})

# Mostrar la primera fila de samples_Q como tabla
output$ejemplo_muestra <- renderTable({
  head(samples_Q, 1)
})

observeEvent(input$volver_interexpli_info, {
  valores$pagina <- "inicio"
})