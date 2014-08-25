library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("My Shiny App"),
  
  # Sidebar layout
  sidebarLayout(
    sidebarPanel(h2("Intstallation"),
                 p("Shiny is available on CRAN, so you can install it in the usal way from your R console:"),
                 code('install.packages("shiny")'),
                 br(),br(),br(),br(),
                 img(src="bigorb.png", height=50, width=50), "shiny is a product of", span('Rstudio', style="color:blue")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h2("First Apps"),
      br(),br(),
      #lm_app <- )
      p("The only app available is", a("Link", href="file://C:/Users/cdeterman/Documents/R_projects/HGShiny/multi_pages/www/lm_file.R"))
    )
  )
))
