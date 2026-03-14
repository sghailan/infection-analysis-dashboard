# Iregistro.R: gestiona la lógica del registro de nuevos usuarios en la aplicación.
# Comprueba que los datos introducidos sean válidos, verifica si el usuario ya
# existe, crea la cuenta en el archivo de usuarios y redirige al inicio de sesión
# cuando el proceso finaliza correctamente. También controla el botón para volver
# a la pantalla de login.

# Crear cuenta
observeEvent(input$crear_cuenta, {
  #requiere que introduzcas todo esto antes de empezar a jugar
  req(input$nuevo_usuario, input$nueva_contrasena, input$repetir_contrasena)
  
  #falla desde el principio y no te coincide
  if (input$nueva_contrasena != input$repetir_contrasena) {
    showModal(modalDialog(title = "Error", "Las contraseñas no coinciden", easyClose = TRUE,
                          footer = modalButton("Cerrar") ))
    return()
  }
  ##si hay ese archivo, comprueba usuarios en el archivo y me los lees
  if (file.exists(usuarios_file)) {
    usuarios <- read.csv(usuarios_file, stringsAsFactors = FALSE)
  } else {
    # si no hay me lo creas nuevo y lo guardas
    usuarios <- data.frame(usuario = character(), contrasena = character())
  }
  
  # si ya existe el usuario en los usuarios que lee
  if (input$nuevo_usuario %in% usuarios$usuario) {
    showModal(modalDialog(title = "Error", "Este usuario ya existe", easyClose = TRUE,
                          footer = modalButton("Cerrar") ))
    return()
  }
  
  ## lo meto directamente
  nuevo <- data.frame(usuario = input$nuevo_usuario, contrasena = input$nueva_contrasena)
  write.table(nuevo, file = usuarios_file, append = TRUE, sep = ",", row.names = FALSE,
              col.names = !file.exists(usuarios_file))
  
  showModal(modalDialog(title = "Éxito", "Cuenta creada correctamente. Ahora puedes iniciar sesión.", easyClose = TRUE,
                        footer = modalButton("Cerrar") ))
  valores$pagina <- "login"
})

# Volver al login
observeEvent(input$volver_login, {
  valores$pagina <- "login"
})