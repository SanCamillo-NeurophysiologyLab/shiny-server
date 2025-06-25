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

# source("../../template/template_ui.R")

timepoints = c(-100, -96, -92, -88, -84, -80, -76, -72, -68, -64, -60, -56, 
  -52, -48, -44, -40, -36, -32, -28, -24, -20, -16, -12, -8, -4, 
  0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 
  64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 
  120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 
  172, 176, 180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 
  224, 228, 232, 236, 240, 244, 248, 252, 256, 260, 264, 268, 272, 
  276, 280, 284, 288, 292, 296, 300, 304, 308, 312, 316, 320, 324, 
  328, 332, 336, 340, 344, 348, 352, 356, 360, 364, 368, 372, 376, 
  380, 384, 388, 392, 396, 400, 404, 408, 412, 416, 420, 424, 428, 
  432, 436, 440, 444, 448, 452, 456, 460, 464, 468, 472, 476, 480, 
  484, 488, 492, 496, 500, 504, 508, 512, 516, 520, 524, 528, 532, 
  536, 540, 544, 548, 552, 556, 560, 564, 568, 572, 576, 580, 584, 
  588, 592, 596, 600, 604, 608, 612, 616, 620, 624, 628, 632, 636, 
  640, 644, 648, 652, 656, 660, 664, 668, 672, 676, 680, 684, 688, 
  692, 696, 700, 704, 708, 712, 716, 720, 724, 728, 732, 736, 740, 
  744, 748, 752, 756, 760, 764, 768, 772, 776, 780, 784, 788, 792, 
  796, 800, 804, 808, 812, 816, 820, 824, 828, 832, 836, 840, 844, 
  848, 852, 856, 860, 864, 868, 872, 876, 880, 884, 888, 892, 896, 
  900, 904, 908, 912, 916, 920)



# Define UI for application that draws the ERP layout
ui <- tagList(
  # header(),
  div(id = "content",fluidPage(
   
   # Application title
   titlePanel("ERP-KW-OSC-PSC"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("curr_timepoint",
                     "Timepoint:",
                     min = min(timepoints),
                     max = max(timepoints),
                     value = 400, step = 4),
         
         selectInput("term", "Choose a term to plot:",
                     list(`term` = list("OSCxPSCxTime", "FreqxTime", "LengthxTime"))
         )
      ),
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("ERPresults", width="150%")
      )
   )
)
  ),
# footer()
)

# Define server logic required to draw the ERP layout
server <- function(input, output) {

   
   output$ERPresults <- renderPlot({
     #read file
     ### case SCALP ##
     
     if(input$term=="OSCxPSCxTime") {

        img<-readPNG(paste("Figures/scalp_OSC_PSC/3d_scalp_pvisgam", input$curr_timepoint, ".png", sep=""))
      
     
     }
     
     if(input$term=="FreqxTime")  { # this is the case in which PSCxTime or OSCxTime, there is no timepoint
       
       img<-readPNG(paste("Figures/scalp_FREQ/full_model_scalp_pvisgam.png", sep=""))
       
     }
     
     if(input$term=="LengthxTime")  { # this is the case in which PSCxTime or OSCxTime, there is no timepoint
       
       img<-readPNG(paste("Figures/scalp_LENGTH/full_model_scalp_pvisgam.png", sep=""))
       
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

# Run the application 
shinyApp(ui = ui, server = server)

