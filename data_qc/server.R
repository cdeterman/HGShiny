require(shiny)
shinyServer(function(input, output){
  # Read in the dataset
  my_df <- reactive({
    inFile <- input$file
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header=TRUE)
    data[is.na(data)] <- ""
    return(data)
  })
  
  
  # Title for factors
  output$factors_text <- renderUI({
    if(is.null(my_df())){
      return()
    }else{
      h3("Factors to Filter")
    }
  })
  
  # Get variables that are factors
  output$factors <- renderUI({
    my_df = my_df()
    #if missing input, exit to avoid error
    if(is.null(my_df))
      return()
    
    #colnames that are factors
    var_factors <- names(which(sapply(my_df, is.factor)))
    
    # Create boxes to select factors
    lapply(1:length(var_factors), function(i){
      fluidRow(
        column(3,
               selectInput(tolower(var_factors[i]), toupper(var_factors[i]), choices=levels(my_df[,var_factors[i]]), multiple = TRUE)
        )
      )
    }    
    )    
  })
  
  #render the dataset
  output$dataset <- renderDataTable(
    if(is.null(my_df())){
      print(data.frame(warning="Please upload your dataset"))
    }else{
      my_df <- my_df()
      var_factors <- names(which(sapply(my_df, is.factor)))
      
      for(i in 1:length(var_factors)){
        if(!is.null(input[[tolower(var_factors[i])]])){
          
          my_df <- my_df[which(my_df[,var_factors[i]] %in% input[[tolower(var_factors[i])]]),]
        }
      }
      my_df
    }, options = list(
      "dom" = 'T<"clear">lfrtip',
      pageLength = 15,
      "oTableTools" = list(
        "sSwfPath" = "//cdnjs.cloudflare.com/ajax/libs/datatables-tabletools/2.1.5/swf/copy_csv_xls.swf",
        "aButtons" = list(
          "copy",
          "print",
          list("sExtends" = "collection",
               "sButtonText" = "Export",
               "aButtons" = c("csv","xls")
          )
        )
      )
    )
  )
  

})