header <- function() {
  tagList(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "/template/www/style.css")
    ),
    div(
        class="header-container",
      a(href="https://app.hsancamillo.it",
        img(class="logo", src = "/template/www/sancamillo_logo_white.png")
      ),
      h1(class="header-title", "San Camillo Shiny Apps")
    ),
    hr()
  )
}

footer <- function() {
  tagList(
    div(
      class="footer",
      "© 2025 IRCCS San Camillo"
    )
  )
}