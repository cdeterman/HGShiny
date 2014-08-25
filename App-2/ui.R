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
      h2("Introducting Shiny"),
      p("Shiny is a new package from RStudio that makes it", em("incredibly"), "easy to build interactive web applications with R"),
      br(),br(),
      p("For an introductiona nd live examples, visit the", a("Shiny homepage", href="http://www.rstudio.com/shiny")),
      br(), br(),
      h2("Features"),
      p("* Build useful web applications with only a few lines of code -no JavaScript required."),
      p('* Shiny applications are automatically "live" in the same way that ", strong("spreadsheets"), "are live.
        Outputs change instantly as users modify inputs, without requiring a reload of the browser.')
    )
  )
))
