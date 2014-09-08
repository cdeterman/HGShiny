require(shiny)

shinyUI({
  fluidPage(
    
    titlePanel("Dataset Filtering and QC"),
    
    sidebarLayout(
      sidebarPanel(
        fileInput("file", label = h3("CSV File Input")),

        uiOutput("factors_text"),
        uiOutput("factors"),

        tagList(
          singleton(tags$head(tags$script(src='//cdn.datatables.net/1.10.2/js/jquery.dataTables.min.js',type='text/javascript'))),
          singleton(tags$head(tags$script(src='http://cdn.datatables.net/tabletools/2.2.2/js/dataTables.tableTools.min.js',type='text/javascript'))),
          singleton(tags$script(HTML("if (window.innerHeight < 400) alert('Screen too small');")))
        ),
        
        includeCSS('http://cdn.datatables.net/tabletools/2.2.2/css/dataTables.tableTools.css')
        
      ),
      
      mainPanel(
               h1("Your Dataset"),
               
               list(tags$head(tags$style("body {background-color: #ADD8E6;}"))), # set background color for page
               tags$head(tags$style("tfoot {display: table-header-group;")), # move filters to the tob of dataTable
               tags$head(tags$style(".table .alignRight {color: blue; text-align:right;}")),
               
               dataTableOutput("dataset")
      )      
    )
  )
})