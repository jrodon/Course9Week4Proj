#
# This is the user-interface definition of the "Diamonds" Shiny web application.
# You can run the application from the "Run App" button above.
# 
# This app uses the "ggplot2::diamonds" datased to predict the price of a 
# diamond based on the inputs weight, cut, color, and clarity, all given by the
# user.
# Once all those options are chosen, the app filters the database accordingly 
# and fits a liner model sqrt(price) ~ weight. From that model then the app 
# returns the predicted 95% confidence interval for the weight selected, along 
# with a plot showing the selected data and the linear model.
#
#
library(shiny)
library(ggplot2)
data("diamonds")

# Define UI for application
shinyUI(fluidPage(
      # Application title
      titlePanel(title = h2("Price of a Diamond", align = "center")),
      # Sidebar with a slider input for desired weight and different options 
      # to choose from
      sidebarLayout(
            sidebarPanel(
                  sliderInput("diamCar",
                              "What is the weight of your diamond?",
                              min = min(diamonds$carat),
                              max = max(diamonds$carat),
                              value = 0.7,
                              step = 0.1,
                              post = " carats"),
                  selectInput("diamCut",
                              "Which type of cut do you want?",
                              choices = levels(diamonds$cut),
                              selected = "Ideal"),
                  selectInput("diamColor",
                              "What color should your diamond be?",
                              choices = levels(diamonds$color),
                              selected = "G"),
                  selectInput("diamClar",
                              "What degree of clarity are you looking for?",
                              choices = levels(diamonds$clarity),
                              selected = "SI1"),
                  textOutput("diamEmpty")
            ),
            # Show a plot of the generated distribution
            mainPanel(
                  plotOutput("diamPlot"),
                  h4("A diamond with the characteristics you selected will cost"),
                  h4(textOutput("diamPrice"))
            )
      )
))
