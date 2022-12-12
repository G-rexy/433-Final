library(shiny)
library(viridis)
library(cowplot)
library(knitr)
library(tidyverse)
library(lubridate)
library(plotly)

## Read Data Set

covidData <- read_csv("https://raw.githubusercontent.com/G-rexy/433-Final/main/Covid.csv")
ratio <- read_csv("https://raw.githubusercontent.com/G-rexy/433-Final/main/data_ratio.csv")

## Regular Plots
case_poverty <- function(df) {
  df %>%
    ggplot(aes(x = below_poverty_ratio, y = cases_ratio)) +
    geom_smooth(color = "blue",method = "lm", se = FALSE) +
    geom_point(color = "light blue") +
    xlab("Poverty Population Ratio") +
    ylab("COVID-19 Cases Ratio") +
    ggtitle("COVID-19 Cases vs. Poverty Ratio",
            subtitle = "2020-12-04") +
    theme_minimal()
}

case_overcrowding <- function(df) {
  df %>%
    ggplot(aes(x = below_poverty_ratio, y = cases_ratio)) +
    geom_smooth(color = "blue",method = "lm", se = FALSE) +
    geom_point(color = "dark green") +
    xlab("Overcrowding Population Ratio") +
    ylab("COVID-19 Cases Ratio") +
    ggtitle("COVID-19 Cases vs. Overcrowding Ratio (%)",
            subtitle = "2020-12-04") +
    theme_minimal()
}

case_uninsured <- function(df) {
  df %>%
    ggplot(aes(x = uninsured_ratio, y = cases_ratio)) +
    geom_smooth(color = "blue",method = "lm", se = FALSE) +
    geom_point(color = "pink") +
    xlab("Uninsured Population Ratio") +
    ylab("COVID-19 Cases Ratio") +
    ggtitle("COVID-19 Cases vs. Uninsured Ratio",
            subtitle = "2020-12-04") +
    theme_minimal()
}

distribution = function(df) {
  df %>%
    ggplot(aes(x=lon,y=lat,
               color = cases)) + 
    geom_point() + 
    scale_size(guide = "none") + 
    scale_color_viridis(option = "D",
                        trans = "log",
                        limits = c(1,100000),
                        breaks = c(1,10,100,1000,10000,100000),
                        labels = format(c(1,10,100,1000,10000,100000),
                                        big.mark=",",scientific=FALSE)) + 
    labs(x="Longitude", y="Latitude") + 
    coord_equal() + 
    ggtitle("COVID19 cases by US county") +
    theme(axis.title = element_blank()) +
    theme_minimal()
}

four_plots_old = function(df) {
  a = plot_ly(df,x = ~ num_uninsured, y = ~cases, name = "num_uninsured")
  
  b = plot_ly(df,x = ~ num_below_poverty, y = ~cases, name = "num_below_poverty")
  
  c = plot_ly(df,x = ~num_overcrowding, y = ~cases, name = "num_overcrowding")
  
  d = plot_ly(df,x = ~total_population, y = ~cases, name = "total_population")
  
  subplot(a,b,c,d)
}

four_plots_new = function(df) {
  a = plot_ly(df,x = ~ log10(num_uninsured), y = ~log10(cases), name = "num_uninsured")
  
  b = plot_ly(df,x = ~ log10(num_below_poverty), y = ~log10(cases), name = "num_below_poverty")
  
  c = plot_ly(df,x = ~log10(num_overcrowding), y = ~log10(cases), name = "num_overcrowding")
  
  d = plot_ly(df,x = ~log10(total_population), y = ~log10(cases), name = "total_population")
  
  subplot(a,b,c,d)
}

