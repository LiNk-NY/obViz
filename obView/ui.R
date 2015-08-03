suppressPackageStartupMessages(library(googleVis))
library(shiny)
library(leaflet)
library(maps)
library(dplyr)
library(RColorBrewer)
library(tidyr)
library(data.table)
library(ggplot2)
library(gridExtra)
library(reshape2)

load("data/fullsurvey.Rda")

tabPanelAbout <- source("about.r")$value

shinyUI(
  fluidPage(
    fluidRow(
      column(8, titlePanel("Obesity Prevalence: Where Does Your State Stand?"), 
	helpText("The ObesityView interactive tool helps you visualize the distribution of obesity across the U.S. population.")),
      column(4, br(), img(src="CUNYlogo.png", align="right", height=72, style="margin-left:10px"),
             img(src="HunterLogo.png", align="right", height=72, style="margin-left:10px"))
    ),
    
    fluidRow(
      column(2, 
             wellPanel(
               h3("Data Selection"),
               radioButtons("year", label= HTML(paste("Choose a BRFSS",tags$sup(1), "Year:", sep=" ")), 
                            choices = list("BRFSS 2013" = 2013, "BRFSS 2012" = 2012,  "BRFSS 2011" = 2011)
               ), 
               helpText(h6("Visualize obesity by:")),
               
               checkboxGroupInput("sex", 
                                  label = "Gender",
                                  choices = c("Male", "Female"),
                                  selected = c("Male", "Female")),
               
               checkboxGroupInput("agegroup",
                                  label = "Age Group",
                                  choices = c("18-24", "25-34", "35-44", "45-54", "55-64", ">65"),
                                  selected = c("18-24", "25-34", "35-44", "45-54", "55-64", ">65")),
               
               checkboxGroupInput("race",
                                  label = "Racial/Ethnic Group*",
                                  choices = c("NH White", "NH Black", "NH Asian", "NH Native American/Alaskan Native"="NH NA/AN", "Hispanic", "Other"),
                                  selected = c("NH White", "NH Black", "NH Asian", "NH NA/AN", "Hispanic", "Other")),
               helpText("*NH - Non-Hispanic")
             )),
      column(9,
             tabsetPanel(
               tabPanel(title="ObesityView",

                        h3("Obesity Prevalence Proportion by State"),
                        helpText("Click on a state to view the prevalence of obesity for the selected data."), 
                        leafletOutput(outputId="obemap"),
                          helpText(HTML(paste("Data are presented in percentages, age-adjusted to the nationwide age distribution from the 2010 Census.",
                                tags$sup("2 "),"Darker colors indicate a higher prevalence of obesity.", sep=""))),
                        p(HTML(paste0("For this visualization, obesity was defined as having a Body Mass Index greater than 30 kg/m",tags$sup("2"), "."))),
                        h3("State Viewer"),
                          selectInput("state", label="Select a state to learn more about the distribution of obesity by age, sex, and racial/ethnic group.",
                                      choices= unique(BRFSS$STATE)),
                          plotOutput(outputId="stateview"),
                        hr(),
                        h4(HTML(paste("Contributing Factors: Availability of Farmers' Markets and Fast Food Restaurants",tags$sup("3,4"), sep=" "))),
                        p("While diet is related to obesity and is often considered an individual choice, the food environment
                        in which an individual lives can have an impact on that person's dietary choices and overall health.
                        The bubbleplots below illustrate the relationship between the prevalence of obesity and availability
                        of farmers' markets and fast food by state and region."),
                        br(),
                        htmlOutput(outputId="farmers"),
                        htmlOutput(outputId="fastfood"),
                        helpText("*Data available only for 43 states."),
                        value="geoviz"),
               tabPanelAbout(),
               id="tsp")
      )
   ) #fluidRow
  ) #fluidPage
) #shinyUI
