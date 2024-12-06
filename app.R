# 5 December 2024
# An app to allow the user to compare MODEL 1 and MODEL 2 to estimate the 
# number of health care facilties in a country. 

# Load necessary libraries for the app
library(shiny)          # Core Shiny library for building interactive web apps
library(shinydashboard) # Provides dashboard layout capabilities
library(dplyr)          # Data manipulation library
library(reshape2)       # For reshaping data between wide and long formats
library(ggplot2)        # Popular plotting library for creating visualizations
library(shinyWidgets)   # Enhances UI components for Shiny
library(gridExtra)      # Provides grid functions for arranging multiple plots

## app.R ##
# Load data for the dashboard from a CSV file
data               <- read.csv("Model12.csv")
countryVec         <- unique(data$Country)  # For use in checkboxes
data$pred_Y        <- 10^data$log10_pred_Y
data$Model         <- as.factor(data$Model)

# Display the first few rows and structure of the data
head(data)  # Preview the data
str(data)   # Show the structure and data types

data1 <- data[48:94,]
data2 <- data[1:47,]

# # Line of best fit - from Model 1.
# bestfitx  <- c(min(data1$countryPop), max(data1$countryPop))
# bestfitx  <- bestfitx / 1000000
# bestfity  <- c(min(data1$log10_pred_Y), max(data1$log10_pred_Y))
# bestfity  <- 10^bestfity 
# bestfitxy <- data.frame(cbind(bestfitx, bestfity))

# Define the User Interface (UI) layout using fluidPage
ui <- fluidPage(
  # Main header
  h2("Estimating the number of health care facilities in sub-Saharan Africa."),
  h4("Visualisation tool for model comparison. MODEL 1: Population data as the sole predictor.  MODEL 2: Adds the proportion of hospital facilities as a variable."),
  h6("See the PowerPoint and Python notebook for details. | Code available on https://github.com/TamsinELee/XXXXXX"),
  h6("Data sources: https://data.humdata.org/dataset/health-facilities-in-sub-saharan-africa and https://hub.worldpop.org/geodata/listing?id=74"),
  # Apply custom CSS styles for margin around box elements
  dashboardBody(tags$head(tags$style(HTML('.box {margin: 5px;}'))),
                fixedRow( # Layout rows and columns in a fixed position
                  column(12,
                         wellPanel(
                           fixedRow(  # Layout inner rows for input selection and plots
                             column(4,  # First column for selecting options and displaying smaller plots
                                    column(6,  # Checkbox for countries
                                           h6(checkboxGroupInput(inputId = "country1", 
                                                                 label   = "Select countries of interest", 
                                                                 choices = countryVec[1:23],
                                                                 selected =  c()))
                                    ), 
                                    column(6,  # Checkbox countries
                                           h6(checkboxGroupInput(inputId = "country2", 
                                                                 label   = "", 
                                                                 choices = countryVec[24:47],
                                                                 selected = c("Sudan", "Nigeria"))),
                                    ),
                                    h4("Relative error (signed)"),
                                    plotOutput("plotError"),
                                    ),
                             column(8, # Second column for larger plots showing inputs, outputs, and mean scores
                                    h4('Number of health care facilties scaling with population (exponent is 0.89).'),
                                    h5('Selected countries are highlighted, and the predictions for MODEL 1 and MODEL 2 added to the plot.'),
                                    plotOutput("plotMain"),
                                    h4('---'),
                                    h4('Proportion of listed health care facilities which are hospitals.'),
                                    h5('This is used as a secondary predictor in MODEL 2 to avoid overestimates in the case of missing data on primary and secondary facilities.'),
                                    plotOutput("plotHosp"),
                            #        h4('Estimated average qualities from ED qualitative assessment'),
                            #        plotOutput("plotMeans")
                             )# close fixed Row# close fixed Row
                           ), # close wellPanel
                         ), #close column
                         column(9,
                                #wellPanel(
                                #h4('The finance indicators from GHED (green line) that correlate with the incidence/mortality. 
                                #Plots are ordered such that the first plot has the strongest correlation to the incidence/mortality.'),
                                #       plotOutput("plotInd", width = "100%")
                                #, height = 1200),#close WellPanel)
                         )
                  ) #close column
                ) # close fixedRow
  ) # close dashboardBody
) # close fluidPage

