# ----------------------------------------------------------------
#       CW PRAIRIES CLIMATE ADAPTATION DECISION SUPPORT TOOL
# ----------------------------------------------------------------


# This is an R Shiny web application for the decision support tool, 
# one of three products available with the CW Prairies Climate
# Adaptation Resource. The full resource is available at:
#
# ----------->       cwprairies.org     <--------------
# 
# K. Moore Powell - August 3, 2019
#

# Load libraries
library(shiny)
library(dplyr)
library(leaflet)
library(shinydashboard)

## Temporarily "hardcode" or populate a dataframe to test out the Task Menu in the upper right
taskData <- data.frame("value" = c(100,50,70,25,10), "color" = c("green","aqua","yellow","blue","red"), 
        "label" = c("Define Goals:","Assess Climate Stressors:","Evaluate Impacts:","Identify 6 Strategies:","Monitor:"))

## set up local data
humans  <- read.csv("database/HumanStressors.csv", fileEncoding="UTF-8-BOM")
cwsites <- read.csv("database/cwprairies.csv", fileEncoding="UTF-8-BOM")
goals <- read.csv("database/Goals.csv", fileEncoding="UTF-8-BOM")
goal_choices <- goals$Name
points <- select(cwsites, Lat, Long)
points <- cbind(points$Long,points$Lat)
stress <- read.csv("database/Stressors.csv", fileEncoding="UTF-8-BOM")
stress_choices <- stress$Type

# User interface
ui <- dashboardPage(
  title = "Prairies Climate Adaptation",
  
  ## Color of the title band at the top
  skin = c("green"),
  
  dashboardHeader(title = span(tagList(icon("leaf"), "Adapt Prairies")),
               dropdownMenuOutput("taskMenu")),  
  
  ## Sidebar content
  dashboardSidebar(
    ## width = 350,
    sidebarMenu(
      menuItem("Start Here!", tabName = "home"),
      menuItem("DEFINE", tabName = "define",
               menuSubItem("Management Goals", tabName = "goals"),
               menuSubItem("Prairie Sites", tabName = "sites")),
      menuItem("ASSESS", tabName = "assess"),
      menuItem("EVALUATE", tabName = "evaluate"),
      menuItem("IDENTIFY", tabName = "identify",
               menuSubItem("Overview", tabName = "overview"),
               menuSubItem("Improve Structure", tabName = "structure"),
               menuSubItem("Optimize Biodiversity", tabName = "diversity"),
               menuSubItem("Social Connections", tabName = "social")),
      menuItem("MONITOR", tabName = "monitor"),
      menuItem("RECOMMENDATIONS", tabName = "recommend")
      
    )),
  
  ## Dashboard Main Body content
  dashboardBody(
    tabItems(
      # Start Here! or Home tab content
      tabItem(tabName = "home", wellPanel(tags$img(src = "Home.png"))),
 
      # DEFINE...Goals subtab content
      tabItem(tabName = "goals", wellPanel(h2("MANAGEMENT GOALS")),
              fluidPage(
                selectInput("goal_pick", 
                            label = "Select a Management Goal",
                            choices = goal_choices)
              )),
      
      # DEFINE...Sites subtab content
      tabItem(tabName = "sites",
              fluidPage(
                leafletOutput("mymap"))),
      
      # ASSESS tab content
      tabItem(tabName = "assess", wellPanel(h2("CLIMATE STRESSORS")),
              fluidPage(
                selectInput("stressor_pick", 
                            label = "Select a Climate Stressor",
                            choices = stress_choices)
              )),
      
      # EVALUATE
      tabItem(tabName = "evaluate",
              h2("EVALUATE tab content")),
      
      # IDENTIFY...Overview subtab content
      tabItem(tabName = "overview",tags$img(src = "Identify.png")),
      
            # IDENTIFY...Structure subtab content
      tabItem(tabName = "structure",
              h2("STRUCTURE tab content")),
      
      # IDENTIFY...Structure subtab content
      tabItem(tabName = "diversity",
              h2("BIODIVERSITY tab content")),

      # IDENTIFY...Social subtab content
      tabItem(tabName = "social",
              h2("NURTURE SOCIAL CONNECTIONS tab content")),

      # MONITOR 
      tabItem(tabName = "monitor",
              h2("MONITOR tab content")),

      # RECOMMEND 
      tabItem(tabName = "recommend",
              h2("RECOMMENDATIONS tab content"))
    )
   )
)


# Server code
server <- function(input, output) { 
  
  ## Message menu
  output$taskMenu <- renderMenu({
    # Code to generate the Task Menu on the upper right. This assumes
    # that taskData is a data frame with three columns, 'value','color, and 'label'.
    tasklist <- apply(taskData, 1, function(row) {
      taskItem(value = row[["value"]], color = row[["color"]], row[["label"]])
    })
    
    # This is equivalent to calling:
    #   dropdownMenu(type="tasks", task[[1]], task[[2]], ...)
    dropdownMenu(type = "tasks", badgeStatus = "success",.list = tasklist)
  })
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.Terrain,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points)
  })
}

# Run application
shinyApp(ui, server)