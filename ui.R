library(shiny)
library(ggmap)
library(ggplot2)
#library(rCharts)

#load and process the data
hdbprices<-read.csv("mydatapath/HDBmedianprices.csv",na.strings=c("*","-"),stringsAsFactors=FALSE,strip.white=TRUE)
for(i in 3:8) {hdbprices[,i]<-as.numeric(gsub(",","",gsub("\\$","",hdbprices[,i])))}
townnames<-sort(unique(hdbprices[,2]))
quarterandyear<-sort(unique(hdbprices[,1]))
housetype<-c("1 ROOM","2 ROOM","3 ROOM","4 ROOM","5 ROOM","EXECUTIVE")

shinyUI(fluidPage(
  titlePanel(h1("Singapore Public HDB Housing Resale Price")),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Documentation: How To Use This Tool"),
      helpText("1) Choose Town & House Type to display price trend"),
      selectInput("town","Town",choices=townnames,selected="Bedok"),
      selectInput("housetype","House Type",choices=housetype,selected="4 ROOM"),
      helpText("2) Red dot marks the location of the Town in Singapore"),
      plotOutput("myMap",width="100%"),
      helpText("3) The plot on the right side in Main Panel Shows the Median Price
               of the HDB house of the Type and in the Town selected.")
    ),
    mainPanel(
      h4("HDB Flat Price Trend"),
      p("Singapore is a country that has one of the highest home ownership
        in the world and one reason is the government policy to provide affordable 
        housing for the residents in the form of HDB Housing Development Board houses.  
        These houses also have a vibrant resale market subject to goverment rules, 
        and the resale prices is an interesting data to study. Resale prices have risen from a low during the 2007 to a peak in 2013 and thereafter trended down after a 
        slew of cooling measures from the Singapore Government.", style="color:blue"),
      h4("Please be patient. 
         The map and plot is this application takes about a minute to load.",style="color:red"),
      h4("Note: There may be no resale data for certain room types and town, esp.
         for 1 ROOM & 2 ROOMS. If so, please select another combination. 
         HINT: 3/4/5 ROOMS housing are most popular on resale market.",style="color:blue"),
      h4(textOutput("myText"),style="color:green"),
      htmlOutput('myChart'),
      p("House prices are hard to predict, as the global economy as well as
        government polices can change very quickly. The purpose of the app
        is to allow the user to quickly view the trend of median resale prices and he can
        make his own judgement on what might be a fair price to buy a resale HDB
        house now.", style="color:blue"),
      tags$a(href="http://www.hdb.gov.sg/fi10/fi10321p.nsf/w/BuyResaleFlatMedianResalePrices?OpenDocument", "Raw Data From HDB Website, click here",style="color:black",target="_blank")
      
    )
  )
))
