# ui.R: define la interfaz principal de la app y el contenedor dinámico donde se renderizan las páginas

fluidPage(
  tags$style(HTML("body { font-family: 'Roboto', sans-serif; }")),
  
  
  uiOutput("main_ui"),
)