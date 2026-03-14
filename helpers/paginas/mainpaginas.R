# mainpaginas.R: gestiona la navegación de la app cargando dinámicamente la UI de cada página según la sección seleccionada

output$main_ui <- renderUI({
if (valores$pagina == "login") {
      source("helpers/paginas/Plogin.R", local = TRUE)
      login_ui
      
} else if (valores$pagina == "registro") {
      source("helpers/paginas/Pregistro.R", local = TRUE)
      registro_ui
    }
  
 else if (valores$pagina == "inicio") {
   source("helpers/paginas/Pinicio.R", local = TRUE)
   inicio_ui
 } 
  else if (valores$pagina == "resultados") {
    source("helpers/paginas/Presultados.R", local = TRUE)
    resultados_ui
  } 
  else if (valores$pagina == "estudio") {
    source("helpers/paginas/Pestudio.R", local = TRUE)
    estudio_ui
  } 
  

  else if (valores$pagina == "movimiento") {
    source("helpers/paginas/Pmovimiento.R", local = TRUE)
    movimiento_ui
  }
  
  else if (valores$pagina == "eligetiempo") {
    source("helpers/paginas/Peligetiempo.R", local = TRUE)
    eligetiempo_ui
  } 
  
  else if(valores$pagina == "grafmov"){
    source("helpers/paginas/Pgrafmov.R", local = TRUE)
    grafmov_ui
  } 
  
  else if (valores$pagina == "grafico") {
    source("helpers/paginas/Pgrafico.R", local = TRUE)
    grafico_ui
  }
  
  else if(valores$pagina == "grafmov2"){
    source("helpers/paginas/Pgrafmov2.R", local = TRUE)
    grafmov2_ui
  } 
  
  else if(valores$pagina == "outlier"){
    source("helpers/paginas/Poutlier.R", local = TRUE)
    outlier_ui
  } 
  
  else if(valores$pagina == "densidad"){
    source("helpers/paginas/Pdensidad.R", local = TRUE)
    densidad_ui
  } 
  
  else if(valores$pagina == "boxplot"){
    source("helpers/paginas/Pboxplot.R", local = TRUE)
    boxplot_ui
  } 
  
  
  else if (valores$pagina == "discri") {
    source("helpers/paginas/Pdiscri.R", local = TRUE)
    discri_ui
}
  else if(valores$pagina == "grafos"){
    source("helpers/paginas/Pgrafos.R", local = TRUE)
    grafos_ui
  }
  
  else if (valores$pagina == "interpolacion") {
    source("helpers/paginas/Pinterpolacion.R", local = TRUE)
    interpolacion_ui
  }
  
  else if (valores$pagina == "info") {
    source("helpers/paginas/Pinfo.R", local = TRUE)
    info_ui
  }
  
  
  else if (valores$pagina == "eligeopcionpanel") {
    source("helpers/paginas/Peligeopcionpanel.R", local = TRUE)
    eligeopcionpanel_ui
  }
  
  else if (valores$pagina == "ajustar_modelo") {
    source("helpers/paginas/Pajustarmodelo.R", local = TRUE)
    ajustarmodelo_ui
  }
  
  else if (valores$pagina == "variable_binaria") {
    source("helpers/paginas/Pvariablebinaria.R", local = TRUE)
    variablebinaria_ui
  }
  
  else if (valores$pagina == "variable_ordinal") {
    source("helpers/paginas/Pvariableordinal.R", local = TRUE)
    variableordinal_ui
  }
  
  else if (valores$pagina == "variable_multinomial") {
    source("helpers/paginas/Pvariablemultinomial.R", local = TRUE)
    variablemultinomial_ui
  }
  
  else if (valores$pagina == "comparar_modelo") {
    source("helpers/paginas/Pcompararmodelo.R", local = TRUE)
    compararmodelo_ui
  }
  
  else if (valores$pagina == "calendario_1") {
    source("helpers/paginas/Pcalendario.R", local = TRUE)
    calendario_ui
  }
  
  else if (valores$pagina == "interactivos") {
    source("helpers/paginas/Pinteractivos.R", local = TRUE)
    interactivos_ui
  }
  
  else if (valores$pagina == "tabla_cruzada") {
    source("helpers/paginas/Ptablacruzada.R", local = TRUE)
    tabla_cruzada_ui
  }
  else if (valores$pagina == "prediccion") {
    source("helpers/paginas/Pprediccion.R", local = TRUE)
    prediccion_ui
  }
  
})
