#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(scales)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
      # Filter the dataset with the user's options
      diamSet <- reactive({
            diamonds %>% filter(cut == input$diamCut & 
                                      color == input$diamColor &
                                      clarity == input$diamClar)
      })
      
      output$diamEmpty <- renderText({
            if(nrow(diamSet()) < 3){
                  "Not enough data for estimation, please select different options"
            }
      })
      
      # Fit the linear model
      diamFit <- reactive({
            lm(sqrt(price) ~ carat, data = diamSet())
      })
      
      pricePred <- reactive({
            predict(diamFit(), newdata = data.frame(carat = input$diamCar), 
                    interval = "confidence")**2
      })
      
      output$diamPrice <- renderText({
            ifelse(pricePred()[1] > 0, paste("Between u$s",
                                             round(pricePred()[2]),"and u$s",
                                             round(pricePred()[3])),
                   "Sorry, weight outside prediction range")
      })
      
      output$diamPlot <- renderPlot({
            carInp <- input$diamCar
            g <- ggplot(data = diamSet(), aes(x = carat, y = price, color = "cut"))
            g <- g + geom_point() +
                  stat_smooth(method = "lm", formula = y ~ x,
                              col = "blue") +
                  scale_y_continuous(trans = sqrt_trans(),
                                     breaks = trans_breaks("sqrt", 
                                                           function(x) x ^ 2, n = 10)
                                     (c(min(diamSet()$price), max(diamSet()$price)))) +
                  scale_x_continuous(breaks = seq(min(diamSet()$carat), 
                                                  max(diamSet()$carat), length.out = 5)) +
                  labs(x = "Weight (carat)", y = "Price (u$s)", 
                       caption = "(based on data from the \"Diamonds\" dataset from the \"ggplot2\" package)") +
                  theme(legend.position="none")
            if(carInp <= max(diamSet()$carat) & carInp >= min(diamSet()$carat) ) {
                  g + geom_point(data = data.frame(carat = carInp, price = pricePred()[1]),
                                 color = "black", cex = 4, shape = 23, fill = "yellow")
            } else {g}
      })
})