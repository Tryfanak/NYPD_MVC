# server.R

library(dplyr);library(tidyr)
rawdata <- readRDS("data/NYPD_MVC.rds")

shinyServer(function(input, output) {
  
  alldata <- reactive({
    data <- rawdata
    if (input$borough !="ALL BOROUGHS") {
      data <- rawdata[rawdata$BOROUGH==input$borough,]
      data$BOROUGH <- droplevels(data$BOROUGH)
      }
    data <- data[data$DATE>= input$dates[1] & data$DATE<= input$dates[2],]
  })
  
  injdata <- reactive({
    data <- alldata()
    data[data$INJURED>0,]
  })
  
  userdata <- reactive({
    if (input$injury) {data <- injdata()} else {data <- alldata()}
    data
  })
  
  output$total <- renderText({
    tot <- nrow(userdata())
    avg <-  round( tot / as.numeric(input$dates[2] - input$dates[1] + 1))
    paste("Total number of accidents selected =", tot, ", Average per day =", avg)
  })

  output$hist <- renderPlot({
    data <- userdata()
    hist(data$HOUR, breaks=24, freq = FALSE, col="violet",
         main = paste("Frequency of Traffic Accidents for",input$borough), 
         xlab="Time of Day (Hour in 24 hour clock)",
         ylab="Density (Total area sums to 1.0")
  })
  
  output$bar <- renderPlot({
    causeraw <- injdata() %>% group_by(CAUSE, BOROUGH) %>%
      summarize(INJURED=sum(INJURED)) %>%
      filter(CAUSE!="Unspecified") %>% filter(CAUSE!="")
    
    acctot <- causeraw %>% group_by(CAUSE) %>% summarize(TOTINJ=sum(INJURED))
    
    accsummary <- causeraw %>% spread(BOROUGH,INJURED)  %>%
      left_join(acctot, by = "CAUSE") %>%
      ungroup() %>% 
      arrange(desc(TOTINJ)) %>% top_n(10,TOTINJ)
    
    nb <- ncol(accsummary)-1
    
    collist <- switch(input$borough,
                   "ALL BOROUGHS" = c("lightblue", "lightyellow", "lightgrey", "lightgreen", "pink"),
                   "BRONX" = c("lightblue"),
                   "BROOKLYN" = c("lightyellow"),
                   "MANHATTAN" = c("lightgrey"),
                   "QUEENS" = c("lightgreen"),
                   "STATEN ISLAND" = c("pink"))
    
    par(mar=c(5,15,3,5))
    barplot(aperm(as.matrix(accsummary[,2:nb])),
            horiz=TRUE,
            names.arg=accsummary$CAUSE, las=1,
            legend=names(accsummary)[2:nb], 
            col = collist,
            main = "Top Ten Causes of Injuries in Traffic Accidents",
            xlab = "Total number of injuries from this cause")
  })
  
  output$stats <- renderPrint({
    summary(userdata())
  },width=120)
  
})