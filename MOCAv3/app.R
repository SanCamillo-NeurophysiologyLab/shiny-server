#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
rm(list=ls())

load("R_data/CRI_MOCA_data_mods.RData")
source("R_functions/CGcut.off.multi.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("MOCA normative data and cut-offs (CRIq)"),
   
   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
         numericInput("age", "Age:", 30, min = 1, max = 100),
         numericInput("education", "Education:", 18, min = 1, max = 100),
         numericInput("cri", "CRI:", 100, min = 70, max = 170),
         selectInput("sex", "Sex", "Female", choices=c("Female", "Male")),
         numericInput("obs_moca", "Observed MoCA score:", 20, min=0, max=30),
         HTML("Normative data for MOCA considering Age, Education, CRI, and Sex. <br>
         <b>If CRI values are not available, set CRI to 999</b>")
      ),
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot"),
         "This shiny app is associated to the paper Montemurro et al., (submitted), with title 'Cognitive reserve estimated with a life experience questionnaire outperforms education in predicting performance on MoCA: Italian normative data.'" ,
         "- Insert the demographic variable of the particiant and the observed MoCA score in the leftmost Bar",
         "- Check the results in the leftmost panels. The observed p is in red. P-value is calculated with Crawford & Garthwaite (2006) method.",
         "",
         #HTML("<br><br><b>IMPORTANT</b>: Set CRI to 999, if only Age, Education and Sex are available.")
         
         
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
     
     
      # convert sex to 1 0 (as from mod_7)
      curr_sex = ifelse(input$sex=="Female", 1, 0);
      # calculate predicted value of Moca considering centering
      
      CRI_mean = mean(dat$CRI)
      Edu_mean = mean(dat$Education)
      
      
      ### CASE 1 : CRI data are available
      if (input$cri!=999){
      
      pred_moca = predict(mod_7, newdata = list(Sex.n = curr_sex, Age = input$age, Educationcentered =  input$education - Edu_mean, CRIcentered = input$cri-CRI_mean, Educationcentered_2 = (input$education-Edu_mean)^2, CRIcentered_2 = (input$cri-CRI_mean)^2))
      
      
      
      res = CGcut.off.multi(controls_data = dat[,c("Sex.n", "Age", "Educationcentered",  "CRIcentered", "Educationcentered_2", "CRIcentered_2")],
                            model = mod_7,
                            preds = c(curr_sex, input$age, (input$education-Edu_mean), (input$cri-CRI_mean), (input$education-Edu_mean)^2, (input$cri-CRI_mean)^2),
                            Yobs = input$obs_moca, upper=F)
      
      res_crit = CGcut.off.multi(controls_data = dat[,c("Sex.n", "Age", "Educationcentered",  "CRIcentered", "Educationcentered_2", "CRIcentered_2")],
                                 model = mod_7,
                                 preds = c(curr_sex, input$age, c(input$education-Edu_mean), c(input$cri-CRI_mean), c(input$education-Edu_mean)^2, c(input$cri-CRI_mean)^2)
                                 , upper=F
                                 )
      
      }
      
      
      ### CASE 2 : CRI data are not available
      if (input$cri==999){
        
        pred_moca = predict(mod_6, newdata = list(Sex.n = curr_sex, Age = input$age, Educationcentered =  input$education - Edu_mean,  Educationcentered_2 = (input$education-Edu_mean)^2))
        
        
        res = CGcut.off.multi(controls_data = dat[,c("Sex.n", "Age", "Educationcentered", "Educationcentered_2")],
                              model = mod_6,
                              preds = c(curr_sex, input$age, c(input$education-Edu_mean), c(input$education-Edu_mean)^2),
                              Yobs = input$obs_moca, upper=F)
        
        res_crit = CGcut.off.multi(controls_data = dat[,c("Sex.n", "Age", "Educationcentered", "Educationcentered_2")],
                                   model = mod_6,
                                   preds = c(curr_sex, input$age, c(input$education-Edu_mean), c(input$education-Edu_mean)^2), upper=F
        ) 
        
        
        
      }
      
      
      
      
      # draw the histogram with the specified number of bins
      mat = matrix(c(1, 2), ncol=2, byrow=T)
      my_layout = layout(mat,  widths = c(1, 1.5))
      #par(mfrow=c(1,2))
      # FIRST PLOT
      par(mar=c(0,0,0,0))
      plot(0, 0, xlim=c(-1,1), ylim=c(-1,1), frame.plot =F, xlab="", ylab="", axes=F, type="n")
      curr_p = round(res$p.obs, 3)
      
      text_size = 1.2
      
      text(0,0.7, labels = paste("observed MoCA = ", input$obs_moca, sep=""), cex=text_size)
      text(0,0.5, labels = paste("predicted MoCA = ", round(pred_moca), sep=""), cex=text_size)
      
      if (curr_p < 0.001){
        text(0,0, labels = "observed p < 0.001", cex=text_size, col="red")
      } else {
        text(0,0, labels = paste("observed p = ", curr_p, sep=""), cex=text_size, col="red")
      }
      
      if(curr_p < 0.05){
        text(0, -0.5, labels = "below clinical cut-off", font = 2, col="red", cex=text_size)
      } else {
        text(0, -0.5, labels = "above or\n equal to clinical cut-off", font = 2, cex = text_size)
      }
      
      if(input$cri!=999){
        text(0, -0.7, labels = "(CRI included)", font = 2, cex = text_size)
      }
      
      if(input$cri==999){
        text(0, -0.7, labels = "(CRI not included)", font = 2, cex = text_size)
      }
      
      
      
      ## SECOND PLOT
      # set xlim
      my_lims = range(dat$MoCA, input$obs_moca, pred_moca)
      
    par(mar=c(3,3,4,0))
    # histogram with observed data
    hist(dat$MoCA, breaks=30, xlim=my_lims, lwd=1, 
         main="Histogram of observed scores\n in normative sample", 
         xlab="MoCA score")
    abline(v = input$obs_moca, pch=19, col="black", lwd=3)
    abline(v = res_crit$Y_obs_crit, col="red", lty=2, lwd=3)
    abline(v = pred_moca, col="darkgray", lty=1, lwd=3)
    legend("topleft", legend = c("observed", "predicted", "cut-off"), lty=c(1,1,2), col=c("black", "darkgray", "red"), lwd=2)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

