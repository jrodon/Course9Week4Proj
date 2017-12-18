#
# This is the server logic of the "Diamonds" Shiny web application. You can run 
# the application from the "Run App" button above.
# 
# This app uses the "ggplot2::diamonds" datased to predict the price of a 
# diamond based on the inputs weight, cut, color, and clarity, all given by the
# user.
# Once all those options are chosen, the app filters the database accordingly 
# and fits a liner model sqrt(price) ~ weight. From that model then the app 
# returns the predicted 95% confidence interval for the weight selected, along 
# with a plot showing the selected data and the linear model.
#

library(shiny)
library(dplyr)
library(scales)
library(ggplot2)

# Define server logic required
shinyServer(function(input, output) {
      # Filter the dataset with the user's options
      diamSet <- reactive({
            diamonds %>% filter(cut == input$diamCut & 
                                      color == input$diamColor &
                                      clarity == input$diamClar)
      })
      # Check if there's enough data to continue
      output$diamEmpty <- renderText({
            if(nrow(diamSet()) < 3){
                  "Not enough data for estimation, please select different options"
            }
      })
      # Fit the linear model. Done with the sqrt since then the relation 
      # is more liner
      diamFit <- reactive({
            lm(sqrt(price) ~ carat, data = diamSet())
      })
      # Obtain the predicted price range
      pricePred <- reactive({
            predict(diamFit(), newdata = data.frame(carat = input$diamCar), 
                    interval = "confidence")**2
      })
      # Output the predicted price range
      output$diamPrice <- renderText({
            ifelse(pricePred()[1] > 0, paste("between u$s",
                                             round(pricePred()[2]),"and u$s",
                                             round(pricePred()[3])),
                   "Sorry, weight outside prediction range")
      })
      # Generate the plot with the chosen options
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
