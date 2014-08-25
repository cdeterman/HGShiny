library(xtable)

shiny::runApp(
  list(
    ui = pageWithSidebar(
      
      headerPanel("TEST"),
      
      sidebarPanel(
        helpText('Is this matrix cool ?')
      ),
      
      mainPanel(    
        uiOutput('matrix')     
      )
    )
    , 
    server = function(input,output){
      output$matrix <- renderUI({
        M <- matrix(rep(1,6),nrow=3)
        rownames(M) <- c('a','b','c')
        M <- print(xtable(M, align=rep("c", ncol(M)+1)), 
                   floating=FALSE, tabular.environment="array", comment=FALSE, print.results=FALSE,
                   size = "Huge")
        html <- paste0("$$", M, "$$")
        list(
          tags$script(src = "http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML", type = 'text/javascript'),
          HTML(html)
        )
      })
    }
  )
)