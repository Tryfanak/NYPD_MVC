library(shiny)

shinyUI(fluidPage(
  titlePanel("An Analysis of Motor Vehicle Collisions in New York"),
  helpText("This app uses data on motor vehicle collisions from the  NYC OpenData Website, 
           and allows the user to subset it by borough, date, and whether there were any injuries. 
           The app calculates the total number of accidents selected, and the average number per day.
           It also shows a histogram of the time of day that the accidents occurred, and a bar chart
            of the top ten causes of injury accidents. Scrolling down, there is a summary of the 
           dataset for the active parameter selections."),
  h3(textOutput("total")),

  fluidRow(
    column(7, plotOutput("hist")),
    column(5, br(), h5("Tip: Use these controls to specify a subset of accidents"),br(),
           selectInput("borough",
                         label = "Select a New York borough, or ALL",
                         choices = c("ALL BOROUGHS", "BRONX", "BROOKLYN", "MANHATTAN",
                                     "QUEENS", "STATEN ISLAND"),
                         selected = "ALL BOROUGHS"),br(),
           dateRangeInput("dates", "Select a date range", start = "2014-01-01",end = "2016-03-14"),
           br(),
           checkboxInput("injury", "Show only accidents involving injuries", value = FALSE)
           )
  ),
  
  fluidRow(
    column(8,plotOutput("bar"))
  ),
  
  fluidRow(
    verbatimTextOutput("stats")
  )
  
))