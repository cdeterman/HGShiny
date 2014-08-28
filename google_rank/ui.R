require(shiny)

shinyUI(
  fluidPage(
    titlePanel("Linear Model of Calls to Designated Search"),
    
    sidebarLayout(
      sidebarPanel(
        
        fileInput("file", label = h3("CSV File Input")),
        # drop-down list of dependent variable options
        uiOutput("dependent_variable"),
        # choice to log transform DV
        uiOutput("log"),
        # choice on max number of plots
        sliderInput("n", "Maximum Number of Plots", value = 5, min=1, max=10),
        # choice to transform IV's
        uiOutput("trans"),
        # if transforming, which transformation
        uiOutput("transform_choices"),
        # if transforming, which variables to transform
        uiOutput("transform_vars"),
        # IV's
        uiOutput("independent_variables")
        ),
      
      mainPanel(
        # download PDF option
        downloadButton("downloadPDF", "Download PDF report"),
        br(),
        # print coefficient table
        uiOutput("model_text"),
        tableOutput("regTab"),
        # print model metrics (R2, MAD) below table
        uiOutput("model_metrics"),
        # print anova table
        uiOutput("anova_text"),
        tableOutput("anova_table"),
        # print plots
        uiOutput("plots")
        )
      )
  )
)