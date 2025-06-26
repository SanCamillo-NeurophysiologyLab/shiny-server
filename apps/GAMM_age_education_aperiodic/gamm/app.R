#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(png)
library(shiny)
library(shinyWidgets)
library(stringr)

dir('Figures/slope/shiny/')

exp_t_start = str_locate(dir('Figures/slope/shiny/'), '.png')[1:length(dir('Figures/slope/shiny/'))]
off_t_start = str_locate(dir('Figures/offset/shiny/'), '.png')[1:length(dir('Figures/offset/shiny/'))]

exp_slider_values = sort(as.numeric(substr(dir('Figures/slope/shiny/'), 1, exp_t_start-1)))
offset_slider_values = sort(as.numeric(substr(dir('Figures/offset/shiny/'), 1, off_t_start-1)))

# Define UI
# Define UI
ui <- fluidPage(
  titlePanel("Plot Navigator"),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("variable", "Select Variable:", choices = c("exponent", "offset")),
      selectInput("value", "Select Value:", choices = c()) # Initially empty, updated dynamically
    ),
    
    mainPanel(
      imageOutput("plotImage")
    )
  )
)


# Define Server
server <- function(input, output, session) {
  
  observeEvent(input$variable, {
    # Select the appropriate values
    slider_values <- if (input$variable == "exponent") exp_slider_values else offset_slider_values
    
    # Update the selectInput with exact values
    updateSelectInput(session, "value",
                      choices = slider_values,
                      selected = slider_values[1])
  })
  
  output$plotImage <- renderPlot({
    #read file
    ### case SCALP ##

    if(input$variable=="exponent") {

      img<-readPNG(paste("Figures/slope/shiny/", input$value, ".png", sep=""))


    }

    if(input$variable=="offset")  { # this is the case in which PSCxTime or OSCxTime, there is no timepoint

      img<-readPNG(paste("Figures/offset/shiny/", input$value, ".png", sep=""))

    }

    #get size
    h<-dim(img)[1]
    w<-dim(img)[2]

    #open new file for output
    par(pty="s",mar=c(0,0,0,0), xpd=NA, mgp=c(0,0,0), oma=c(0,0,0,0), ann=F)
    plot.new()
    plot.window(0:1, 0:1)

    #fill plot with image
    usr<-par("usr")
    rasterImage(img, usr[1], usr[3], usr[2], usr[4])


  }, height = 600, width = 600)
  
}

# Run the app
shinyApp(ui = ui, server = server)
