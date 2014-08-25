library(shiny)
library(HGmiscTools)

# global maximum number of plots
max_plots=10

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

# Read data and transformation options
{
  # Read in the dataset
  df <- reactive({
    inFile <- input$file
    if (is.null(inFile)) return(NULL)
    data <- read.csv(inFile$datapath, header=TRUE)
    data
  })
  
  # Get dependent variables drop bar
  output$dependent_variable <- renderUI({
    df = df()
    #if missing input, exit to avoid error
    if(is.null(df))
      return()
    
    #colnames
    colnames <- names(df)
    
    # Create checkboxes with default set to client_calls_per_designated_search
    selectInput("dv",
                label = h3("Choose Dependent Variable"), 
                choices = colnames,
                selected = "client_calls_per_designated_search",
                width = '100%')
  })
  
  # whether to log transform the DV
  output$log <- renderUI({
    df = df()
    if(is.null(df))
      return()
    
    checkboxInput("log", label="log transform dv?", value=TRUE)
  })
  
  # choosing the IV's
  output$independent_variables <- renderUI({
    df = df()
    
    # if missing input, exit to avoid error
    if(is.null(df))
      return()
    
    # Get the variable names
    colnames <- names(df)[!names(df) %in% input$dv]
    
    # Create checkboxes for variables to include in model
    checkboxGroupInput("ivs", 
                       label = h3("Variables"), 
                       choices = colnames,
                       selected = c("client_google_rank", "client_search_per_client_providers"))
  })
  
  # option to transform IV's
  output$trans <- renderUI({
    df = df()
    if(is.null(df)){
      return()
    }else{
      checkboxInput("trans", label="Transform any IV's?")
    }
  })
  
  # transformation choices
  output$transform_choices <- renderUI({
    df = df()
    if(is.null(df)){
      return()
    }else{
      if(length(input$trans) == 0){
        return()
      }else{
        if(input$trans == TRUE){
          selectInput("transform_selection",
                      label = "choose transformation",
                      choices = c("sqrt", "log"))
        }else{
          return()
        }
      }
      
    }
  })
  
  # transform variables
  df_transform <- reactive({
    df <- df()
    df <- df[, names(df) %in% c(input$dv, input$ivs), drop=FALSE]
    
    
    # if transforming data
    if(!is.null(input$iv_trans)){
      index <- which(input$ivs %in% input$iv_trans)
      # apply transformation
      df[,index] <- sapply(df[,index], FUN = input$transform_selection)
    }
    df
  })
  
  # which IV's to transform
  output$transform_vars <- renderUI({
    df = df()
    if(is.null(df)){
      return()
    }else{
      if(length(input$trans) == 0){
        return()
      }else{
        if(input$trans == TRUE){
          
          # if transforming, which variables to transform
          checkboxGroupInput("iv_trans",
                             label = h3("Which variable(s) to transform?"),
                             choices = input$ivs)
        }else{
          return()
        }
      }
      
    }
  })
}

# Generating Plots
{

  # generate blank spaces for plots
  output$plots <- renderUI({
    plot_list <- lapply(1:(input$n+1), function(i){
      plotname <- paste("plot", i, sep="")
      plotOutput(plotname, height = 400, width=800)
    })
    
    # convert to taglist
    do.call(tagList, plot_list)
  })
  
  # predicted vs. actual plot
  output$plot1 <- renderPlot({
    df<-df()
    if(is.null(df))
      return()
    actual <- df[, input$dv]
    lm_out <- runRegression()
    par(mfrow=c(1,2))
    pred <- ifelse(rep(input$log, nrow(df)), exp(predict(lm_out)), predict(lm_out))
    plot(actual, pred, pch=19, ylab = "Predicted", xlab = "Actual", main=paste("Predicted vs. Actual\nPearson R-squared =", round(cor(actual, pred)^2, 4), sep=" "))
    plot(actual, col="green", ylab = input$dv, pch=19, main="Predicted and Actual")
    points(pred, col="red", pch=19)
  })
  
  # fill in the boxplots and histograms
  for(i in 2:max_plots){
    local({
      my_i <- i
      plotname <- paste("plot", my_i, sep="")
      
      output[[plotname]] <- renderPlot({
        par(mfrow=c(1,2))
        try(suppressWarnings(boxplot(df_transform()[,input$ivs[my_i-1]], main = input$ivs[my_i-1])), silent=TRUE)
        try(suppressWarnings(hist(df_transform()[, input$ivs[my_i-1]], main = input$ivs[my_i-1], xlab = input$ivs[my_i-1])), silent=TRUE)
      })
    })
  }
  
}

  
# Linear Regression Functions
{
  # Linear Regression
  runRegression <- reactive({
    df <- df()
    df <- df[, names(df) %in% c(input$dv, input$ivs), drop=FALSE]
    
    # transform if selected
    df <- df_transform()
      
    # run regression
    if(input$log){
      lm(as.formula(paste(log(df[, input$dv, drop=FALSE])," ~ ",paste(input$ivs,collapse="+"))),data=df)
    }else{
      lm(as.formula(paste(input$dv," ~ ",paste(input$ivs,collapse="+"))),data=df)
    }
  })
  
  # anova table
  output$model_text <- renderUI({
    if(is.null(df())){
      return()
    }else{
      h3("Model Coefficient Table")
    }
  })
  
  # Coefficient Table
  output$regTab <- renderTable({
    if(!is.null(input$ivs) | !is.null(input$dv)){
      lm_sum <- summary(runRegression())
      coefs <- as.data.frame(lm_sum$coefficients)
      coefs[,4] <- signif(coefs[,4], 4)
      coefs[,4] <- as.character(coefs[,4])
      coefs
    } else {
      if(is.null(df())){
        print(data.frame(warning="Please upload your dataset"))
      }else{
        if(is.null(input$ivs))
          print(data.frame(warning="Please select your Indpendent Variables"))
        if(is.null(input$dv))
          print(data.frame(Warning="Please select your Dependent Variable."))
      }
    }
  }, digits=4)
  
  # anova table
  output$anova_text <- renderUI({
    if(is.null(df())){
      return()
    }else{
      h3("ANOVA Table")
    }
  })
  
  output$anova_table <- renderTable({
    if(is.null(df())){
      return()
    }else{
      M <- as.data.frame(anova(runRegression()))
      M$Df <- as.integer(M$Df)
      M
    }
  }, digits = 4)
  
  
  output$model_metrics <- renderUI({
    if(!is.null(input$ivs)){
      df <- df()
      mod <- summary(runRegression())
      str1 <- paste("R2 =", round(mod$r.squared, 4))
      str2 <- paste("Adjusted R2 =", round(mod$adj.r.squared, 4))
      str3 <- paste("MAD =", round(mad_model(runRegression(), df[, input$dv]), 5))
      HTML(paste(str1, str2, str3, sep = '<br/>'))
    }else{
      return()
    }
  })
  
}
  
  }
)
