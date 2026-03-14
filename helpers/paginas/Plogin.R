# Plogin.R: interfaz de inicio de sesión para acceder a la aplicación o entrar como invitado

login_ui <- fluidPage(
  titlePanel(""),
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
  fluidRow(
    column(12, align = "center",
           div(class = "login-container",
               div(class = "login-box",
                   h3("Inicio de Sesión", align = "center"),
                   textInput("usuario", "Usuario:", ""),
                   passwordInput("contrasena", "Contraseña:", ""),
                   actionButton("login_button", "Ingresar",
                                style = "width: 100%; padding: 10px; font-size: 16px; margin-top: 10px;"),
                   actionButton("registro_button", "Crear cuenta",
                                style = "width: 100%; padding: 10px; font-size: 14px; margin-top: 10px; background-color: #6c757d; color: white;"),
                   tags$div(
                     actionButton("guest_button", "Entrar sin iniciar sesión", 
                                  style = "width: 100%; margin-top: 10px; background-color: transparent; color: blue; border: none; text-decoration: underline; cursor: pointer;")
                   )
                   
               )
           )
    )
  )
)
