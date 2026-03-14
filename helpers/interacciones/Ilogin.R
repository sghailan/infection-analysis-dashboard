# Ilogin.R: gestiona la lógica del inicio de sesión de la aplicación.
# Comprueba si el usuario existe, valida la contraseña introducida y
# redirige a la página principal cuando el acceso es correcto. Además,
# controla el paso al formulario de registro y la entrada como invitado.

# ¿Cúando doy a iniciar sesión qué pasa?
observeEvent(input$login_button, {
  # si existe mi documento ya la comprueba
  if (file.exists(usuarios_file)) {
    usuarios <- read.csv(usuarios_file, stringsAsFactors = FALSE)
    ## el usuario que introduces esta entre los usuarios del archivo
    if (input$usuario %in% usuarios$usuario) {
      ## guardo la contraseña que corresponde a ese usuario en una nueva variable 
      contrasena_guardada <- usuarios$contrasena[usuarios$usuario == input$usuario]
      ## si la contraseña coinciden con la introducida
      if (input$contrasena == contrasena_guardada) {
        valores$pagina <- "inicio"
        valores$usuario_correcto <- TRUE
      } else {
        ## contraseña porque es verdad que el usuario existe
        showModal(modalDialog(title = "Error", "Contraseña incorrecta.", easyClose = TRUE,
                              footer = modalButton("Cerrar") ))
      }
    } else {
    ## no existe ni el usuario
      showModal(modalDialog(title = "Error", "El usuario no existe.", easyClose = TRUE,
                            footer = modalButton("Cerrar") ))
    }

    # esta vacio todo, vas a registrarte creandose automaticamente un archivo con usuario y contrasena
    } else {
    showModal(modalDialog(title = "Error", "No hay usuarios registrados aún.", easyClose = TRUE,
                          footer = modalButton("Cerrar") ))
  }
})

# Ir al formulario de registro(quiero crear cuenta, me voy a otra pagina)
observeEvent(input$registro_button, {
  valores$pagina <- "registro"
})


observeEvent(input$guest_button, {
  valores$pagina <- "inicio"
  showNotification("Has entrado sin iniciar sesión", type = "message")
})
