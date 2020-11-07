#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Untuk meletakkan data dan package

library(shiny)
library(shinydashboard)

# Memanggil package yang digunakan
library(flexdashboard)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
library(plotly)
library(glue)
library(leaflet)

# Import Data
covid <- read.csv("data/perkembangan_covid.csv")
covid1 <- read.csv("data/kasus_harian_per_provinsi.csv")
covid2 <- read.csv("data/kecamatan_rawan.csv")


# membuat object leaflet(), sama seperti awalan ggplot()
map1 <- leaflet()

# membuat tiles atau gambar peta
map1 <- addTiles(map1)

# membuat konten popup dengan gaya penulisan html
content_popup <- paste(sep = " ",
                       "<B>","<left>", covid1$Provinsi,"</left>", "</B>", "<br>",
                       "Kasus Positif:", covid1$Positif, "<br>",
                       "Sembuh:", covid1$Sembuh, "<br>",
                       "Meninggal:", covid1$Meninggal
)

# memasukkan marker atau titik sesuai dengan data
map1 <- addMarkers(map = map1, 
                   covid1$covid1,
                   lng =  covid1$Long, # garis bujur
                   lat = covid1$Lat, # garis lintang
                   
                   popup = content_popup, #popup atau tulisan
                   
                   clusterOptions = markerClusterOptions() # membuat cluster supaya tidak overlap
)

# mengganti base map
#map1 <- addProviderTiles(map1, providers$Stamen.Toner)


# Data untuk visualisasi
## Covid Fatality


## Tema Visualisasi
theme_algo <- theme(
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(colour = "gray80"),
    panel.grid.minor = element_blank(),
    plot.title = element_text(family = "serif", 
                              size = 18)
)


# Define UI for application that draws a histogram
ui <- dashboardPage(
    
    dashboardHeader(title = "COVID-19 Tracker"), # header atau kepala dashboard
    
    dashboardSidebar( # menu atau tampilan di sisi samping dashboard
        
        sidebarMenu(
            
            menuItem(text = "Trend", icon = icon("chart-line"),  
                     menuSubItem(text = "Trend", icon = icon("chart-line"), tabName = "trend")  ),
            
            menuItem(text = "Map", icon = icon("map-marked-alt"), tabName = "map"),
            
            menuItem(text = "Statistics", icon = icon("info-circle"), tabName = "stat"),
            
            menuItem(text = "Data", icon = icon("table"), tabName = "data")
        )
        
    ),
    
    dashboardBody( # halaman utama
        
        tabItems( # sebagai wadah untuk setiap tab item 
            
            # setiap tab item berhubungan dengan 1 menu item    
            tabItem(tabName = "trend", align = "center",
                    
                    # UI atau tampilan untuk tab trend
                    ## Judul atau Heading
                    h2("Trend Confirmed Cases") ,
                    
                    ## input
                    selectInput(inputId = "trend_country", # id atau tanda pengenal input
                                label = "Select Country",  # tulisan yang muncul di UI
                                multiple = T, # bisa memilih lebih dari 1 input
                                selected = c("Indonesia", "India", "US"),  # yang terpilih di awal apa saja
                                choices = unique(covid$Country.Region) # pilihannya apa saja
                    ) ,
                    
                    ## output berupa plotly line chart
                    plotlyOutput(outputId = "trend_line")
            ),   
            
            tabItem(tabName = "map", align = "center",
                    h2("Persebaran Covid-19 di Indonesia") ,
                    leafletOutput("map")
            ),   
            
            tabItem(tabName = "stat"),   
            
            tabItem(tabName = "data",
                    
                    h2("Data Covid-19"), # h2 = heading 2
                    
                    DT::dataTableOutput(outputId = "table")
                    
            )  
            
        )
        
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # Mengeluarkan plot trend line
   
    
    output$map <- renderLeaflet({
        map1
    })
    
    output$table <- DT::renderDataTable({
        
        covid1
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
