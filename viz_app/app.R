#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#

library(shiny)
library(tidyverse)
library(ggplot2)
library(reshape2)
library(stringr)

source("genshin_viz_func.R")

theme_set(theme_classic())
all_ATK <- read.csv("data/all_ATK.csv", row.names=1)
ATK_long <- melt(all_ATK, id="Level", value.name = "ATK")
character_summary <- read.csv("data/character_summary.csv", row.names=1)


ui <- fluidPage(

    titlePanel("Genshin Impact Character Data Visualization"),

    sidebarLayout(
        sidebarPanel(
            fluidRow(
                column(6,
                    checkboxGroupInput(inputId = "Weapon",
                                       label = "Weapon",
                                       choices = c(
                                           "Bow",
                                           "Catalyst",
                                           "Claymore",
                                           "Polearm",
                                           "Sword"
                                       )
                    )
                ),
                column(6,
                   checkboxGroupInput(inputId = "Rarity",
                                      label = "Rarity",
                                      choices = c(
                                          "4",
                                          "5"
                                      ),
                   ),
                   checkboxGroupInput(inputId = "Sex",
                                      label = "Sex",
                                      choices = c(
                                          "Male",
                                          "Female"
                                      ),
                   ),
                )
            ),
            fluidRow(
                column(6,
                   checkboxGroupInput(inputId = "Type",
                                      label = "Type",
                                      choices = c(
                                          "Anemo",
                                          "Cryo",
                                          "Dendro",
                                          "Electro",
                                          "Geo",
                                          "Hydro",
                                          "Pyro"
                                      )
                   )
                ),
                column(6,
                   checkboxGroupInput(inputId = "Nationality",
                                      label = "Nationality",
                                      choices = c(
                                          "Fontaine",
                                          "Inazuma",
                                          "Liyue",
                                          "Mondstadt",
                                          "Natlan",
                                          "Snezhnaya",
                                          "Sumeru"
                                      )
                   )
                )
            )
        ),


        mainPanel(
           plotOutput("choices")
        )
    )
)


server <- function(input, output) {
    output$choices <- renderPlot({ 
        pick_characters(
            character_summary,
            input$Weapon,
            input$Rarity,
            input$Sex,
            input$Type,
            input$Nationality) %>%
            genshin_plot(
                data = ATK_long,
                title = "Genshin Impact Characters Attack vs. Level",
                subtitle = generate_subtitle(
                    input$Weapon,
                    input$Rarity,
                    input$Sex,
                    input$Type,
                    input$Nationality
                )
            )
    })
}

shinyApp(ui = ui, server = server)