ui <- navbarPage(
    strong("Socioeconomic Impacts of Covid-19 Cases in 2020"),
    tabPanel(
      "Introduction",
      p("The original data link is", a("here", href = "https://www.kaggle.com/code/johnjdavisiv/us-counties-weather-health-hospitals-covid19-data/data?select=cdc_social_vulnerability_column_select.csv"),"."),
      p("We transformed and filtered the original data, and create a new data set for us. We keep it in ", a("GitHub link"),href = "https://github.com/G-rexy/433-Final/blob/main/Covid.csv","."),
      p("The data collects the information from every county in United States on 2020-12-04."),
      p("The plot below shows the general distribution of cases using ",strong("Longitude")," and ",strong("Latitude"), ":"),
      plotlyOutput("distribution"),
      p("In this project, we choose four explanatory variables that illustrating the socioeconomic status from over 200 variables in the original dataset, which are:"),
      p("(1) num_below_poverty"),
      p("(2) num_overcrowding "),
      p("(3) num_uninsured"),
      p("(4) total_population"),
      p("Then, we have the plot:"),
      plotlyOutput("four_plots_old"),
      p("From the four plots above, we do see some \"fake\" outliers, but actually they are not. These \"outliers\" are the larger states with larger population, and it is reasonable to see that these states have more possibilities to have more COVID-19 cases."),
      p("Therefore, to remove \"outliers\" from plots, we transform the original data into log10 format and visualize as:"),
      plotlyOutput("four_plots_new"),
      p("We want to find how these variables can impact the cases of COVID-19 cases on 2020-12-04, which is the last day of the dataset. Therefore, we apply ", strong("linear regression model")," on the four variables separately.")
      ),
    tabPanel(
      "Poverty",
      p("This page displays the relevant information to explain the association between COVID-19 cases on 2020-12-04 and number of people below poverty in each county."),
      p("Based on the linear regression analysis, we have the predicted model as"),
      uiOutput("poverty_lm"),
      p(strong("Visualizations: ")),
      plotlyOutput("p1_line"),
      p(strong("Conclusion:")),
      p("We find the positive association between ",strong("cases_ratio"), " and ", strong("below_poverty_ratio"), ".")),
    tabPanel(
      "Overcrowding",
      p("This page displays the relevant information to explain the association between COVID-19 cases on 2020-12-04 and number of overcrowding people in each county."),
      p("Based on the linear regression analysis, we have the predicted model as"),
      uiOutput("overcrowding_lm"),
      p(strong("Visualizations: ")),
      plotlyOutput("p2_line"),
      p(strong("Conclusion:")),
      p("We find the positive association between ",strong("cases_ratio"), " and ", strong("overcrowding_ratio"), ".")),
    tabPanel(
      "Uninsured",
      p("This page displays the relevant information to explain the association between COVID-19 cases on 2020-12-04 and number of people without insurance in each county."),
      p("Based on the linear regression analysis, we have the predicted model as"),
      uiOutput("uninsured_lm"),
      p(strong("Visualizations: ")),
      plotlyOutput("p3_line"),
      p(strong("Conclusion:")),
      p("We find the positive association between ",strong("cases_ratio"), " and ", strong("uninsured_ratio"), "."))
)

server <- function(input, output,session) {
  covid <- covidData
  output$p1_line <-
    renderPlotly(ggplotly(case_poverty(ratio)))
  output$p2_line <-
    renderPlotly(ggplotly(case_overcrowding(ratio)))
  output$p3_line <-
    renderPlotly(ggplotly(case_uninsured(ratio)))
  output$distribution <-
    renderPlotly(ggplotly(distribution(covid)))
  output$four_plots_old <-
    renderPlotly(ggplotly(four_plots_old(covid)))
  output$four_plots_new <-
    renderPlotly(ggplotly(four_plots_new(covid)))
  output$poverty_lm<- renderUI({
    withMathJax(
      helpText('$$\\text{COVID-19 Cases Ratio} = 4.61895 + 0.02207 * \\text{Number of Below Poverty Ratio}$$'))
  })
  output$overcrowding_lm<- renderUI({
    withMathJax(
      helpText('$$\\text{COVID-19 Cases Ratio} = 4.74382 + 0.25389 * \\text{Number of Overcrowding People Ratio}$$'))
  })
  output$uninsured_lm<- renderUI({
    withMathJax(
      helpText('$$\\text{COVID-19 Cases Ratio} = 4.56806 + 0.04417 * \\text{Number of People Without Insurance Ratio}$$'))
  })
}

shinyApp(ui = ui, server = server)
