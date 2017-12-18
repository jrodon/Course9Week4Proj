#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
data("diamonds")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel(title = h2("Price of a Diamond", align = "center")),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       sliderInput("diamCar",
                   "Weight of the diamond (carats):",
                   min = min(diamonds$carat),
                   max = max(diamonds$carat),
                   value = 0.7,
                   step = 0.1),
       selectInput("diamCut",
                   "Cut:",
                   choices = levels(diamonds$cut),
                   # multiple = TRUE,
                   selected = "Ideal"),
       selectInput("diamColor",
                   "Color:",
                   choices = levels(diamonds$color),
                   # multiple = TRUE,
                   selected = "G"),
       selectInput("diamClar",
                   "Clarity:",
                   choices = levels(diamonds$clarity),
                   # multiple = TRUE,
                   selected = "SI1"),
       textOutput("diamEmpty")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("diamPlot"),
       h2("Predicted price of the diamond"),
       textOutput("diamPrice")
    )
  )
))