# Define the server logic that creates plots and calculations based on user inputs
server <- function(input, output, session) {
  
  get.thisData    <- reactive({
    theseCountries <- c(input$country1, input$country2)
    thisData       <- data %>% filter(Country %in% theseCountries)
    thisData$Model <- as.factor(thisData$Model)
    thisData
  })
  
    # Generate plots 
  output$plotMain  <-  renderPlot({
  
    thisData   <- get.thisData()
    
    plot <- ggplot() +
      geom_point(data = thisData, aes(x = log10_x, y = log10_pred_Y, color = Model), size = 4) +
      geom_point(data = data1, aes(x = log10_x, y = log10_y), colour = "#138086", alpha = 0.2, size = 4) +
     # geom_line(data = bestfitxy, aes(x = bestfitx, y = bestfity), size = 2, color = "#CD7672") + 
      geom_line(data = data1, aes(x = log10_x, y = log10_pred_Y), size = 1, color = "#CD7672") + 
      geom_point(data = thisData, aes(x = log10_x, y = log10_y), color = "#138086", size = 4) +
      scale_x_continuous(name = "Population (millions)", breaks = c(5, 6, 7, 8), labels = c("0.1", "1", "10", "100")) + 
      scale_y_continuous(name = "Number of health care facilties", breaks = c(1, 2, 3, 4), labels = c("10", "100", "1,000", "10,000")) + 
      scale_color_manual(values = c("#CD7672", "#EEB462"), labels = c("MODEL 1", "MODEL 2")) + 
      theme_bw(base_size = 18) + 
      theme(legend.position = c(0.2, 0.9), legend.title=element_blank())
    plot
  }, height = 400)    #, height = 200, width = 400

  # Plot for proportion of hospitals for selected countries
  output$plotHosp  <-  renderPlot({
    
    thisData   <- get.thisData()
    toPlotHosp <- data2
    toPlotHosp$Selected <- rep(0, nrow(data2))
    toPlotHosp$Selected[which(toPlotHosp$Country %in% unique(thisData$Country))] <- 1
    
    toPlotHosp$Country <- factor(toPlotHosp$Country, levels = toPlotHosp$Country[order(toPlotHosp$Hospital_Percentage)])
    plot <- ggplot() +
      geom_col(data = toPlotHosp, aes(x = Country, y = Hospital_Percentage, alpha = as.factor(Selected)), color = "black", fill = "#EEB462") +
      geom_hline(yintercept = 4.3, linetype = "dashed") + 
      annotate("text", x = 4, y = 12, label = "median = 4.3", size = 5, color = "black") +
      scale_y_continuous(name = "Percentage") + 
      scale_x_discrete(name = "") + 
      theme_bw(base_size = 18) + 
      theme(legend.position = "none") + 
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
    plot
  }, height = 400)    #, height = 200, width = 400
  
  # Plot for error
  output$plotError  <-  renderPlot({
    
    thisData   <- get.thisData()
    
     plot <- ggplot() +
      geom_col(data = thisData, aes(x = Country, y = Relative_Error, fill = as.factor(Model)), position_dodge(), color = "black") +
      scale_y_continuous(name = "Relative error") + 
      scale_x_discrete(name = "") + 
      scale_fill_manual(values = c("#CD7672", "#EEB462"), labels = c("MODEL 1", "MODEL 2")) + 
      theme_bw(base_size = 18) + 
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
       theme(legend.position = c(0.9, 0.9), legend.title=element_blank())
    plot
  }, height = 300)    #, height = 200, width = 400
  
  
    
}

shinyApp(ui, server)
 