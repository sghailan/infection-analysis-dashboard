# server.R: define la lógica del servidor de la app Shiny y carga los módulos de interacción y navegación

server <- function(input, output, session) {
  
    valores <- reactiveValues(pagina = "login", usuario_correcto = FALSE)
    usuarios_file <- "usuarios.csv"
  
    source("helpers/paginas/mainpaginas.R", local = TRUE)
    
    source("helpers/navegacion.R", local = TRUE)
    
    source("helpers/interacciones/Ilogin.R", local = TRUE)
    
    source("helpers/interacciones/Iregistro.R", local = TRUE)
    
    source("helpers/interacciones/Iinicio.R", local = TRUE)
    
    source("helpers/interacciones/Iinfo/Iinfomain.R", local = TRUE)
    
    source("helpers/interacciones/Iinterpolacion.R", local = TRUE)
    
    source("helpers/interacciones/Imovimiento.R", local = TRUE)
    
    source("helpers/interacciones/Ieligetiempo.R", local = TRUE)
    
    source("helpers/interacciones/Igrafmov2.R", local = TRUE)
    
    source("helpers/interacciones/Igrafmov.R", local = TRUE)
    
    source("helpers/interacciones/Igrafico.R", local = TRUE)
    
    source("helpers/interacciones/Ioutlier.R", local = TRUE)
    
    source("helpers/interacciones/Idensidad.R", local = TRUE)
    
    source("helpers/interacciones/Iboxplot.R", local = TRUE)
    
    source("helpers/interacciones/Igrafos.R", local = TRUE)
    
    source("helpers/interacciones/Idiscri.R", local = TRUE)
    
    source("helpers/interacciones/Ieligeopcionpanel.R", local = TRUE)
    
    source("helpers/interacciones/Iajustarmodelo.R", local = TRUE)
    
    source("helpers/interacciones/Ivariablebinaria.R", local = TRUE)
    
    source("helpers/interacciones/Ivariableordinal.R", local = TRUE)
    
    source("helpers/interacciones/Ivariablemultinomial.R", local = TRUE)
    
    source("helpers/interacciones/Icompararmodelo.R", local = TRUE)
    
    source("helpers/interacciones/Icalendario.R", local = TRUE)
    
    source("helpers/interacciones/Iinteractivos.R", local = TRUE)
    
    source("helpers/interacciones/Itablacruzada.R", local = TRUE)
    
    source("helpers/interacciones/Iprediccion.R", local = TRUE)
    
    source("helpers/interacciones/Iresultados.R", local = TRUE)
    
    source("helpers/interacciones/Iestudio.R", local = TRUE)
}

