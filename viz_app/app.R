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
ATK_long <- read.csv("data/all_ATK.csv", row.names=1) %>% 
                melt(id="Level", value.name = "val")
HP_long <- read.csv("data/all_HP.csv", row.names=1) %>% 
                melt(id="Level", value.name = "val")
DEF_long <- read.csv("data/all_DEF.csv", row.names=1) %>% 
                melt(id="Level", value.name = "val")
character_summary <- read.csv("data/character_summary.csv", row.names=1)


ui <- fluidPage(

    titlePanel("Genshin Impact Character Data Visualization"),

    sidebarLayout(
        sidebarPanel(
            fluidRow(
                column(6,
                       checkboxGroupInput(
                           inputId = "Weapon",
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
                       checkboxGroupInput(
                           inputId = "Rarity",
                           label = "Rarity",
                           choices = c(
                               "4-Star",
                               "5-Star"
                               ),
                           ),
                       checkboxGroupInput(
                           inputId = "Sex",
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
                       checkboxGroupInput(
                           inputId = "Type",
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
                       checkboxGroupInput(
                           inputId = "Nationality",
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
            fluidRow(
                column(10,
                       plotOutput("gv_plot")
                ),
                column(2,
                       radioButtons(
                           inputId = "dataset",
                           label = "Display:",
                           choices = c(
                               "Attack",
                               "HP",
                               "Defense"
                               )
                           )
                       )
                )
            )
        )
    )


server <- function(input, output) {
    dataset_input <- reactive(switch(input$dataset,
                                     "Attack" = ATK_long,
                                     "HP" = HP_long,
                                     "Defense" = DEF_long))
    input_weapon <- reactive(input$Weapon)
    input_rarity <- reactive(sapply(input$Rarity, 
                                    switch, 
                                    "4-Star" = 4,
                                    "5-Star" = 5))
    input_sex <- reactive(input$Sex)
    input_type <- reactive(input$Type)
    input_nationality <- reactive(input$Nationality)
    
    output$gv_plot <- renderPlot({ 
        pick_characters(
            character_summary,
            input_weapon(),
            input_rarity(),
            input_sex(),
            input_type(),
            input_nationality()) %>%
            genshin_plot(
                data = dataset_input(),
                title = paste("Genshin Impact Characters",
                              input$dataset,
                              "vs. Level"),
                subtitle = generate_subtitle(
                    input_weapon(),
                    input_rarity(),
                    input_sex(),
                    input_type(),
                    input_nationality()
                ),
                ylabel = input$dataset
            )
    })
}

shinyApp(ui = ui, server = server)
