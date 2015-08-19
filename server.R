library(shiny)
library(tidyr)
#library(rCharts)
library(googleVis)
library(ggmap)
library(ggplot2)
library(mapproj)
# library(rworldmap)
# library(rworldextra)

#Create the Singapore Map Background
map <- get_map(location="Singapore", zoom=11,color="color",source="osm")
g<-ggmap(map, darken=c(0.05, "white"), extent="device")
  
#load and process the data
hdbprices<-read.csv("mydatapath/HDBmedianprices.csv",na.strings=c("*","-"),stringsAsFactors=FALSE,strip.white=TRUE)
for(i in 3:8) {hdbprices[,i]<-as.numeric(gsub(",","",gsub("\\$","",hdbprices[,i])))}
townnames<-sort(unique(hdbprices[,2]))
quarterandyear<-sort(unique(hdbprices[,1]))
housetype<-c("1 ROOM","2 ROOM","3 ROOM","4 ROOM","5 ROOM","EXECUTIVE")
for(i in 3:8) {colnames(hdbprices)[i]<-housetype[i-2]}
hdbpriceslookup<-gather(hdbprices,housetype,price,-c(QUARTER,TOWNS))
  
shinyServer(function(input, output) {

  output$myText<-renderText({
    prices<-NULL
    for(i in (length(quarterandyear)-2):length(quarterandyear)) {
      prices[i]<-as.numeric(subset(hdbpriceslookup,QUARTER==quarterandyear[i]
                                   & TOWNS==input$town & housetype==input$housetype,select=price))}
    meanoflast3quarters<-round(mean(prices,na.rm=TRUE))
    paste("Average Median Prices for Last 3 Quarters: $",meanoflast3quarters)
  })
  output$myChart <- renderGvis({
    #Lookup the HDB house prices for all the quarters for the selected town
    prices<-NULL
    for(i in 1:length(quarterandyear)) {
      prices[i]<-as.numeric(subset(hdbpriceslookup,QUARTER==quarterandyear[i]
                                   & TOWNS==input$town & housetype==input$housetype,select=price))}
    housingdata<-as.data.frame(cbind(as.character(quarterandyear),as.numeric(prices)))
    names(housingdata)<-c("quarterandyear","prices")
    housingdata$quarterandyear<-as.character(housingdata$quarterandyear)
    housingdata$prices<-as.numeric(as.character(housingdata$prices)) 


    gvisLineChart(housingdata,options=list(height=520,title=paste("Resale Price Trend For",input$town,input$housetype),
                                           titleTextStyle="{color:'black',fontName:'Arial',fontSize:20}",
                                           vAxes="[{title:'Prices in Singapore dollars (\\S$)'}]"
                                          ))
    })
  
  
  output$myMap <- renderPlot({
    areacode<-geocode(paste(input$town,",Singapore"))
      g+geom_point(aes(x=lon, y=lat), data=areacode,size=4,color="red")+geom_text(aes(x=lon, y=lat), label="Here!",data=areacode)
  })
})
