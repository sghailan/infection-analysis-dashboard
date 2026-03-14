# Pregistro.R: interfaz para que un nuevo usuario pueda registrarse en la aplicación

registro_ui <- fluidPage(
  titlePanel("Crear cuenta"),
  tags$head(tags$style(HTML("                 
    .login-container {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 80vh;
    }
    .login-box {
        width: 300px;
        padding: 20px;
        border-radius: 10px;
        background-color: #f8f9fa;
        box-shadow: 0px 4px 6px rgba(0,0,0,0.1);
    }"))),
  div(class = "login-container",
      div(class = "login-box",
          h3("Registro de nuevo usuario", align = "center"),
          textInput("nuevo_usuario", "Nuevo usuario:"),
          passwordInput("nueva_contrasena", "Contraseña:"),
          passwordInput("repetir_contrasena", "Repetir contraseña:"),
          actionButton("crear_cuenta", "Crear cuenta",
                       style = "width: 100%; padding: 10px; font-size: 16px; margin-top: 10px; background-color: #28a745; color: white;"),
          actionButton("volver_login", "Volver",
                       style = "width: 100%; padding: 10px; font-size: 14px; margin-top: 10px; background-color: #6c757d; color: white;")
      )
  )
)